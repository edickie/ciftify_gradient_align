import os
import numpy as np
from ciftify import niio

corr_day1_all_grad = []
corr_day2_all_grad = []

for grad_no in range(1, 11):
    avrg_grad = "/scratch/a/arisvoin/jjee/average_gradients.dscalar.nii"
    avrg_grad = niio.load_concat_cifti_surfaces(avrg_grad)[:, grad_no - 1]

    subs_day1 = "/scratch/a/arisvoin/jjee/gradients_merged/day1/all_subs_REST1_grad_" + str(grad_no) + ".txt"
    subs_day2 = "/scratch/a/arisvoin/jjee/gradients_merged/day2/all_subs_REST2_grad_" + str(grad_no) + ".txt"
    
    subs_day1 = np.loadtxt(subs_day1)
    subs_day2 = np.loadtxt(subs_day2)
    
    num_subs = subs_day1.shape[1]

    corr_day1 = []
    corr_day2 = []

    for s in range(num_subs):
        corr_day1.append(np.corrcoef(avrg_grad, subs_day1[:, s], rowvar = False)[0, 1])
        corr_day2.append(np.corrcoef(avrg_grad, subs_day2[:, s], rowvar = False)[0, 1])

        
    corr_day1_all_grad.append(corr_day1)
    corr_day2_all_grad.append(corr_day2)

corr_day1_all_grad = np.asarray(corr_day1_all_grad)
corr_day2_all_grad = np.asarray(corr_day2_all_grad)

avrg_corr_dir = "/scratch/a/arisvoin/jjee/analysis/average"
if not os.path.exists(avrg_corr_dir):
    os.makedirs(avrg_corr_dir)

np.savetxt(os.path.join(avrg_corr_dir, "day1_corr.txt"), corr_day1_all_grad)
np.savetxt(os.path.join(avrg_corr_dir, "day2_corr.txt"), corr_day2_all_grad)



