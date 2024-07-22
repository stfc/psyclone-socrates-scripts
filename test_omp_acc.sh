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
    cp $file out_acc/$outname
done

for file in $FILES
do
    outname=$(basename $file)
    psyclone -api nemo -I temp_dir/ -l output -opsy out_acc/$outname $file
done

for file in ${SOCRATES_BASE}/src/radiance_core/*.F90
do
    outname=$(basename $file)
    psyclone -api nemo -s acc_loops_trans.py -I temp_dir/ -d temp_dir/ --limit all -opsy out_acc/$outname $file
    # Fix issues iwth hoising arrays - we could disablethis like with OpenMP (or fix in PSyclone)
    sed -i "1 s/_mod/_mod\n  use realtype_rd, only : realk/" out_acc/$outname
done
# interp1d doesn't work at all and PSyclone actually fails applying this script at the moment.
cp ${SOCRATES_BASE}/src/radiance_core/interp1d.F90 out_acc/.

# PSyclone outputs opt_prop_inhom_corr_cairns.F90 with an error for the NVidia compiler
# Note that if this file is changed in socrates this command won't work.
printf '%s\n' '13m29' 'wq' | ed -s out_acc/opt_prop_inhom_corr_cairns.F90

# Fix issues with hoisting arrays - this is disabled with OpenMP and could potentially be disabled for acc as well.
#sed -i "1 s/module eigenvalue_tri_mod/module eigenvalue_tri_mod\n  use realtype_rd, only : realk/" out_acc/eigenvalue_tri.F90
#sed -i "1 s/module mixed_solar_source_mod/module mixed_solar_source_mod\n  use realtype_rd, only : realk/" out_acc/mixed_solar_source.F90
#sed -i "1 s/module inter_k_mod/module inter_k_mod\n  use realtype_rd, only : realk/" out_acc/inter_k.F90
#sed -i "1 s/module calc_photolysis_incr_mod/module calc_photolysis_incr_mod\n  use realtype_rd, only : realk/" out_acc/calc_photolysis_incr_mod.F90
#sed -i "1 s/module monochromatic_gas_flux_mod/module monochromatic_gas_flux_mod\n  use realtype_rd, only : realk/" out_acc/monochromatic_gas_flux.F90
#sed -i "1 s/module rescale_phase_fnc_mod/module rescale_phase_fnc_mod\n  use realtype_rd, only : realk/" out_acc/rescale_phase_fnc.F90
#sed -i "1 s/module calc_top_rad_mod/module calc_top_rad_mod\n  use realtype_rd, only : realk/" out_acc/calc_top_rad.F90
#sed -i "1 s/module overlap_coupled_mod/module overlap_coupled_mod\n  use realtype_rd, only : realk/" out_acc/overlap_coupled.F90
#sed -i "1 s/module set_dirn_weights_mod/module set_dirn_weights_mod\n  use realtype_rd, only : realk/" out_acc/set_dirn_weights.F90
#sed -i "1 s/module single_scat_sol_mod/module single_scat_sol_mod\n  use realtype_rd, only : realk/" out_acc/single_scat_sol.F90
#sed -i "1 s/module inter_pt_lookup_mod/module inter_pt_lookup_mod\n  use realtype_rd, only : realk/" out_acc/inter_pt_lookup.F90
#sed -i "1 s/module opt_prop_ukca_aerosol_mod/module opt_prop_ukca_aerosol_mod\n  use realtype_rd, only : realk/" out_acc/opt_prop_ukca_aerosol.F90
#sed -i "1 s/module mix_app_scat_mod/module mix_app_scat_mod\n  use realtype_rd, only : realk/" out_acc/mix_app_scat.F90
#sed -i "1 s/module solar_source_mod/module solar_source_mod\n  use realtype_rd, only : realk/" out_acc/solar_source.F90
#sed -i "1 s/module solar_coefficient_basic_mod/module solar_coefficient_basic_mod\n  use realtype_rd, only : realk/" out_acc/solar_coefficient_basic.F90
#sed -i "1 s/module spherical_trans_coeff_mod/module spherical_trans_coeff_mod\n  use realtype_rd, only : realk/" out_acc/spherical_trans_coeff.F90


# Psyclone can't handle this file as it can't understand some of the function calls as not arrays
cp ${SOCRATES_BASE}/src/radiance_core/diff_planck_source_mod.F90 out_acc/.

cp CMakeLists.txt.acc out_acc/CMakeLists.txt

rm -r temp_dir
