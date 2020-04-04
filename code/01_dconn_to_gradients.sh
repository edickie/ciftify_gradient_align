#!/bin/bash

## software env
module load NiaEnv/2019b # this allows python to load
module use /home/a/arisvoin/edickie/quarantine/modules/
module load edickie_quarantine connectome-workbench/1.4.2
source /scratch/a/arisvoin/edickie/virtual_envs/brainspace_cifti_0200404_03/bin/activate

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

# # make directory for the sub in the dtseries folder
# dtdir=$tmpdir/home/dtseries/$sub_no
# mkdir -p $dtdir

sub_no=$1
#sub_no=$(basename $sub)

# # day 1
# left1=$(ls "$sub" | grep "REST1_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
# right1=$(ls "$sub" |grep "REST1_RL_Atlas_hp2000_clean2sm4.dtseries.nii")
# # day 2
# left2=$(ls "$sub" | grep "REST2_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
# right2=$(ls "$sub" |grep "REST2_RL_Atlas_hp2000_clean2sm4.dtseries.nii")
#
# wb_command -cifti-merge $dtdir/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dtseries.nii"\
#  -cifti $sub/$left1 -cifti $sub/$right1
#
# wb_command -cifti-merge $dtdir/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dtseries.nii"\
#  -cifti $sub/$left2 -cifti $sub/$right2
#
# # make a subject directory to store left and right
# # cortex rois
# separate=$tmpdir/home/separate/$sub_no
# mkdir -p $separate
#
# sub=$dtdir
#
# day1=$(ls "$sub" | grep "REST1")
# day2=$(ls "$sub" | grep "REST2")
#
# # day 1
# wb_command -cifti-separate \
# $sub/$day1 \
# COLUMN \
# -metric CORTEX_LEFT $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L.func.gii" \
# -roi $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
# -metric CORTEX_RIGHT $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R.func.gii" \
# -roi $separate/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R_roi.func.gii"
#
# # day 2
# wb_command -cifti-separate \
# $sub/$day2 \
# COLUMN \
# -metric CORTEX_LEFT $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L.func.gii" \
# -roi $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
# -metric CORTEX_RIGHT $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R.func.gii" \
# -roi $separate/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R_roi.func.gii"
#
# rm -rf $dtdir
#
# # make directory for the sub in the separated folder
# LRcombined=$tmpdir/home/LRcombined/$sub_no
# mkdir -p $LRcombined
#
# sub=$separate
#
# # day 1
# left_d1=$(ls "$sub" | grep "REST1.*_L.func")
# left_d1_roi=$(ls "$sub" | grep "REST1.*_L_roi")
# right_d1=$(ls "$sub" | grep "REST1.*_R.func")
# right_d1_roi=$(ls "$sub" | grep "REST1.*_R_roi")
#
# # day 2
# left_d2=$(ls "$sub" | grep "REST2.*_L.func")
# left_d2_roi=$(ls "$sub" | grep "REST2.*_L_roi")
# right_d2=$(ls "$sub" | grep "REST2.*_R.func")
# right_d2_roi=$(ls "$sub" | grep "REST2.*_R_roi")
#
# # day 1
# wb_command -cifti-create-dense-timeseries \
# $LRcombined/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dtseries.nii" \
# -left-metric $sub/$left_d1 \
# -roi-left $sub/$left_d1_roi \
# -right-metric $sub/$right_d1 \
# -roi-right $sub/$right_d1_roi
#
# # day 2
# wb_command -cifti-create-dense-timeseries \
# $LRcombined/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dtseries.nii" \
# -left-metric $sub/$left_d2 \
# -roi-left $sub/$left_d2_roi \
# -right-metric $sub/$right_d2 \
# -roi-right $sub/$right_d2_roi
#
# rm -rf $separate

# make directory for the subject in the separated folder
dconn=/scratch/a/arisvoin/jjee/dconn/$sub_no
# mkdir -p $dconn
#
# sub=$LRcombined
#
# day1=$(ls "$sub" | grep "REST1")
# day2=$(ls "$sub" | grep "REST2")
#
# # day 1
# wb_command -cifti-correlation \
# $sub/$day1 \
# $dconn/$sub_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dconn.nii"
#
# # day 2
# wb_command -cifti-correlation \
# $sub/$day2 \
# $dconn/$sub_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dconn.nii"
#
# rm -rf $LRcombined
# # Build gradients with dconn
sub=$dconn

# source ~/.virtualenvs/gradients/bin/activate
#
python ~/code/ciftify_gradient_align/code/01_build_gradients.py $sub /scratch/a/arisvoin/edickie/gradients_raw_txt

# get the subject's gradients.txt
sub_grad_dir=/scratch/a/arisvoin/edickie/gradients_raw_txt/$sub_no
sub_day1=$(ls $sub_grad_dir | grep REST1)
sub_day2=$(ls $sub_grad_dir | grep REST2)

# get the subject's dconn
dconn_dir=/scratch/a/arisvoin/jjee/dconn/$sub_no
dconn_day1=$(ls $dconn_dir | grep REST1)
dconn_day2=$(ls $dconn_dir | grep REST2)

# make subject directory to store dscalar.nii
dscalar_day1_dir=/scratch/a/arisvoin/edickie/gradients_raw_dscalar/day1/$sub_no
mkdir -p $dscalar_day1_dir
dscalar_day2_dir=/scratch/a/arisvoin/edickie/gradients_raw_dscalar/day2/$sub_no
mkdir -p $dscalar_day2_dir

dscalar_tmp=$tmpdir/home/dscalar/$sub_no
mkdir -p $dtdir

wb_command -cifti-convert -from-text \
$sub_grad_dir/$sub_day1 \
$dconn_dir/$dconn_day1 \
$dscalar_day1_dir/${sub_day1%%.*}.dscalar.nii \
-reset-scalars

wb_command -cifti-convert -from-text \
$sub_grad_dir/$sub_day2 \
$dconn_dir/$dconn_day2 \
$dscalar_day2_dir/${sub_day2%%.*}.dscalar.nii \
-reset-scalars

# transpose the rows and columns of dscalar so later tools can read it..
wb_command -cifti-transpose \
$dscalar_day1_dir/${sub_day1%%.*}.dscalar.nii \
$dscalar_day1_dir/${sub_day1%%.*}_t.dscalar.nii

wb_command -cifti-transpose \
$dscalar_day2_dir/${sub_day2%%.*}.dscalar.nii \
$dscalar_day2_dir/${sub_day2%%.*}_t.dscalar.nii
