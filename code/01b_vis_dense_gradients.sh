#!/bin/bash

#SBATCH --partition=compute
#SBATCH --time=00:20:00
#SBATCH --array=0-50
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --job-name HCP_gradient_QC
#SBATCH --output=HCP_gradient_QC_%j.txt

SUB_SIZE=16 ## number of subjects to run
CORES=40
export THREADS_PER_COMMAND=2

## set and export the important paths
ciftify_container=/scinet/course/ss2019/3/5_neuroimaging/containers/tigrlab_fmriprep_ciftify_v1.3.2-2.3.3-2019-08-16-d2128c2344d2.img
HCP_S1200_dir=/scratch/a/arisvoin/edickie/HCP_S1200
dense_gradients_dir=/scratch/a/arisvoin/jjee/gradients_dscalar
output_dir=${SCRATCH}/gradients_dscalar_vis/

export ciftify_container
export dense_gradients_dir
export HCP_S1200_dir
export output_dir

bbtmpdir=$(mktemp --tmpdir=/$BBUFFER -d tmp.XXXXXX)
export bbtmpdir

## set up a trap that will clear the ramdisk if it is not cleared
function cleanup_ramdisk {
    echo -n "Cleaning up ramdisk directory /$SLURM_TMPDIR/ on "
    date
    rm -rf /$SLURM_TMPDIR
    rm -rf ${bbtmpdir}
    echo -n "done at "
    date
}

#trap the termination signal, and call the function 'trap_term' when
# that happens, so results may be saved.
trap "cleanup_ramdisk" TERM


# load the important modules for this (parallel and singularity)
module load gnu-parallel/20180322
module load singularity/3.5.2

## double check that parallel is in the env..
command -v parallel > /dev/null 2>&1 || { echo "GNU parallel not found in job environment. Exiting."; exit 1; }

## get the subject list from the command
bigger_bit=`echo "($SLURM_ARRAY_TASK_ID + 1) * ${SUB_SIZE}" | bc`
subjects=`cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | \
 head -n ${bigger_bit} | tail -n ${SUB_SIZE}`

## write a function that runs the singularity command - to simplify the look the way it is called
run_vis_map() {
### make a tmpdir for this call
tmpdir=$(mktemp --tmpdir=/$SLURM_TMPDIR -d tmp.XXXXXX)
mkdir $tmpdir/home

## do the call to singularity to run the cleaning
subject=$1
day=$2

mkdir -p ${bbtmpdir}/${subject}

## first transpose the file
singularity exec \
-H ${tmpdir}/home \
-B ${bbtmpdir}:/BBUFFER \
-B ${dense_gradients_dir}:/dense_gradients_dir \
${ciftify_container} wb_command -cifti-transpose \
/dense_gradients_dir/day${day}/${subject}_rfMRI_REST${day}_Atlas_hp2000_clean2sm4_gradients.dscalar.nii \
/BBUFFER/${subject}/${subject}_day${day}.dscalar.nii \

for grad_num in "1" "2" "3" "4" "5" "6"; do
## then break out the gradient..
singularity exec \
-H ${tmpdir}/home \
-B ${bbtmpdir}:/BBUFFER \
-B ${dense_gradients_dir}:/dense_gradients_dir \
${ciftify_container} wb_command -cifti-merge \
/BBUFFER/${subject}/${subject}_day${day}_${grad_num}.dscalar.nii \
-cifti /BBUFFER/${subject}/${subject}_day${day}.dscalar.nii \
-column ${grad_num}

## finally run the
singularity exec \
-H ${tmpdir}/home \
-B ${bbtmpdir}:/BBUFFER \
-B ${output_dir}:/output \
-B ${HCP_S1200_dir}:/hcp_data \
${ciftify_container} cifti_vis_map cifti-subject \
    --ciftify-work-dir /hcp_data \
    --qcdir /output/qc_gradient${grad_num} \
    /BBUFFER/${subject}/${subject}_day${day}_${grad_num}.dscalar.nii \
    ${subject} \
    gradient${grad_num}_day${day}
done
## delete the tmpdir when we are done
rm -rf $tmpdir
}

export -f run_vis_map

parallel -j${CORES} --tag --line-buffer --compress \
 "run_vis_map {1} {2}" \
    ::: ${subjects} \
    ::: "1" "2"

## making the final index page
tmpdir=$(mktemp --tmpdir=/$SLURM_TMPDIR -d tmp.XXXXXX)
mkdir $tmpdir/home

## do the call to singularity to run the cleaning
for grad_num in "1" "2" "3" "4" "5" "6"; do
singularity exec \
-H ${tmpdir}/home \
-B ${output_dir}:/output \
-B ${HCP_S1200_dir}:/hcp_data \
${ciftify_container} cifti_vis_map index \
    --ciftify-work-dir /hcp_data \
    --qcdir /output/qc_gradient${grad_num}
done
## delete the tmpdir when we are done
rm -rf $tmpdir
