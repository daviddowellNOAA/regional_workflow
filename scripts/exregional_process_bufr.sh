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
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
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

This is the ex-script for the task that runs bufr (cloud, metar, lightning) preprocess
with FV3 for the specified cycle.
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
valid_args=( "CYCLE_DIR" "WORKDIR")
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
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"WCOSS_C" | "WCOSS")
#

  if [ "${USE_CCPP}" = "TRUE" ]; then
  
# Needed to change to the experiment directory because the module files
# for the CCPP-enabled version of FV3 have been copied to there.

    cd_vrfy ${CYCLE_DIR}
  
    set +x
    source ./module-setup.sh
    module use $( pwd -P )
    module load modules.fv3
    module list
    set -x
  
  else
  
    . /apps/lmod/lmod/init/sh
    module purge
    module use /scratch4/NCEPDEV/nems/noscrub/emc.nemspara/soft/modulefiles
    module load intel/16.1.150 impi/5.1.1.109 netcdf/4.3.0 
    module list
  
  fi

  ulimit -s unlimited
  ulimit -a
  APRUN="mpirun -l -np ${PE_MEMBER01}"
  ;;
#
"HERA")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  LD_LIBRARY_PATH="${UFS_WTHR_MDL_DIR}/FV3/ccpp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  ;;
#
"JET")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  LD_LIBRARY_PATH="${UFS_WTHR_MDL_DIR}/FV3/ccpp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  ;;
#
"ODIN")
#
  module list

  ulimit -s unlimited
  ulimit -a
  APRUN="srun -n ${PE_MEMBER01}"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting year, month, day, and hour of the
# forecast.  These are needed below for various operations.
#
#-----------------------------------------------------------------------
#
set -x
START_DATE=`echo "${CDATE}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/'`
  YYYYMMDDHH=`date +%Y%m%d%H -d "${START_DATE}"`
  JJJ=`date +%j -d "${START_DATE}"`

YYYY=${YYYYMMDDHH:0:4}
MM=${YYYYMMDDHH:4:2}
DD=${YYYYMMDDHH:6:2}
HH=${YYYYMMDDHH:8:2}
YYYYMMDD=${YYYYMMDDHH:0:8}

YYJJJHH=`date +"%y%j%H" -d "${START_DATE}"`
PREYYJJJHH=`date +"%y%j%H" -d "${START_DATE} 1 hours ago"`

#
#-----------------------------------------------------------------------
#
# Get into working directory
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Getting into working directory for BUFR obseration process ..."

cd ${WORKDIR}

fixdir=$FIXgsi/

print_info_msg "$VERBOSE" "fixdir is $fixdir"

#
#-----------------------------------------------------------------------
#
# link or copy background files
#
#-----------------------------------------------------------------------

cp_vrfy ${fixdir}/fv3_grid_spec          fv3sar_grid_spec.nc
cp_vrfy ${fixdir}/geo_em.d01.nc          geo_em.d01.nc


#-----------------------------------------------------------------------
#
#   copy bufr table
#
#-----------------------------------------------------------------------
BUFR_TABLE=${fixdir}/prepobs_prep_RAP.bufrtable
cp_vrfy $BUFR_TABLE prepobs_prep.bufrtable

#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Link to the observation lightning bufr files
#
#-----------------------------------------------------------------------

run_lightning=false
obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.lghtng.tm00.bufr_d
print_info_msg "$VERBOSE" "obsfile is $obs_file"
if [ -r "${obs_file}" ]; then
   cp_vrfy "${obs_file}" "lghtngbufr"
   run_lightning=true
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi

#-----------------------------------------------------------------------
#
# Build namelist and run executable for lightning
#
#   analysis_time : process obs used for this analysis date (YYYYMMDDHH)
#   minute        : process obs used for this analysis minute (integer)
#   trange_start  : obs time window start (minutes before analysis time)
#   trange_end    : obs time window end (minutes after analysis time)
#   bkversion     : grid type (background will be used in the analysis)
#                   0 for ARW  (default)
#                   1 for FV3LAM
#-----------------------------------------------------------------------

cat << EOF > lightning_bufr.namelist
 &setup
  analysis_time = ${YYYYMMDDHH},
  minute=00,
  trange_start=-10,
  trange_end=10,
  bkversion=1,
 /

EOF

#
#-----------------------------------------------------------------------
#
# link/copy executable file to working directory 
#
#-----------------------------------------------------------------------
#
EXEC="${EXECDIR}/process_Lightning_bufr.exe"

