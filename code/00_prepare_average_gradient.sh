# building the reference grandients from the average release

## software env
module load NiaEnv/2019b # this allows python to load
module use /home/a/arisvoin/edickie/quarantine/modules/
module load edickie_quarantine connectome-workbench/1.4.2
source /scratch/a/arisvoin/edickie/virtual_envs/brainspace_cifti_0200404_03/bin/activate


# some general housekeeping
working_dir=/scratch/a/arisvoin/edickie/for_jjee
start_dconn=HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_zcorr_recon2.dconn.nii
cifti_roi=/home/a/arisvoin/edickie/code/ciftify/ciftify/data/HCP_S1200_GroupAvg_v1/Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii


cd $working_dir

## now make corr instead of zcorr
wb_command -cifti-math "tanh(x)" \
HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_corr_recon2.dconn.nii \
-var x $start_dconn

## removing the subcortical bit
wb_command -cifti-restrict-dense-map \
 HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_corr_recon2.dconn.nii \
 ROW tmp1_average.dconn.nii \
  -left-roi roi.L.shape.gii \
  -right-roi roi.R.shape.gii

wb_command -cifti-restrict-dense-map tmp1_average.dconn.nii COLUMN \
  HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_corr_recon2_CORTEX.dconn.nii \
    -left-roi roi.L.shape.gii \
    -right-roi roi.R.shape.gii

## putting the output into an average in folder
mkdir average_cortex_in
mkdir average_cortex_out
cp HCP_S1200_812_rfMRI_MSMAll_groupPCA_d4500ROW_corr_recon2_CORTEX.dconn.nii average_cortex_in/average_cortex.dconn.nii

## running python script on average
python ~/code/ciftify_gradient_align/code/01_build_gradients.py ${SCRATCH}/for_jjee/average_cortex_in ${SCRATCH}/for_jjee/average_cortex_out

cd ${SCRATCH}/for_jjee/average_cortex_out/average_cortex_in/

wb_command -cifti-convert -from-text \
average_cortex_gradients.txt \
${SCRATCH}/for_jjee/average_cortex_in/average_cortex.dconn.nii \
tmp_average_cortex_gradients.dscalar.nii \
-reset-scalars
