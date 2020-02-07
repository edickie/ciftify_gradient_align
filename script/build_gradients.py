"""
Usage: build_gradients.py <dconn directory>

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

def build_gradients(dconn_file):
    
    # format name for gradient file
    grad_name = os.path.basename(dconn_file)
    grad_name = grad_name.replace(".dconn.nii", "_gradient.txt")
    grad_name = os.path.join("data/gradients", grad_name)
    
    # load dconn.hdf5 file
#     dconn_file = h5py.File(dconn_file, "r")
#     dconn = dconn_file["dconn"]
    dconn_file = nib.load(dconn_file)
    gm = GradientMaps(n_components=10, random_state=0)
    gm.fit(dconn_file.get_data())
    
    # save as textfile
    np.savetxt(grad_name, gm.gradients_)
    
    dconn_file.close()
    
if __name__== '__main__':
    dconn_dir = docopt(__doc__)["dconn directory"]
    dconn_files = glob(os.path.join(dconn_dir, "*.dconn.nii"))

    for dconn in dconn_files:
        t = Thread(target=build_gradients, args=(dconn,))
        t.start()
    