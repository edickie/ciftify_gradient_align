"""
Usage: 
  within_vs_between.py <day1_start> <day1_end> <day2_start> <day2_end> <merged_grad_dir> <gradient_number>
  
Arguments:
  <day1_start>        Starting subject
  <day1_end>          Ending subject
  <day2_start>        Starting subject
  <day2_end>          Ending subject
  <merged_grad_dir>   Path to directory that contains dconn file.
  <gradient_number>   The gradient number

"""

from docopt import docopt
import numpy as np
import os
from threading import Thread




def within_vs_between(day1_start, day1_end, 
                      day2_start, day2_end,
                      day1, day2, grad_no):    
    # get the first day gradients by subs
    day1_grad = np.loadtxt(day1)
    day2_grad = np.loadtxt(day2)
    size = int(day1_end) - int(day1_start)
    
    result = np.empty([size, size])
    r1 = 0
    r2 = 0
    # compute correlation
    for i in range(int(day1_start),int(day1_end)):
        for j in range(int(day2_start),int(day2_end)):
            corr = np.corrcoef(day1_grad[:, i], day2_grad[:, j], rowvar = False)[0, 1]
            result[r1, r2] = corr
            
            r2 = r2 + 1
        
        r1 = r1 + 1
        r2 = 0
            
            
    # r to z transformation
    # result = np.arctanh(result)
    
    # create directory for analysis
    analysis_dir = "/scratch/a/arisvoin/jjee/analysis/by_subs"
    if not os.path.exists(analysis_dir):
        os.makedirs(analysis_dir)
    
    # save as txt
    np.savetxt(os.path.join(analysis_dir, "within_vs_between_grad" + 
                                         str(grad_no) + "_day1_sub" + day1_start +
                                         "_to_sub" + day1_end +
                                         "_day2_sub" + day2_start +
                                         "_to_sub" + day2_end +
                                         ".txt")
               , result)

    

if __name__== '__main__':
    
    grad_no = docopt(__doc__)["<gradient_number>"]
    merged_grad_dir = docopt(__doc__)["<merged_grad_dir>"]
    day1_start = docopt(__doc__)["<day1_start>"]
    day1_end = docopt(__doc__)["<day1_end>"]
    day2_start = docopt(__doc__)["<day2_start>"]
    day2_end = docopt(__doc__)["<day2_end>"]
    
    day1_dir = os.path.join(merged_grad_dir, "day1")
    day2_dir = os.path.join(merged_grad_dir, "day2")
    
    grad_str = "grad_" + str(grad_no)

    day1 = [os.path.join(day1_dir, grad) 
            for grad in os.listdir(day1_dir) if grad_str in grad][0]
    day2 = [os.path.join(day2_dir, grad) 
            for grad in os.listdir(day2_dir) if grad_str in grad][0]

    within_vs_between(day1_start, day1_end, 
                      day2_start, day2_end, 
                      day1, day2, grad_no)