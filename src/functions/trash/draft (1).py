#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import os, sys, re, csv, matplotlib
import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# %matplotlib inline

ROOTPATH = '/Volumes/methlab/HBN_RestingEEG_Features/results/csv/'
INPATH = ROOTPATH + 'features_psd_average/row_%d.csv'
OUTPATH = ROOTPATH + 'test.csv'
nrows =  4


#row_1.csv (has header), read separately
FILEPATH = INPATH % 1
first_row = pd.read_csv(FILEPATH)

#row_2.csv and following have no header, load and concatenate
FILEPATHS = [INPATH % row for row in range(2,nrows)]
df = pd.concat([pd.read_csv(f) for f in FILEPATHS ])

#add header to row_2 and following
df.columns = first_row.columns

#concatenate row 1 and the rest
df = pd.concat([first_row, df])

print(df.shape)
print(df.head())

# #save dataframe to csv
# df.to_csv(OUTPATH, index=False, encoding='utf-8-sig')


# In[ ]:




