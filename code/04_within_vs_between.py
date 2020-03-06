
# coding: utf-8

# In[2]:


import numpy as np
import nibabel as nib
import os


# In[ ]:


day1 = os.listdir("/scratch/a/arisvoin/jjee/gradients_dscalar/day1/all")
day2 = os.listdir("/scratch/a/arisvoin/jjee/gradients_dscalar/day2/all")


# In[ ]:


corr = []

for i in range(10):
    day1_grad = day1[i]
    day2_grad = day2[i]
    
    day1_grad_matrix = nib.load(day1_grad)
    day2_grad_matrix = nib.load(day2_grad)
    
    # correlation
    result = np.corrcoef(day1_grad_matrix, day2_grad_matrix)
    
    np.savetxt("/scratch/a/arisvoin/jjee/analysis/within_vs_between_grad" + 
               str(i), result)

