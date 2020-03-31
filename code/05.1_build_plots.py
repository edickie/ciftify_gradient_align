#!/usr/bin/env python
# coding: utf-8

# In[14]:


import numpy as np
import os
import pandas as pd
import math
import seaborn as sns


# In[29]:


analysis_dir = "/Users/Joelle/Anaconda3/envs/BCB430/Gradients/data/analysis"
corr_files = os.listdir(analysis_dir)
pro_sub_fg = []
mean_all_grad = []
std_all_grad = []
within_sd_all_grad = []


# In[30]:


fingerprint = 0
for g in range(1, 11):
    # search for the specific gradient
    grad = [fname for fname in corr_files if "grad" + str(g) in fname][0]
    
    grad = np.loadtxt(os.path.join(analysis_dir, grad))
    grad = np.nan_to_num(grad)
    grad = np.arctanh(grad)
    
    num_subs = grad.shape[0]
    mean_grad = []
    std_grad = []
    within_sd_grad = []
    
    # update fingerprint if x[i, i] is the row max
    for i in range(num_subs):
        if i == np.argmax(grad[i, :]):
            fingerprint = fingerprint + 1
        
        # compute std for each row between subject analysis
        bet_row = np.delete(grad[i, :], i, 0)
        bet_mean = np.sum(bet_row) / num_subs
        std_row = np.std(bet_row)
        
        # compute the sd of within subject to between subject value
        within_sd = abs(grad[i, i] - bet_mean) / std_row
        
        # append to lists for the whole gradient
        if bet_mean != 0:
            mean_grad.append(bet_mean)
        if std_row != 0:
            std_grad.append(std_row)
        if within_sd != 0:
            within_sd_grad.append(within_sd)
        
        
    
    pro_sub_fg.append(fingerprint/num_subs)
    mean_all_grad.append(mean_grad)
    std_all_grad.append(std_grad)
    within_sd_all_grad.append(within_sd_grad)
    
    # reset fingerprint value
    fingerprint = 0


# In[35]:


import matplotlib.pyplot as plt


# In[96]:


plt.figure()

# plot gradients
for i in range(6):
    plt.subplot(320 + i + 1)
    sns.kdeplot(std_all_grad[i])
    plt.title("Gradient " + str(i + 1))
    plt.grid(True)

plt.subplots_adjust(top=0.92, bottom=0.2, 
                    left=0.10, right=0.95, 
                    hspace=0.75, wspace=0.30)

plt.suptitle("The Density Distribution of the" +
         " Standard Deviance \n in " +
         "Between-Subject Analyses",
            y = 1.15)
plt.text(-0.005, -50, 'Standard Deviance', ha='center')
plt.text(-0.061, 160, 'Number of Analyses', va='center', rotation='vertical')

plt.savefig("SD_between_sub.png", bbox_inches='tight')


# In[116]:


plt.figure()

# plot gradients
for i in range(6):
    plt.subplot(320 + i + 1)
    sns.kdeplot(within_sd_all_grad[i])
    plt.title("Gradient " + str(i + 1))
    plt.grid(True)

plt.subplots_adjust(top=0.92, bottom=0.2, 
                    left=0.10, right=0.95, 
                    hspace=0.75, wspace=0.30)

plt.suptitle("The Density Distribution of" +
         " Standard Deviance of \nWithin-Subject Analysis to the " +
         "Between-Subject Analyses",
            y = 1.15)
plt.text(-0.06, -12, 'Standard Deviance', ha='center')
plt.text(-0.35, 32, 'Number of Analyses', va='center', rotation='vertical')

plt.savefig("SD_within_to_between_sub.png", bbox_inches='tight')

