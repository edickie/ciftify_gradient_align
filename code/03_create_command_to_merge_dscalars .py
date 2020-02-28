
# coding: utf-8

# In[1]:


import os


# In[8]:


dscalar_dir = "/scratch/a/arisvoin/jjee/gradients_dscalar"
f = open("wb_commands_merge_dscalars.txt", "w")

f.write("wb_command -cifti-merge all_sub_day1.dscalar.nii \\\n")

i = 1
while i <= 6:
    for dscalar in os.listdir(file.path(dscalar_dir, "day1")):
        f.write("-cifti " + dscalar + "-column" + i + " \\\n")
            
f.write("\n")

i = 1
while i <= 6:
    for dscalar in os.listdir(file.path(dscalar_dir, "day2")):
        f.write("-cifti " + dscalar+ "-column" + i + " \\\n")


f.close()

