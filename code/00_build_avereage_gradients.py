from brainspace.gradient import GradientMaps
import os
import numpy as np
from docopt import docopt
from glob import glob
from threading import Thread
import nibabel as nib


# In[2]:


dconn = nib.load("average.dconn.nii")
dconn.shape


# In[ ]:


gm = GradientMaps(n_components=10, random_state=0)
gm.fit(dconn.get_data())


# In[ ]:


np.savetxt("average_gradient.txt", gm.gradients_)
