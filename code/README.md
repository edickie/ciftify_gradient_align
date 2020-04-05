
# qbatch -b slurm -w 00:40:00 qbatch__dtseries_to_gradients.txt -c 8 -j 4

# module load gnu-parallel qbatch/2.1.5
#
# cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | \
#  parallel echo ${HOME}/code/ciftify_gradient_align/code/01_dconn_to_gradients.sh {} |\
#  head -10 | \
#  qbatch -b slurm -w 00:40:00 -N rerun_dconn_raw_grad --env none --header "module load gnu-parallel" -c 1 -j 1 -



## ran 20200404 to generate procrutes aligned gradients.

```sh
module load gnu-parallel qbatch/2.1.5

cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | \
 parallel echo bash ${HOME}/code/ciftify_gradient_align/code/01_dconn_to_aligned_gradients.sh {} |\
 qbatch -b slurm -w 00:30:00 -N rerun_dconn_proc_grad --env none --header "module load gnu-parallel" -c 1 -j 1 -

```

## checking if the dscalar outputs are formatted properly

In the output directory - run the following line.
If all outputs say " Type: CIFTI - Dense Scalar" - then the cifti files are good!
If all outputs say "Type: Connectivity Unknown (Could be Unsupported CIFTI File)" - then the cifti files need to be transposed.

```sh
module use /home/a/arisvoin/edickie/quarantine/modules/
module load edickie_quarantine connectome-workbench/1.4.2
cd ${output_directory}
for dscalar in */*/*gradients.dscalar.nii; do
  myline=$(wb_command -file-information ${dscalar} | grep Type: | head -1);
  echo ${dscalar} ${myline};
done
```

## checking that output exits

```sh
subjects=`cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt`
output_dir=/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar/
for maptype in "orig" "proc"; do
for subject in $subjects; do
  FILE=$output_dir/day1/${subject}/${subject}_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_${maptype}.dscalar.nii
  if [ ! -f "$FILE" ]; then
      echo "$FILE does not exist"
  fi
  FILE=$output_dir/day2/${subject}/${subject}_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_${maptype}.dscalar.nii
  if [ ! -f "$FILE" ]; then
      echo "$FILE does not exist"
  fi
done
done
```

/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/213017/213017_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/201111/201111_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/214524/214524_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/204218/204218_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/211114/211114_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/200008/200008_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_orig.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/213017/213017_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/201111/201111_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/214524/214524_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/204218/204218_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day1/211114/211114_rfMRI_REST1_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist
/scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar//day2/200008/200008_rfMRI_REST2_Atlas_hp2000_clean2sm4_gradients_proc.dscalar.nii does not exist

therefore exclude "213017 201111 204218 211114 200008" from final analysis for now.

```sh
subjects=$(cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | grep -v 213017 | grep -v 201111 | grep -v 204218 | grep -v 211114 | grep -v 200008 | grep -v 214524)

cd /scratch/a/arisvoin/edickie/hcp_gradients_20200404/gradients_dscalar/

for maptype in "orig" "proc"; do
  for day in 1 2; do
    for gradient in 1 2 3 4 5 6 7 8 9; do

      # creates the end of the merge command as well as the map names
      cifti_list=""
      map_names=HCP_REST${day}_gradient${gradient}_${maptype}_mapnames.txt
      rm ${map_names}
      for subject in ${subjects}; do
        cifti_list=$(echo ${cifti_list} -cifti day${day}/${subject}/${subject}_rfMRI_REST${day}_Atlas_hp2000_clean2sm4_gradients_${maptype}.dscalar.nii -column ${gradient})
        echo ${subject}_REST${day}_grad${gradient}_${maptype} >> $map_names
      done

      # run the merge command
      wb_command -cifti-merge \
        HCP_REST${day}_gradient${gradient}_${maptype}.dscalar.nii \
        ${cifti_list}

      # set the map names in the dscalar file.
      wb_command -set-map-names \
         HCP_REST${day}_gradient${gradient}_${maptype}.dscalar.nii \
         -name-file ${map_names}
    done
  done
done
```