if [ -f $EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the lightning process  executable to the run directory..."
  cp_vrfy ${EXEC} ${WORKDIR}/process_Lightning_bufr.exe
else
  print_err_msg_exit "\
The executable specified in EXEC does not exist:
  EXEC = \"$EXEC\"
Build lightning process and rerun."
fi
#
#
#-----------------------------------------------------------------------
#
# Run the process for lightning bufr file 
#
#-----------------------------------------------------------------------
#
if [ $run_lightning ]; then
   $APRUN ./process_Lightning_bufr.exe > stdout_lightning_bufr 2>&1 || print_err_msg "\
   Call to executable to run lightning process returned with nonzero exit code."
fi

#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Link to the observation NASA LaRC cloud bufr file
#
#-----------------------------------------------------------------------

obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.lgycld.tm00.bufr_d
print_info_msg "$VERBOSE" "obsfile is $obs_file"
run_cloud=false
if [ -r "${obs_file}" ]; then
   cp_vrfy "${obs_file}" "NASA_LaRC_cloud.bufr"
   run_cloud=true
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi

#-----------------------------------------------------------------------
#
# Build namelist and run executable for NASA LaRC cloud
#
#   analysis_time : process obs used for this analysis date (YYYYMMDDHH)
#   bufrfile      : result BUFR file name
#   npts_rad      : number of grid point to build search box (integer)
#   ioption       : interpolation options
#                   = 1 is nearest neighrhood
#                   = 2 is median of cloudy fov
#   bkversion     : grid type (background will be used in the analysis)
#                   = 0 for ARW  (default)
#                   = 1 for FV3LAM
#-----------------------------------------------------------------------

cat << EOF > namelist_nasalarc
 &setup
  analysis_time = ${YYYYMMDDHH},
  bufrfile='NASALaRCCloudInGSI_bufr.bufr',
  npts_rad=1,
  ioption = 2,
  bkversion=1,
 /
EOF

#
#-----------------------------------------------------------------------
#
# Copy the executable to the run directory.
#
#-----------------------------------------------------------------------
#
EXEC="${EXECDIR}/process_larccld.exe"

if [ -f $EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the NASA LaRC cloud process  executable to the run directory..."
  cp_vrfy ${EXEC} ${WORKDIR}/process_larccld.exe
else
  print_err_msg_exit "\
The executable specified in EXEC does not exist:
  EXEC = \"$EXEC\"
Build lightning process and rerun."
fi
#
#
#-----------------------------------------------------------------------
#
# Run the process for NASA LaRc cloud  bufr file 
#
#-----------------------------------------------------------------------
#
if [ $run_cloud ]; then
  $APRUN ./process_larccld.exe > stdout_nasalarc 2>&1 || print_err_msg "\
  Call to executable to run NASA LaRC Cloud process returned with nonzero exit code."
fi

#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
# Link to the observation prepbufr bufr file for METAR cloud
#
#-----------------------------------------------------------------------

obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00 
print_info_msg "$VERBOSE" "obsfile is $obs_file"
run_metar=false
if [ -r "${obs_file}" ]; then
   cp_vrfy "${obs_file}" "prepbufr"
   run_metar=true
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi

#-----------------------------------------------------------------------
#
# Build namelist for METAR cloud
#
#   analysis_time   : process obs used for this analysis date (YYYYMMDDHH)
#   analysis_minute : process obs used for this analysis minute (integer)
#   prepbufrfile    : input prepbufr file name
#   twindin         : observation time window (real: hours before and after analysis time)
#
#-----------------------------------------------------------------------

cat << EOF > namelist_metarcld
 &setup
  analysis_time = ${YYYYMMDDHH},
  prepbufrfile='prepbufr',
  twindin=0.5,
 /
EOF

#
#-----------------------------------------------------------------------
#
# Copy the executable to the run directory.
#
#-----------------------------------------------------------------------
#
EXEC="${EXECDIR}/process_metarcld.exe"

if [ -f $EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the METAR cloud process  executable to the run directory..."
  cp_vrfy ${EXEC} ${WORKDIR}/process_metarcld.exe
else
  print_err_msg_exit "\
The executable specified in EXEC does not exist:
  EXEC = \"$EXEC\"
Build lightning process and rerun."
fi
#
#
#-----------------------------------------------------------------------
#
# Run the process for METAR cloud bufr file 
#
#-----------------------------------------------------------------------
#
if [ $run_metar ]; then
  $APRUN ./process_metarcld.exe > stdout_metarcld 2>&1 || print_err_msg "\
  Call to executable to run METAR cloud process returned with nonzero exit code."
fi

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
BUFR PROCESS completed successfully!!!

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

