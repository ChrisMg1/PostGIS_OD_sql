# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 18:15:43 2022

@author: chris
"""



import pandas as pd
import matplotlib.pyplot as plt
#import numpy as np

pd.options.display.width = 0
pd.set_option('display.expand_frame_repr', False)

font = {'family' : 'normal',
        'weight' : 'normal',
        'size'   : 18}

plt.rc('font', **font)

in_file = 'C:/TUMdissDATA/cm_metrics_with_PAXh.csv'


for_hist = pd.read_csv(in_file)

print(for_hist)

# sum values
sum_PAXh_base = for_hist['pax_h_base'].sum()
sum_PAXh_UAM = for_hist['pax_h_uam_all'].sum()

# sort df according to scenario
for_hist_sort = for_hist.sort_values('cm_metric_scen1')

# Make Cumsum of passenger-hours
# note: still all demand (demand_ivoev, iv+oev), no capacity restriction
for_hist_sort['pax_h_base_CUM_S1'] = for_hist_sort['pax_h_base'].cumsum()
for_hist_sort['pax_h_uam_all_CUM_S1'] = for_hist_sort['pax_h_uam_all'].cumsum()

# total passenger-hours in the system
for_hist_sort['pax_h_total_S1'] = sum_PAXh_base - for_hist_sort['pax_h_base_CUM_S1'] + for_hist_sort['pax_h_uam_all_CUM_S1']


print(for_hist_sort)

print(sum_PAXh_base, sum_PAXh_UAM)


#for_hist_sort['int_index'] = range(len(for_hist_sort))
#for_hist_sort.plot(x='int_index', y='pax_h_base_CUM_S1', color='red')
#for_hist_sort.drop('int_index', axis=1, inplace=True)




for_hist_sort.pax_h_total_S1.plot(use_index=False)
for_hist_sort.pax_h_base_CUM_S1.plot(use_index=False)
for_hist_sort.pax_h_uam_all_CUM_S1.plot(use_index=False)

plt.show()
