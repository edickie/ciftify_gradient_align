#!/bin/sh

# qbatch -b slurm -w 00:40:00 qbatch__dtseries_to_gradients.txt -c 8 -j 4

# module load gnu-parallel qbatch/2.1.5
#
# cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | \
#  parallel echo ${HOME}/code/ciftify_gradient_align/code/01_dconn_to_gradients.sh {} |\
#  head -10 | \
#  qbatch -b slurm -w 00:40:00 -N rerun_dconn_raw_grad --env none --header "module load gnu-parallel" -c 1 -j 1 -

module load gnu-parallel qbatch/2.1.5

cat ${HOME}/code/chitah/subject_lists/HCP_unrelated_REST_sample?.txt | \
 parallel echo bash ${HOME}/code/ciftify_gradient_align/code/01_dconn_to_aligned_gradients.sh {} |\
 qbatch -b slurm -w 00:30:00 -N rerun_dconn_proc_grad --env none --header "module load gnu-parallel" -c 1 -j 1 -
