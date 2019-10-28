#!/usr/bin/env python
# coding: utf-8

# In[39]:


#HBN_RESTINGEEG_FEATURES
#
#script to concatenate intermediate row_1.csv files to feature.csv file
#uses pandas (quite slow), should be faster when using csv.read etc
#
#christian.pfeiffer@uzh.ch
#28.10.2019


import os, sys, re, csv, matplotlib
import pandas as pd

feature_name = 'features_psd_channel'
ROOTPATH = '/Volumes/methlab/HBN_RestingEEG_Features/results/csv/'
INPATH = ROOTPATH + feature_name + '/row_%d.csv'
OUTPATH = ROOTPATH + feature_name + '.csv'
nrows =  1485

#First row (has header)
PATH = INPATH % 1
print('..loading {}'.format(PATH))
alldata = pd.read_csv(PATH)

#Remaining rows (no header)
FILEPATHS = [INPATH % row for row in range(2,nrows)]
for f in FILEPATHS:
    print('..loading {}'.format(f))
    df = pd.read_csv(f, header=None, sep=',')
    df.columns = alldata.columns
    alldata = pd.concat([alldata, df], ignore_index=True)
    
#Save output
alldata.to_csv(OUTPATH, index=False)


# In[ ]:




