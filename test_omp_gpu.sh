#! /bin/bash

export PSYCLONE_CONFIG=psyclone.cfg

export SOCRATES_BASE=/home/achalk/socrates_new/um13.6_runes_lfric

FILES="${SOCRATES_BASE}/src/cosp_control/cosp_constants_mod.F90
${SOCRATES_BASE}/src/cosp_github/src/cosp_constants.F90
${SOCRATES_BASE}/src/cosp_github/src/cosp.F90
${SOCRATES_BASE}/src/cosp_control/cosp_def_diag.F90
${SOCRATES_BASE}/src/cosp_control/cosp_diagnostics_mod.F90
${SOCRATES_BASE}/src/cosp_control/cosp_input_mod.F90
${SOCRATES_BASE}/src/cosp_control/cosp_mod.F90
${SOCRATES_BASE}/src/cosp_control/cosp_radiation_mod.F90
${SOCRATES_BASE}/src/cosp_control/cosp_types_mod.F90
${SOCRATES_BASE}/src/cosp_github/driver/src/cosp2_io.f90
${SOCRATES_BASE}/src/cosp_github/model-interface/cosp_errorHandling.F90
${SOCRATES_BASE}/src/cosp_github/model-interface/cosp_kinds.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/quickbeam_optics/array_lib.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/quickbeam_optics/math_lib.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/quickbeam_optics/mrgrnk.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/quickbeam_optics/optics_lib.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/quickbeam_optics/quickbeam_optics.F90
${SOCRATES_BASE}/src/illumination/astro_constants_mod.F90
${SOCRATES_BASE}/src/illumination/def_orbit.F90
${SOCRATES_BASE}/src/illumination/orbprm_mod.F90
${SOCRATES_BASE}/src/illumination/socrates_illuminate.F90
${SOCRATES_BASE}/src/illumination/solang_mod.F90
${SOCRATES_BASE}/src/illumination/solinc_mod.F90
${SOCRATES_BASE}/src/illumination/solpos_mod.F90
${SOCRATES_BASE}/src/interface_core/socrates_bones.F90
${SOCRATES_BASE}/src/interface_core/socrates_cloud_abs_diag.F90
${SOCRATES_BASE}/src/interface_core/socrates_cloud_ext_diag.F90
${SOCRATES_BASE}/src/interface_core/socrates_cloud_gen.F90
${SOCRATES_BASE}/src/interface_core/socrates_cloud_level_diag.F90
${SOCRATES_BASE}/src/interface_core/socrates_def_diag.F90
${SOCRATES_BASE}/src/interface_core/socrates_runes.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_aer.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_bound.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_cld.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_cld_dim.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_cld_mcica.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_control.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_diag.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_dimen.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_spectrum.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_topography.F90
${SOCRATES_BASE}/src/modules_core/yomhook.F90
${SOCRATES_BASE}/src/modules_core/errormessagelength_mod.F90
${SOCRATES_BASE}/src/modules_core/rad_ccf.F90
${SOCRATES_BASE}/src/modules_core/missing_data_mod.F90
${SOCRATES_BASE}/src/modules_core/parkind1.F90
${SOCRATES_BASE}/src/modules_core/filenamelength_mod.F90
${SOCRATES_BASE}/src/modules_core/vectlib_mod.F90
${SOCRATES_BASE}/src/modules_core/ereport_mod.F90
${SOCRATES_BASE}/src/modules_core/dimensions_spec_ucf.F90
${SOCRATES_BASE}/src/modules_core/file_manager.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/quickbeam/quickbeam.F90
${SOCRATES_BASE}/src/cosp_github/src/cosp_stats.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_modis_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_rttov_interfaceSTUB.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_misr_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_isccp_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_calipso_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/actsim/lidar_simulator.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_atlid_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_grLidar532_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_parasol_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/cosp_cloudsat_interface.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/MISR_simulator/MISR_simulator.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/parasol/parasol.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/rttov/cosp_rttovSTUB.F90
${SOCRATES_BASE}/src/interface_core/socrates_set_atm.F90
${SOCRATES_BASE}/src/aux/nml_mod.f90
${SOCRATES_BASE}/src/aux/read_cdf3.f90
"

# Processing these files with PSyclone leads to issues with NVidia compiler (even without any transformations)
COPY_FILES="
${SOCRATES_BASE}/src/cosp_github/src/cosp_config.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/MODIS_simulator/modis_simulator.F90
${SOCRATES_BASE}/src/cosp_github/subsample_and_optics_example/optics/cosp_optics.F90
${SOCRATES_BASE}/src/cosp_github/src/simulator/icarus/icarus.F90
${SOCRATES_BASE}/src/aux/runes_driver3.f90
${SOCRATES_BASE}/src/modules_core/realtype_rd.f90
"

# Setup a set of temp directories to use for the -I flag to PSyclone
mkdir -p temp_dir
for file in $FILES
do
    outname=$(basename $file)
    cp $file temp_dir/$outname
done
for file in $COPY_FILES
do
    outname=$(basename $file)
    cp $file temp_dir/$outname
done
for file in ${SOCRATES_BASE}/src/radiance_core/*.F90
do
    outname=$(basename $file)
    cp $file temp_dir/$outname
done

# We need to sed vectlib to remove the yomhook calls
sed -i 's/IF (lhook)/!IF (lhook)/' temp_dir/vectlib_mod.F90
sed -i 's/CHARACTER(LEN=*)/!CHARACTER(LEN=*)/' temp_dir/vectlib_mod.F90


for file in $COPY_FILES
do
    outname=$(basename $file)
    cp $file out_omp/$outname
done

for file in $FILES
do
    outname=$(basename $file)
    psyclone -api nemo -I temp_dir/ -l output -opsy out_omp/$outname $file
done

for file in ${SOCRATES_BASE}/src/radiance_core/*.F90
do
    outname=$(basename $file)
    psyclone -api nemo -s omp_gpu_trans.py -I temp_dir/ -d temp_dir/ --limit all -opsy out_omp/$outname $file
done
# PSyclone outputs opt_prop_inhom_corr_cairns.F90 with an error for the NVidia compiler
# Note that if this file is changed in socrates this command won't work.
printf '%s\n' '12m28' 'wq' | ed -s out_omp/opt_prop_inhom_corr_cairns.F90


# Psyclone can't handle this file as it can't understand some of the function calls as not arrays
cp ${SOCRATES_BASE}/src/radiance_core/diff_planck_source_mod.F90 out_omp/.

# I build using CMake - this needs Ninja as well to work. Use `cmake -GNinja ..` from a build directory inside out_omp
cp CMakeLists.txt.omp out_omp/CMakeLists.txt

rm -r temp_dir
