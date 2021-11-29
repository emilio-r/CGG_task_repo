#!/usr/bin/env python3

#Script written nov 2021 for use during CGG-problem.
#Use: python3 P_sample_parser.py -s {samples.txt} 

import argparse
from datetime import date
from sys import argv, exit

#Add user input flags
def parse_args():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("-s", "--samples", required=True, help="Path to samples.txt")
   
  if len(argv) < 2: # check if user had arguments
      parser.print_help() # if not, print help
      exit(1) # And exit
  
  args = parser.parse_args()
  return args

def parse_samples(samp):
  sample_dict = {} # define empty dict
  #Open file and fill dictionary
  with open(samp, 'r') as f: # open the file into memory

    header = f.readline().split(",") # extract the header
    ncol = len(header) # count how long the header is
    
    if ncol == 6: # Check if input looks OK (is header as long as it should?)
      for line in f: # read line-by-line
        sample_id = line.split(",")[0].split("-")[0] # pull out sample id by splitting on , and -
        if sample_id not in sample_dict: # if sample is not yet added
          sample_dict[sample_id] = [line.rstrip().split(",")[-1]] # add it and its value
        else:
          sample_dict[sample_id].append(line.rstrip().split(",")[-1]) # append the existing
    else: # If input is not OK, notify user
      print("Inputfile",samp,"does not appear to be formated correctly")
      exit(1) # and exit

  #Close the file and count number of false and lenght of dict, per ID
  n_false, p = (0, 0) # define variables   
      
  for k in sample_dict: # loop over all keys
    n_false = sample_dict[k].count("FALSE") # count number of "false" occuring in the list
    n_tot = n_false + sample_dict[k].count("TRUE") # total number of samples from F+T
    if n_false > 0: # if the number of false are more than zero
      p = (n_false/n_tot) # get a quota
      if p >= 0.10: # If it is above 10%
        print("Warning: origin",k,"has over 10% failed samples!")
      else:
        print("Origin",k,"is OK")
    else: # If no failed, report this.
      print("Origin",k, "is OK. All samples passed")

#Use the arguments and print date
if __name__ == "__main__":

    today = str(date.today())
    print("\nRunning sample_parser on",today,"\n")

    args = parse_args()
    samp = parse_samples(args.samples)
    
