# -*- coding: utf-8 -*-
"""
Created on Tue Apr  2 22:43:08 2024

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


font = {'family' : 'normal',
        'weight' : 'normal',
        'size'   : 18}

plt.rc('font', **font)


in_file = 'C:/TUMdissDATA/demandWITHbavariaFLAG.csv'

num_bins = 20

for_hist = pd.read_csv(in_file)

bin_number = 21


#for_hist.hist(bins = 21)
#for_hist.hist(column=['cm_metric_scen1], bins = bin_number)


print(for_hist['demand_all_person'].max())

counts, bins = np.histogram(for_hist['demand_all_person'], bins = bin_number)

## Total demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Total demand')
plt.ylabel('Frequency (n=)')

plt.hist(for_hist['demand_all_person'], edgecolor='darkgrey', bins = bin_number)
# plt.savefig('C:/Users/chris/plots/demand_weight_hist.png', bbox_inches='tight')
plt.savefig('C:/Users/chris/plots/demand_person_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## Bavaria demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Bavaria demand')
plt.ylabel('Frequency (n=)')

plt.hist(for_hist['demand_all_person'], edgecolor='darkgrey', bins = bin_number)
# plt.savefig('C:/Users/chris/plots/distance_weight_hist.png', bbox_inches='tight')
plt.savefig('C:/Users/chris/plots/demand_person_BAV.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()