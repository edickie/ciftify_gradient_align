#!/bin/sh
for subject in "$1"/*
    # dir is the subject folder
    do
        # day 1
        left_d1=$(ls "$subject" | grep "REST1.*_L.func")
        left_d1_roi=$(ls "$subject" | grep "REST1.*_L_roi")
        right_d1=$(ls "$subject" | grep "REST1.*_R.func")
        right_d1_roi=$(ls "$subject" | grep "REST1.*_R_roi")
        
        # day 2
        left_d2=$(ls "$subject" | grep "REST2.*_L.func")
        left_d2_roi=$(ls "$subject" | grep "REST2.*_L_roi")
        right_d2=$(ls "$subject" | grep "REST2.*_R.func")
        right_d2_roi=$(ls "$subject" | grep "REST2.*_R_roi")
        
        subject_no=$(basename $subject)
        
        # make directory for the subject in the separated folder
        mkdir -p $2"/"$subject_no
        
        # day 1
        wb_command -cifti-create-dense-scalar \
        $2"/"$subject_no"/"$subject_no"_rfMRI_REST1_Atlas_hp2000_clean2sm4.dscalar.nii" \
        -left-metric $1"/"$subject_no"/"$left_d1 \
        -roi-left $1"/"$subject_no"/"$left_d1_roi \
        -right-metric $1"/"$subject_no"/"$right_d1 \
        -roi-right $1"/"$subject_no"/"$right_d1_roi \
        
        # day 2
        wb_command -cifti-create-dense-scalar \
        $2"/"$subject_no"/"$subject_no"_rfMRI_REST2_Atlas_hp2000_clean2sm4.dscalar.nii" \
        -left-metric $1"/"$subject_no"/"$left_d2 \
        -roi-left $1"/"$subject_no"/"$left_d2_roi \
        -right-metric $1"/"$subject_no"/"$right_d2 \
        -roi-right $1"/"$subject_no"/"$right_d2_roi \
    
    done