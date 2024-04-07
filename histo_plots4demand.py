# -*- coding: utf-8 -*-
"""
Created on Tue Apr  2 22:43:08 2024

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
#import numpy as np


#font = {'family' : 'normal',
#        'weight' : 'normal',
#        'size'   : 18}

#plt.rc('font', **font)


in_file = 'C:/TUMdissDATA/demandWITHbavariaFLAG.csv'

for_hist = pd.read_csv(in_file)

bin_number = 31

print(for_hist['demand_all_person'].max())
print(for_hist['demand_all_person'].min())
print(len(for_hist['demand_all_person']))

print(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person'].max())
print(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person'].min())
print(len(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person']))

#counts, bins = np.histogram(for_hist['demand_all_person'], bins = bin_number)


## Total demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand model area')
plt.ylabel('Frequency (n=44,342,281)')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(for_hist['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## Bavaria demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand study area')
plt.ylabel('Frequency (n=23,716,900)')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_BAV.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()
