#!/usr/bin/env python
# -----------------------------------------------------------------------------
# BSD 3-Clause License
#
# Copyright (c) 2021-2024, Science and Technology Facilities Council.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
# Authors: S. Siso, STFC Daresbury Lab

''' PSyclone transformation script showing the introduction of OpenMP for GPU
directives into Nemo code. '''

from psyclone.psyGen import TransInfo
from psyclone.psyir.nodes import (
    Call, Loop, Directive, Assignment, OMPAtomicDirective, Routine,
    IntrinsicCall)
from psyclone.psyir.transformations import OMPTargetTrans
from psyclone.transformations import OMPDeclareTargetTrans

from utils import insert_explicit_loop_parallelism, normalise_loops, \
    enhance_tree_information, add_profiling

from psyclone.psyir.transformations import OMPTargetTrans, InlineTrans, LoopFuseTrans
from psyclone.domain.common.transformations import KernelModuleInlineTrans
from psyclone.transformations import OMPDeclareTargetTrans, TransformationError
from psyclone.psyir.transformations import Product2LoopTrans


PROFILING_ENABLED = False


def trans(psy):
    ''' Add OpenMP Target and Loop directives to all loops, including the
    implicit ones, to parallelise the code and execute it in an acceleration
    device.

    :param psy: the PSy object which this script will transform.
    :type psy: :py:class:`psyclone.psyGen.PSy`
    :returns: the transformed PSy object.
    :rtype: :py:class:`psyclone.psyGen.PSy`

    '''
    omp_target_trans = OMPTargetTrans()
    omp_loop_trans = TransInfo().get_trans_name('OMPLoopTrans')
    omp_loop_trans.omp_directive = "loop"
    routine_sym = None

    print(f"Invokes found in {psy.name}:")
    print(psy.invokes)
    for invoke in psy.invokes.invoke_list:
        print(invoke.name)

        if PROFILING_ENABLED:
            add_profiling(invoke.schedule.children)

        # TODO #2317: Has structure accesses that can not be offloaded and has
        # a problematic range to loop expansion of (1:1)
        if psy.name.startswith("psy_obs_"):
            print("Skipping", invoke.name)
            continue

        # TODO #1841: These files have a bug in the array-range-to-loop
        # transformation. One leads to the following compiler error
        # NVFORTRAN-S-0083-Vector expression used where scalar expression
        # required, the other to an incorrect result.
        if invoke.name in ("trc_oce_rgb", ):
            print("Skipping", invoke.name)
            continue

        # This are functions with scalar bodies, we don't want to parallelise
        # them, but we could:
        # - Inine them
        # - Annotate them with 'omp declare target' and allow to call from gpus
        if invoke.name in ("q_sat", "sbc_dcy", "gamma_moist", "cd_neutral_10m",
                           "psi_h", "psi_m"):

            print("Skipping", invoke.name)
            continue

        enhance_tree_information(invoke.schedule)
       
        inline_trans = InlineTrans()
        kern_in_trans = KernelModuleInlineTrans()
        inlined_syms = []
        for call in invoke.schedule.walk(Call):
            if(call.routine.name == "exp_v" or call.routine.name == "sqrt_v" or call.routine.name == "rescale_tau_omega"):
                try:
                    kern_in_trans.apply(call)
                    inlined_syms.append(call.routine)
                except Exception as err:
                    pass
                try:
                    inline_trans.apply(call)
                except Exception as err:
                    if(call.routine.name == "exp_v"):
                        print("Failed to inline")
                        print(err)
                    elif call.routine.name == "rescale_tau_omega":
                        print("Failed to inline rescale_tau_omega")
                        print(err)

        normalise_loops(
                invoke.schedule,
                hoist_local_arrays=False,
                convert_array_notation=True,
                loopify_array_intrinsics=True,
                convert_range_loops=True,
                hoist_expressions=True
        )

        # For performance in lib_fortran, mark serial routines as GPU-enabled
        if psy.name == "psy_lib_fortran_psy":
            if not invoke.schedule.walk(Loop):
                calls = invoke.schedule.walk(Call)
                if all(call.is_available_on_device() for call in calls):
                    OMPDeclareTargetTrans().apply(invoke.schedule)
                    continue

        # For now this is a special case for stpctl.f90 because it forces
        # loops to parallelise without many safety checks
        # TODO #2446: This needs to be generalised and probably be done
        # from inside the loop transformation when the race condition data
        # dependency is found.
        if psy.name == "psy_stpctl_psy":
            for loop in invoke.schedule.walk(Loop):
                # Skip if an outer loop is already parallelised
                if loop.ancestor(Directive):
                    continue
                omp_loop_trans.apply(loop, options={"force": True})
                omp_target_trans.apply(loop.parent.parent)
                assigns = loop.walk(Assignment)
                if len(assigns) == 1 and assigns[0].lhs.symbol.name == "zmax":
                    stmt = assigns[0]
                    if OMPAtomicDirective.is_valid_atomic_statement(stmt):
                        parent = stmt.parent
                        atomic = OMPAtomicDirective()
                        atomic.children[0].addchild(stmt.detach())
                        parent.addchild(atomic)
            continue
        # Fuse loops
        current_index = 0
        loops = invoke.schedule.walk(Loop)
        if invoke.name not in "solve_band_random_overlap":
            fusetrans = LoopFuseTrans()
            fuses = 0
            while current_index < len(loops)-1:
                loop = loops[current_index]
                next_loop = loops[current_index+1]
                if loop.depth == next_loop.depth:
                    try:
                        fusetrans.apply(loop, next_loop)
                        # If successful
                        loops = invoke.schedule.walk(Loop)
                        fuses = fuses + 1
                    except:
                        #Unsuccessful
                        current_index = current_index+1
                else:
                    current_index= current_index + 1
        for routine_sym in inlined_syms:
            def skip_for_correctness(loop):
                for call in loop.walk(Call):
                    if not isinstance(call, IntrinsicCall):
                        print(f"Loop not parallelised because it has a call to "
                              f"{call.routine.name}")
                        return True
                    if not call.is_available_on_device():
                        print(f"Loop not parallelised because it has a "
                              f"{call.intrinsic.name} not available on GPUs.")
                        return True
                if loop.walk(CodeBlock):
                    print("Loop not parallelised because it has a CodeBlock")
                    return True
                return False
            if routine_sym.is_modulevar:
                table = routine_sym.find_symbol_table(call)
                for routine in table.node.walk(Routine):
                    if( routine.name.lower() == "exp_v" or routine.name.lower() == "sqrt_v"):
                        for loop in routine.walk(Loop):
                            region_directive_trans=omp_target_trans
                            loop_directive_trans=omp_loop_trans
                            # Collapse is necessary to give GPUs enough parallel items
                            collapse=True
                            opts = {}
                            try:
                                loop_directive_trans.apply(loop, options=opts)
                                # Only add the region directive if the loop was successfully
                                # parallelised.
                                if region_directive_trans:
                                    region_directive_trans.apply(loop.parent.parent)
                            except TransformationError as err:
                                # This loop can not be transformed, proceed to next loop
                                print("Loop not parallelised because:", str(err))
                                continue

                            if collapse:
                                # Count the number of perfectly nested loops that can be collapsed
                                num_nested_loops = 0
                                next_loop = loop
                                previous_variables = []
                                while isinstance(next_loop, Loop):
                                    previous_variables.append(next_loop.variable)
                                    num_nested_loops += 1

                                    # If it has more than one children, the next loop will not be
                                    # perfectly nested, so stop searching
                                    if len(next_loop.loop_body.children) > 1:
                                        break

                                    next_loop = next_loop.loop_body.children[0]
                                    if not isinstance(next_loop, Loop):
                                        break

                                    # If it is a dependent (e.g. triangular) loop, it can not be
                                    # collapsed
                                    dependent_of_previous_variable = False
                                    for bound in (next_loop.start_expr, next_loop.stop_expr,
                                                  next_loop.step_expr):
                                        for ref in bound.walk(Reference):
                                            if ref.symbol in previous_variables:
                                                dependent_of_previous_variable = True
                                                break
                                    if dependent_of_previous_variable:
                                        break

                                    # Check that the next loop has no loop-carried dependencies
                                    if not next_loop.independent_iterations():
                                        break

                                # Add collapse clause to the parent directive
                                if num_nested_loops > 1:
                                    loop.parent.parent.collapse = num_nested_loops
        insert_explicit_loop_parallelism(
                invoke.schedule,
                region_directive_trans=omp_target_trans,
                loop_directive_trans=omp_loop_trans,
                # Collapse is necessary to give GPUs enough parallel items
                collapse=True
        )

    return psy
