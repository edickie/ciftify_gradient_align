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
        wb_command -cifti-separate \
        $1"/"$subject_no"/"$day1 \
        COLUMN \
        -metric CORTEX_LEFT $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L.func.gii" \
        -roi $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
        -metric CORTEX_RIGHT $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R.func.gii" \
        -roi $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4_R_roi.func.gii"
        
        # day 2
        wb_command -cifti-separate \
        $1"/"$subject_no"/"$day2 \
        COLUMN \
        -metric CORTEX_LEFT $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L.func.gii" \
        -roi $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_L_roi.func.gii" \
        -metric CORTEX_RIGHT $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R.func.gii" \
        -roi $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4_R_roi.func.gii"

    done