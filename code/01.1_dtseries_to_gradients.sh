#!/bin/bash

## set up a trap that will clear the ramdisk if it is not cleared
function cleanup_ramdisk {
    echo -n "Cleaning up ramdisk directory /$SLURM_TMPDIR/ on "
    date
    rm -rf /$SLURM_TMPDIR
    echo -n "done at "
    date
}

# trap the termination signal, and call the function 'trap_term' when
# that happens, so results may be saved.
trap "cleanup_ramdisk" TERM


# make a tmpdir for this call
tmpdir=$(mktemp --tmpdir=/$SLURM_TMPDIR -d tmp.XXXXXX)
mkdir $tmpdir/home

# make directory for the sub in the dtseries folder
dtdir=$tmpdir/home/dtseries/$sub_no
mkdir -p $dtdir

sub=$1 
sub_no=$(basename $sub)

# day 1
left1=$(ls "$sub" | grep "REST1_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
right1=$(ls "$sub" |grep "REST1_RL_Atlas_hp2000_clean2sm4.dtseries.nii")
# day 2
left2=$(ls "$sub" | grep "REST2_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
right2=$(ls "$sub" |grep "REST2_RL_Atlas_hp2000_clean2sm4.dtseries.nii")

wb_command -cifti-merge $dtdir/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dtseries.nii"\
 -cifti $sub/$left1 -cifti $sub/$right1

wb_command -cifti-merge $dtdir/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dtseries.nii"\
 -cifti $sub/$left2 -cifti $sub/$right2

# make a subject directory to store left and right
# cortex rois
separate=$tmpdir/home/separate/$sub_no
mkdir -p $separate

sub=$dtdir

day1=$(ls "$sub" | grep "REST1")
day2=$(ls "$sub" | grep "REST2")

# day 1
wb_command -cifti-separate \
$sub/$day1 \
COLUMN \
-metric CORTEX_LEFT $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L.func.gii" \
-roi $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
-metric CORTEX_RIGHT $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R.func.gii" \
-roi $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R_roi.func.gii"

# day 2
wb_command -cifti-separate \
$sub/$day2 \
COLUMN \
-metric CORTEX_LEFT $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L.func.gii" \
-roi $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
-metric CORTEX_RIGHT $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R.func.gii" \
-roi $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R_roi.func.gii"

rm -rf $dtdir

# make directory for the sub in the separated folder
LRcombined=$tmpdir/home/LRcombined/$sub_no
mkdir -p $LRcombined

sub=$separate

# day 1
left_d1=$(ls "$sub" | grep "REST1.*_L.func")
left_d1_roi=$(ls "$sub" | grep "REST1.*_L_roi")
right_d1=$(ls "$sub" | grep "REST1.*_R.func")
right_d1_roi=$(ls "$sub" | grep "REST1.*_R_roi")

# day 2
left_d2=$(ls "$sub" | grep "REST2.*_L.func")
left_d2_roi=$(ls "$sub" | grep "REST2.*_L_roi")
right_d2=$(ls "$sub" | grep "REST2.*_R.func")
right_d2_roi=$(ls "$sub" | grep "REST2.*_R_roi")

# day 1
wb_command -cifti-create-dense-scalar \
$LRcombined/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dscalar.nii" \
-left-metric $sub/$left_d1 \
-roi-left $sub/$left_d1_roi \
-right-metric $sub/$right_d1 \
-roi-right $sub/$right_d1_roi

# day 2
wb_command -cifti-create-dense-scalar \
$LRcombined/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dscalar.nii" \
-left-metric $sub/$left_d2 \
-roi-left $sub/$left_d2_roi \
-right-metric $sub/$right_d2 \
-roi-right $sub/$right_d2_roi

rm -rf $separate

# make directory for the subject in the separated folder
dconn=$tmpdir/home/dconn/$sub_no
mkdir -p $dconn

sub=$LRcombined

day1=$(ls "$sub" | grep "REST1")
day2=$(ls "$sub" | grep "REST2")

# day 1
wb_command -cifti-correlation \
$sub/$day1 \
$dconn/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dconn.nii"

# day 2
wb_command -cifti-correlation \
$sub/$day2 \
$dconn/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dconn.nii"

rm -rf $LRcombined
# Build gradients with dconn
sub=$dconn

source ~/.virtualenvs/gradients/bin/activate

python ~/scratch/build_gradients.py $sub

deactivate
