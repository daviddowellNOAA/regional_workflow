#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that 
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"
#
# This test assumes the forecast files will be generated by running a
# an ensemble forecast.  Thus, specify the parameters needed to run
# such a forecast.  Note that the flag that turns on ensemble forecasts
# (IS_ENS_FCST) as well as the number of ensemble members are set further
# below.
#
PREDEF_GRID_NAME="RRFS_CONUS_25km"
LAYOUT_X="10"
LAYOUT_Y="4"
CCPP_PHYS_SUITE="FV3_GFS_2017_gfdlmp"

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"
USE_USER_STAGED_EXTRN_FILES="TRUE"

DATE_FIRST_CYCL="20190701"
DATE_LAST_CYCL="20190701"
CYCL_HRS=( "00" )

FCST_LEN_HRS="6"
LBC_SPEC_INTVL_HRS="3"
#
# This test assumes the observation files will be fetched using the
# GET_OBS_... tasks.  Thus, activate these tasks and specify the
# locations for staging the files.
#
RUN_TASK_GET_OBS_CCPA="TRUE"
CCPA_OBS_DIR='$EXPTDIR/obs/ccpa/proc'
RUN_TASK_GET_OBS_MRMS="TRUE"
MRMS_OBS_DIR='$EXPTDIR/obs/mrms/proc'
RUN_TASK_GET_OBS_NDAS="TRUE"
NDAS_OBS_DIR='$EXPTDIR/obs/ndas/proc'
#
# This test assumes that the forecast(s) to be verified is an ensemble
# forecast, i.e. that the post-processed forecast files are in an ensemble
# directory structure.  Thus, turn the flag that specifies this on and
# specify the number of members in the ensemble.
#
IS_ENS_FCST="TRUE"
NUM_ENS_MEMBERS="2"
#
# Run deterministic vx on each member of the forecast ensemble.
#
RUN_TASKS_VXDET="TRUE"
#
# Run vx on the ensemble as a whole.
#
RUN_TASKS_VXENS="TRUE"
#
# Specify other vx parameters.
#
# ENS_TIME_LAG_HRS is the time-lagging that the vx tasks should assume
# for each ensemble member (in units of hours).
ENS_TIME_LAG_HRS=( "0" "0" )
# VX_FCST_MODEL_NAME is the (base) forecast model name to use in the vx
# output, both in the output file names and in their contents.  This has
# a default value based on NET and POST_OUTPUT_DOMAIN_NAME (which have
# their own default values).  Here, we explicitly specify its value.
VX_FCST_MODEL_NAME="RRFSE_CONUS_25km"