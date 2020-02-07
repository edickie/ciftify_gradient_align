#!/bin/sh
for subject in "$1"/*
    # dir is the subject folder
    do
        day1=$(ls "$subject" | grep "REST1")
        day2=$(ls "$subject" | grep "REST2")
        
        subject_no=$(basename $subject)
        echo "$subject_no"
        
        # make directory for the subject in the separated folder
        mkdir -p $2"/"$subject_no
        
        # day 1
        wb_command -cifti-correlation \
        $1"/"$subject_no"/"$day1 \
        $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dconn.nii"
        
        # day 2
        wb_command -cifti-correlation \
        $1"/"$subject_no"/"$day2 \
        $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dconn.nii"
        
    done