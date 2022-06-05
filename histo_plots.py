# -*- coding: utf-8 -*-
"""
Created on Sun Jun  5 13:59:16 2022

@author: chris
"""

import pandas as pd


in_file = 'C:/temp/cm_metric.csv'

for_hist = pd.read_csv(in_file)

print(for_hist)


for_hist.hist(bins = 100)
for_hist.hist(column=['cm_metric'], bins = 100)