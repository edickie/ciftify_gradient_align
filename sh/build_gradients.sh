#!/bin/sh

source ~/.virtualenvs/gradients/bin/activate

for subject in "$1"/*
    # subject is the subject folder
    do 
        python build_gradients.py $subject
    done
    
deactivate
