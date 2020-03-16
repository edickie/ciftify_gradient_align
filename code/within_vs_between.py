
# coding: utf-8

# In[3]:


import numpy as np
import os


# In[4]:


merged_grad_dir = "/scratch/a/arisvoin/jjee/gradients_merged"
day1_dir = os.path.join(merged_grad_dir, "day1")
day2_dir = os.path.join(merged_grad_dir, "day2")

day1 = os.listdir(day1_dir)
day2 = os.listdir(day2_dir)


# In[7]:


corr = []

for i in range(10):
    day1_grad = np.loadtxt(os.path.join(day1_dir, day1[i]))
    day2_grad = np.loadtxt(os.path.join(day2_dir, day2[i]))
    
    # correlation
    result = np.corrcoef(day1_grad, day2_grad)
    # r to z transformation
    result = np.arctanh(result)
    
    # create directory for analysis
    analysis_dir = "/scratch/a/arisvoin/jjee/analysis"
    if not os.path.exists(analysis_dir):
        os.makedirs(analysis_dir)
    
    # save as txt
    np.savetxt(analysis_dir, "within_vs_between_grad" + 
               str(i + 1) + ".txt", result)
    
    

