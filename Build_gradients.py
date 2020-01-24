from build_gradient import build_gradient
import os
from threading import Thread
import glob

dconn_files = glob.glob("data/dconn.hdf5/*.hdf5")

for dconn in dconn_files:
    t = Thread(target=build_gradient, args=(dconn,))
    t.start()
    
# build_gradient("sub-50005_task-rest_Atlas_s0.dconn.hdf5")

