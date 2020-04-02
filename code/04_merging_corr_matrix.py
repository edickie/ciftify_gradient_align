
import os
import numpy as np

to_merge = os.listdir("/scratch/a/arisvoin/jjee/analysis/by_subs")

for g in range(1, 11):
    # search for the specific gradient
    grad = [fname for fname in to_merge if "grad" + str(g) in fname]
    
    # give names for the 4 quadrandts
    first = [quad for quad in grad if "day1_sub0_to_sub389_day2_sub0_to_sub389" in quad][0]
    second = [quad for quad in grad if "day1_sub0_to_sub389_day2_sub389_to_sub778" in quad][0]
    third = [quad for quad in grad if "day1_sub389_to_sub778_day2_sub389_to_sub778" in quad][0]
    fourth = [quad for quad in grad if "day1_sub389_to_sub778_day2_sub0_to_sub389" in quad][0]
    
    # read them as matrices with numpy
    first = np.loadtxt(os.path.join("/scratch/a/arisvoin/jjee/analysis/by_subs", first))
    second = np.loadtxt(os.path.join("/scratch/a/arisvoin/jjee/analysis/by_subs", second))
    third = np.loadtxt(os.path.join("/scratch/a/arisvoin/jjee/analysis/by_subs", third))
    fourth = np.loadtxt(os.path.join("/scratch/a/arisvoin/jjee/analysis/by_subs", fourth))
    
    # concatenate them
    first_second = np.hstack((first, second))
    print(first_second.shape)
    fourth_third = np.hstack((fourth, third))
    
    all_subs = np.vstack((first_second, fourth_third))
    print(all_subs.shape)
    
    
    result_dir = "/scratch/a/arisvoin/jjee/analysis/by_gradient"
    if not os.path.exists(result_dir):
        os.mkdir(result_dir)
        
    # save as txt file
    np.savetxt(os.path.join(result_dir, "within_vs_between_grad" + str(g) + ".txt"), 
               all_subs)
