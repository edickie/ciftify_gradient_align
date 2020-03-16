"""

Usage:
    merge_gradient_by_day.py <grad_no> <day> <grad_dir> <merged_dir>

Arguments:
    <grad_no>     Gradient number
    <day>         Day 
    <grad_dir>    Directory of all subjects' gradients
    <merged_dir>  directory for merged gradients


"""


import os
import numpy as np
from docopt import docopt

def merge(day, grad_no, all_sub_grad, grad_dir, all_subs, merged_dir):
    
    for sub in all_subs:
        sub_dir = os.path.join(grad_dir, sub)
        
        sub_grad = sub + "_rfMRI_REST" + str(day) + "_Atlas_hp2000_clean2sm4_gradients.txt"
        sub_grad = os.path.join(sub_dir, sub_grad)

        sub_grad = np.loadtxt(sub_grad)[:, grad_no]
        
        all_sub_grad = np.column_stack((all_sub_grad, sub_grad))
    
    np.savetxt(os.path.join(merged_dir, 
                            "all_subs_REST" + str(day) + "_grad_" + str(grad_no) + ".txt")
               , all_sub_grad)

    
if __name__== '__main__':
    grad_no = docopt(__doc__)["<grad_no>"]
    grad_no = int(grad_no) - 1
    grad_dir = docopt(__doc__)["<grad_dir>"]
    day = docopt(__doc__)["<day>"]
    merged_dir = docopt(__doc__)["<merged_dir>"]
    
    # create a list of all subjects
    all_subs = []
    for sub in os.listdir(grad_dir):
        sub_path = os.path.join(grad_dir, sub)
        # check if sub is a folder that's not the average and 
        # if both day1 and day2 are stored in the sub dir
        if os.path.isdir(sub_path) and len(os.listdir(sub_path)) == 2 and sub != "average":
            all_subs.append(sub)
    
    first_sub = all_subs[0]
    first_sub_dir = os.path.join(grad_dir, first_sub)

    all_sub_grad = first_sub + "_rfMRI_REST" + str(day) + "_Atlas_hp2000_clean2sm4_gradients.txt"
    all_sub_grad = os.path.join(first_sub_dir, all_sub_grad)

    all_sub_grad = np.loadtxt(all_sub_grad)[:, grad_no]
    
    # create directories to store merged gradients    
    if not os.path.exists(merged_dir):
        os.makedirs(merged_dir)
    
    # call merge
    merge(day, grad_no,all_sub_grad, grad_dir, all_subs[1:], merged_dir)