#
# TEST PURPOSE/DESCRIPTION:
# ------------------------
#
# This test is to ensure that 
#

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

DATE_FIRST_CYCL="20210508"
DATE_LAST_CYCL="20210508"
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
# Also, since these staged files use a naming convention differs from
# the default convention in the SRW App, explicitly specify their
# subdirectory and file name templates.
#
VX_FCST_INPUT_BASEDIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/DTC_ensemble_task/staged/fcst_ens"
FCST_SUBDIR_TEMPLATE='{init?fmt=%Y%m%d%H?shift=-${time_lag}}${SLASH_ENSMEM_SUBDIR_OR_NULL}/postprd'
FCST_FN_TEMPLATE='${NET}.t{init?fmt=%H?shift=-${time_lag}}z.bgdawpf{lead?fmt=%HHH?shift=${time_lag}}.tm00.grib2'
FCST_FN_METPROC_TEMPLATE='${NET}.t{init?fmt=%H}z.bgdawpf{lead?fmt=%HHH}.tm00_a${ACCUM}h.nc'
#
# This test assumes the observation files are staged.  Thus, deactivate
# the GET_OBS_... tasks and instead specify the obs staging directories.
#
RUN_TASK_GET_OBS_CCPA="FALSE"
CCPA_OBS_DIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/DTC_ensemble_task/staged/obs/ccpa/proc"
RUN_TASK_GET_OBS_MRMS="FALSE"
MRMS_OBS_DIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/DTC_ensemble_task/staged/obs/mrms/proc"
RUN_TASK_GET_OBS_NDAS="FALSE"
NDAS_OBS_DIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/DTC_ensemble_task/staged/obs/ndas/proc"
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
ENS_TIME_LAG_HRS=( "0" "12" )
# NET is needed to construct the paths/names of the staged forecast files
# using the templates above, and both NET and POST_OUTPUT_DOMAIN_NAME
# are needed to construct the default value of VX_FCST_MODEL_NAME if an
# explicit value for it has not been specified (which is the case for
# this test).  (VX_FCST_MODEL_NAME is the (base) forecast model name to
# use in the vx output, both in the output file names and in their
# contents.)  The alternative is to specify VX_FCST_MODEL_NAME, in which
# case POST_OUTPUT_DOMAIN_NAME is not needed.
NET='RRFSE_CONUS'
POST_OUTPUT_DOMAIN_NAME="rrfs_conus_25km"
# VX_FIELDS specifies the fields for which to perform vx.
VX_FIELDS=( "RETOP" )
#
# MET and METplus paths.  Move these to the machine files?
#
METPLUS_PATH="/contrib/METplus/METplus-4.1.1"
MET_INSTALL_DIR="/contrib/met/10.1.1"
