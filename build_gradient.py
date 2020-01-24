import h5py
import brainspace
import pickle
from brainspace.gradient import GradientMaps
import os
import numpy as np

def build_gradient(dconn_file):
    
    # format name for gradient file
    grad_name = os.path.basename(dconn_file)
    grad_name = grad_name.replace(".dconn.hdf5", "_gradient.txt")
    grad_name = os.path.join("data/gradients", grad_name)
    
    # load dconn.hdf5 file
    dconn_file = h5py.File(dconn_file, "r")
    dconn = dconn_file["dconn"]
    gm = GradientMaps(n_components=10, random_state=0)
    gm.fit(dconn)
    
    # save as textfile
    np.savetxt(grad_name, gm.gradients_)
    
    dconn_file.close()