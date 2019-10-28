#!/usr/bin/env python
# coding: utf-8

# In[4]:


#HBN_RESTINGEEG_FEATURES
#
#script to concatenate intermediate row_1.csv files to feature.csv file
#
#christian.pfeiffer@uzh.ch
#28.10.2019


import os, sys, re, csv, matplotlib
import pandas as pd


ROOTPATH = '/Volumes/methlab/HBN_RestingEEG_Features/results/csv/'
#levels = ['average','cluster','channel']
levels = ['cluster']
nrows =  1485

for level in levels:
    feature_name = 'features_psd_' + level
    
    INPATH = ROOTPATH + feature_name + '/row_%d.csv'
    OUTPATH = ROOTPATH + feature_name + '.csv'
    
    outfile = open(OUTPATH, 'w')

    with outfile:

        outfile_writer = csv.writer(outfile)

        #add one to rows to also get the last file
        for row in range(1,nrows+1):

            print('File {}/{}'.format(row,nrows))

            infile = open(INPATH % row, 'r')
            with infile:

                infile_reader = csv.reader(infile)

                for line in infile_reader:
                    outfile_writer.writerow(line)






# In[ ]:




