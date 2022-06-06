# -*- coding: utf-8 -*-
"""
Created on Sun Jun  5 13:59:16 2022

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np



in_file = 'C:/temp/cm_metric.csv'

for_hist = pd.read_csv(in_file)

bin_number = 21


#for_hist.hist(bins = 21)
for_hist.hist(column=['cm_metric'], bins = bin_number)


print(for_hist['cm_metric'])

counts, bins = np.histogram(for_hist['cm_metric'], bins = bin_number)

plot = np.histogram(for_hist['cm_metric'])

print ('Counts: ', counts)


print ('Bins: ', bins)

print('Plot:', plot[0])
