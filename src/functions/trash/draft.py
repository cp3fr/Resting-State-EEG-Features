import os, sys, re, csv, matplotlib
import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# %matplotlib inline

ROOTPATH = '/Volumes/methlab/HBN_RestingEEG_Features/results/csv/'
INPATH = ROOTPATH + 'features_psd_average/row_%d.csv'
OUTPATH = ROOTPATH + 'test.csv'

#row_1.csv (has header)
#row_2.csv and following (no header)
filenames = [INPATH % row for row in range(2,6)]
print(filenames)

# df = pd.concat([pd.read_csv(f) for f in filenames ])


# print(df)

# df = pd.read_csv(filenames[0])

# df.to_csv(OUTPATH, index=False, encoding='utf-8-sig')