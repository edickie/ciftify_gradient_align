#!/bin/sh
for dir in "$1"/*
    # dir is the subject folder
    do
        # day 1
        left1=$(ls "$dir" | grep "REST1_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
        right1=$(ls "$dir" |grep "REST1_RL_Atlas_hp2000_clean2sm4.dtseries.nii")
        # day 2
        left2=$(ls "$dir" | grep "REST2_LR_Atlas_hp2000_clean2sm4.dtseries.nii")
        right2=$(ls "$dir" |grep "REST2_RL_Atlas_hp2000_clean2sm4.dtseries.nii")
        
        subject_no=$(basename $dir)
        
        # make directory for the subject in the merged folder
        mkdir -p $2"/"$subject_no
        
        wb_command -cifti-merge $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dtseries.nii"\
         -cifti "$dir/$left1" -cifti "$dir/$right1"

        wb_command -cifti-merge $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dtseries.nii"\
         -cifti "$dir/$left2" -cifti "$dir/$right2"
    
    done