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

print(len(for_hist))

## Generate some statistics
print('stats')
print(for_hist.loc[for_hist["cm_metric_scen1"] >= 0.0, "cm_metric_scen1"].mean())
print(for_hist.loc[for_hist["cm_metric_scen1"] >= 0.4, "cm_metric_scen1"].mean())
print(for_hist.loc[for_hist["cm_metric_scen1"] >= 0.6, "cm_metric_scen1"].mean())
print(for_hist.loc[for_hist["cm_metric_scen1"] >= 0.8, "cm_metric_scen1"].mean())

print(len(for_hist.loc[for_hist["cm_metric_scen1"] >= 0.8, "cm_metric_scen1"]))


print(for_hist.loc[for_hist["cm_metric_scen2"] >= 0.0, "cm_metric_scen2"].mean())
print(for_hist.loc[for_hist["cm_metric_scen2"] >= 0.4, "cm_metric_scen2"].mean())
print(for_hist.loc[for_hist["cm_metric_scen2"] >= 0.6, "cm_metric_scen2"].mean())
print(for_hist.loc[for_hist["cm_metric_scen2"] >= 0.8, "cm_metric_scen2"].mean())

print(len(for_hist.loc[for_hist["cm_metric_scen2"] >= 0.6, "cm_metric_scen2"]))


print(for_hist.loc[for_hist["cm_metric_scen3"] >= 0.0, "cm_metric_scen3"].mean())
print(for_hist.loc[for_hist["cm_metric_scen3"] >= 0.4, "cm_metric_scen3"].mean())
print(for_hist.loc[for_hist["cm_metric_scen3"] >= 0.6, "cm_metric_scen3"].mean())
print(for_hist.loc[for_hist["cm_metric_scen3"] >= 0.8, "cm_metric_scen3"].mean())

print(len(for_hist.loc[for_hist["cm_metric_scen3"] >= 0.8, "cm_metric_scen3"]))


## Print span of each metric
print('\nspan')
print(min(for_hist['cm_metric_scen1']), max(for_hist['cm_metric_scen1']))
print(min(for_hist['cm_metric_scen2']), max(for_hist['cm_metric_scen2']))
print(min(for_hist['cm_metric_scen3']), max(for_hist['cm_metric_scen3']))

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

## Total impedance Scenario 1 (watch out for weighting/parameters)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Total Impedance (Scenario 1)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['total_impedance1'], color = 'orange', edgecolor='darkgrey', bins = bin_number)
#plt.savefig('plots/TOTAL_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Metric / Utility Scenario 1
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Metric (Scenario 1)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['cm_metric_scen1'], color = 'orange', edgecolor='darkgrey', bins = bin_number, label=r'$\mathcal{M}_u$')
plt.legend()
plt.savefig('plots/metricUtil_s1.png', bbox_inches='tight')
plt.show()
plt.clf()


## Total impedance Scenario 2 (watch out for weighting/parameters)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Total Impedance (Scenario 2)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['total_impedance2'], color = 'orange', edgecolor='darkgrey', bins = bin_number)
#plt.savefig('plots/TOTAL_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Metric / Utility Scenario 2
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Metric (Scenario 2)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['cm_metric_scen2'], color = 'orange', edgecolor='darkgrey', bins = bin_number, label=r'$\mathcal{M}_u$')
plt.legend()
plt.savefig('plots/metricUtil_s2.png', bbox_inches='tight')
plt.show()
plt.clf()


## Total impedance Scenario 3 (watch out for weighting/parameters)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Total Impedance (Scenario 3)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['total_impedance3'], color = 'orange', edgecolor='darkgrey', bins = bin_number)
#plt.savefig('plots/TOTAL_weight_hist.png', bbox_inches='tight')
plt.show()
plt.clf()

## Metric / Utility Scenario 3
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Metric (Scenario 3)')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['cm_metric_scen3'], color = 'orange', edgecolor='darkgrey', bins = bin_number, label=r'$\mathcal{M}_u$')
plt.legend()
plt.savefig('plots/metricUtil_s3.png', bbox_inches='tight')
plt.show()
plt.clf()

## Checks: Distance
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('OD Distance')
plt.ylabel('Frequency (n=861,497)')

plt.hist(for_hist['directdist'], edgecolor='darkgrey', bins = bin_number)
#plt.savefig('plots/directdist_hist.png', bbox_inches='tight')
#plt.show()
plt.clf()


