#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source the file containing the function that sets various parameters
# needed by MET/METplus verification tasks.
#
#-----------------------------------------------------------------------
#
. $USHDIR/set_MET_vx_params.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs METplus for grid-stat on
the UPP output files by initialization time for all forecast hours.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "cycle_dir" )
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args "valid_args"
#
#-----------------------------------------------------------------------
#
# Set the names to use to identify the field in various types of MET
# output.  Definitions:
#
# FIELDNAME_IN_MET_OUTPUT:
# Specifies the name of the array to use in MET output NetCDF files.
#
# FIELDNAME_IN_MET_FILEDIR_NAMES:
# Specifies the name of the field as it appears in files and directories
# that the MET-based verification tasks create.
#
#-----------------------------------------------------------------------
#
FIELDNAME_IN_MET_OUTPUT=""
FIELDNAME_IN_MET_FILEDIR_NAMES=""
set_MET_vx_params field="$VAR" accum="${ACCUM:-}" \
                  outvarname_fieldname_in_MET_output="FIELDNAME_IN_MET_OUTPUT" \
                  outvarname_fieldname_in_MET_filedir_names="FIELDNAME_IN_MET_FILEDIR_NAMES"
#
#-----------------------------------------------------------------------
#
# Set the array of forecast hours for which to run pcp_combine.  Note 
# that for ensemble forecasts that contain time-lagged members, these
# forecast hours are relative to the non-time-lagged initialization
# time of the cycle (i.e. same as if there were no time-lagged members).
#
# Note:
# Need to add a step here to to remove those forecast hours for which
# obs are not available (i.e. for which obs files do not exist).
#
#-----------------------------------------------------------------------
#
echo "BBBBBBBBBBBBBBBBBBBBBBBBBBB"
echo "  CDATE = |$CDATE|"

fhr_array=($( seq ${ACCUM:-1} ${ACCUM:-1} ${FCST_LEN_HRS} ))
echo "fhr_array = |${fhr_array[@]}|"
FHR_LIST=$( echo "${fhr_array[@]}" | $SED "s/ /,/g" )
echo "FHR_LIST = |${FHR_LIST[@]}|"
#
#-----------------------------------------------------------------------
#
# Set variables that the METplus conf files assume exist in the
# environment.
#
#-----------------------------------------------------------------------
#
INPUT_BASE=${OBS_DIR}
OUTPUT_BASE=${MET_OUTPUT_DIR}
OUTPUT_SUBDIR="metprd/pcp_combine_nogridstat"
LOG_SUFFIX="${CDATE}_${FIELDNAME_IN_MET_FILEDIR_NAMES}"
#
#-----------------------------------------------------------------------
#
# Create the directory(ies) in which MET/METplus will place its output
# from this script.  We do this here because (as of 20220811), when 
# multiple workflow tasks are launched that all require METplus to create
# the same directory, some of the METplus tasks can fail.  This is a 
# known bug and should be fixed by 20221000.  See https://github.com/dtcenter/METplus/issues/1657.
# If/when it is fixed, the following directory creation step can be 
# removed from this script.
#
#-----------------------------------------------------------------------
#
mkdir_vrfy -p "${OUTPUT_BASE}/${OUTPUT_SUBDIR}"
#
#-----------------------------------------------------------------------
#
# Check for existence of top-level OBS_DIR.
#
#-----------------------------------------------------------------------
#
if [ ! -d "${OBS_DIR}" ]; then
  print_err_msg_exit "\
OBS_DIR does not exist or is not a directory:
  OBS_DIR = \"${OBS_DIR}\""
fi
#
#-----------------------------------------------------------------------
#
# Export variables to environment to make them accessible in METplus
# configuration files.
#
#-----------------------------------------------------------------------
#
# Variables needed in the common METplus configuration file (at 
# ${METPLUS_CONF}/common.conf).
#
export MET_INSTALL_DIR
export METPLUS_PATH
export MET_BIN_EXEC
export METPLUS_CONF
export LOGDIR
#
# Variables needed in the METplus configuration file metplus_config_fp
# defined below.
#
export CDATE
export INPUT_BASE
export OUTPUT_BASE
export OUTPUT_SUBDIR
export LOG_SUFFIX
export FIELDNAME_IN_MET_OUTPUT
export FIELDNAME_IN_MET_FILEDIR_NAMES
export FHR_LIST
#
#-----------------------------------------------------------------------
#
# Run METplus.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Calling METplus to run MET's PcpCombine tool..."
metplus_config_fp="${METPLUS_CONF}/PcpCombine_obs_APCP.conf"
${METPLUS_PATH}/ush/run_metplus.py \
  -c ${METPLUS_CONF}/common.conf \
  -c ${metplus_config_fp} || \
print_err_msg_exit "
Call to METplus failed with return code: $?
METplus configuration file used is:
  metplus_config_fp = \"${metplus_config_fp}\""
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
METplus pcp_combine tool completed successfully.

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1