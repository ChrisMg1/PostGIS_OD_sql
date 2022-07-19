# -*- coding: utf-8 -*-
"""
Created on Sun Jun  5 13:59:16 2022

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

font = {'family' : 'normal',
        'weight' : 'normal',
        'size'   : 18}

plt.rc('font', **font)

in_file = 'C:/temp/cm_metric.csv'

num_bins = 20

for_hist = pd.read_csv(in_file)



bin_number = 21


#for_hist.hist(bins = 21)
#for_hist.hist(column=['cm_metric_scen1], bins = bin_number)


print(for_hist['directdist'].max())

counts, bins = np.histogram(for_hist['cm_metric_scen1'], bins = bin_number)

#plot = np.histogram(for_hist['cm_metric'])

print ('Counts: ', counts)


print ('Bins: ', bins)

#print('Plot:', plot[0])

## Plot simple histos from all cols including total ("cm_metric")

## Demand impedance
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Demand Impedance')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['demand_weight'], edgecolor='darkgrey', bins = bin_number)
plt.savefig('plots/demand_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Distance impedance
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Distance Impedance')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['distance_weight'], edgecolor='darkgrey', bins = bin_number)
plt.savefig('plots/distance_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Distance impedance
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Travel Time Impedance')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['ttime_weight'], edgecolor='darkgrey', bins = bin_number)
plt.savefig('plots/ttime_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Total impedance (watch out for weighting/parameters)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Metric Value')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['cm_metric_scen1'], color = 'orange', edgecolor='darkgrey', bins = bin_number)
plt.savefig('plots/TOTAL_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Checks: Distance
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Distance')
plt.ylabel('Frequency')

plt.hist(for_hist['directdist'], edgecolor='darkgrey')
#plt.savefig('plots/directdist_hist.png', bbox_inches='tight')
#plt.show()
plt.clf()


print(len(for_hist))