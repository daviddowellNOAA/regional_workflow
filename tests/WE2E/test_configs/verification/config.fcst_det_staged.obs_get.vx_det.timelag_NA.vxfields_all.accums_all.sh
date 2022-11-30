#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that 
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

DATE_FIRST_CYCL="20190701"
DATE_LAST_CYCL="20190701"
CYCL_HRS=( "00" )

FCST_LEN_HRS="6"
#
# This test assumes the forecast files are staged (i.e. not generated by
# running the forecast model as part of this experiment ).  Thus, turn
# off the forecast, post-processing, and other tasks that are not needed
# for generation of post-processed forecast files.
#
RUN_TASK_MAKE_GRID="FALSE"
RUN_TASK_MAKE_OROG="FALSE"
RUN_TASK_MAKE_SFC_CLIMO="FALSE"
RUN_TASK_GET_EXTRN_ICS="FALSE"
RUN_TASK_GET_EXTRN_LBCS="FALSE"
RUN_TASK_MAKE_ICS="FALSE"
RUN_TASK_MAKE_LBCS="FALSE"
RUN_TASK_RUN_FCST="FALSE"
RUN_TASK_RUN_POST="FALSE"
#
# Since the forecast files are staged, specify the base staging directory.
#
VX_FCST_INPUT_BASEDIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/DTC_ensemble_task/staged/fcst_det"
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
# Run deterministic vx on the forecast.
#
RUN_TASKS_VXDET="TRUE"
#
# Specify other vx parameters.
#
# NET and POST_OUTPUT_DOMAIN_NAME are needed to construct the paths/names
# of the staged forecast files if those files use the default directory
# and file naming convention assumed in the SRW App (which is the case
# for this test).  They are also needed to construct the default value
# of VX_FCST_MODEL_NAME if an explicit value for it has not been specified
# (which is also the case for this test).  (VX_FCST_MODEL_NAME is the
# (base) forecast model name to use in the vx output, both in the output
# file names and in their contents.)  The alternative is to specify
# VX_FCST_MODEL_NAME, in which case POST_OUTPUT_DOMAIN_NAME is not needed.
NET="rrfs"
POST_OUTPUT_DOMAIN_NAME="rrfs_conus_25km"
#
# MET and METplus paths.  Move these to the machine files?
#
METPLUS_PATH="/contrib/METplus/METplus-4.1.1"
MET_INSTALL_DIR="/contrib/met/10.1.1"
