"""
Runs brainspace to build dense gradients from a cifti dense connectome.

Usage: 
  build_gradients.py <dconn_directory>

Arguments:
  <dconn_directory>   Path to directory that contains dconn file.

"""

import h5py
import pickle
from brainspace.gradient import GradientMaps
import os
import numpy as np
from docopt import docopt
from glob import glob
from threading import Thread
import nibabel as nib



# def flip_and_reorder():

def build_gradients(sub_file):
    
    # load the dconn file and compute gradients
    dconn = nib.load(sub_file)
    gm = GradientMaps(n_components=10, random_state=0)
    gm.fit(dconn.get_data())
    
#     gm.gradients_ = flip_and_reorder(gm.gradients_)
    
    return gm.gradients_
    
def align_to_average(sub_grad, average_grad):
    # create a GradientMaps object to store the aligned gradients
    aligned = GradientMaps(kernel = "normalized_angle",
                           alignment = "joint")
    aligned.fit([average_grad, sub_grad])
    
    return aligned.gradients_
    

def build_and_align(sub_file, average_grad, sub_no):
    
    # format name for gradient file
    grad_name = os.path.basename(sub_file)
    grad_name = grad_name.replace(".dconn.nii", "_gradients.txt")
    grad_name = os.path.join("/scratch/a/arisvoin/jjee/gradients_txt", 
                             sub_no,
                             grad_name)
    
    # first build subject's gradients
    sub_grad = build_gradients(sub_file)
    
    # save as textfile
    np.savetxt(grad_name, sub_grad)
    
    # format appropriate filename for aligned gradients
    aligned_name = grad_name.replace("_gradients.txt",
                                     "_gradients_aligned.txt")
    
    # align the subject's gradients to the average gradients
    aligned_grad = align_to_average(sub_grad, average_grad)
    
    # write the aligned gradients as a text file
    np.savetxt(aligned_name, aligned_grad)
    
    
if __name__== '__main__':
    dconn_dir = docopt(__doc__)["<dconn_directory>"]
    dconn_files = glob(os.path.join(dconn_dir, "*.dconn.nii"))
    
    # get subject number
    sub_no = os.path.basename(os.path.normpath(dconn_dir))
    
    # read pre-coputed average gradients
    average = "/scratch/a/arisvoin/jjee/gradients_txt/average/average_gradients.txt"
    average = np.loadtxt(average)
    
    # create subject subdirectories to store gradients
    sub_grad_dir = os.path.join("/scratch/a/arisvoin/jjee/gradients_txt/", sub_no)
    if not os.path.exists(sub_grad_dir):
        os.makedirs(sub_grad_dir)

    for dconn in dconn_files:
        t = Thread(target=build_and_align, args=(dconn, average, sub_no))
        t.start()
    
