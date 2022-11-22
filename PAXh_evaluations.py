# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 18:15:43 2022

@author: chris
"""



import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
#import numpy as np

# pd.options.display.width = 0
pd.set_option('display.expand_frame_repr', False)

font = {'family' : 'normal',
        'weight' : 'normal',
        'size'   : 18}

plt.rc('font', **font)

in_file = 'C:/TUMdissDATA/cm_metrics_with_PAXh.csv'


for_hist = pd.read_csv(in_file)

print(for_hist)

def ret_cumsum(scenario):
    # sum values
    sum_PAXh_base = for_hist['pax_h_base'].sum()
    #sum_PAXh_UAM = for_hist['pax_h_uam_all'].sum()
    
    # sort df according to metric values of input scenario
    for_hist_sort = for_hist.sort_values(scenario)
    
    # Make Cumsum of passenger-hours
    # note: still all demand (demand_ivoev, iv+oev), no capacity restriction
    for_hist_sort['pax_h_base_CUM_SCENARIO'] = for_hist_sort['pax_h_base'].cumsum()
    for_hist_sort['pax_h_uam_all_CUM_SCENARIO'] = for_hist_sort['pax_h_uam_all'].cumsum()
    
    # total passenger-hours in the system
    for_hist_sort['pax_h_total_SCENARIO'] = sum_PAXh_base - for_hist_sort['pax_h_base_CUM_SCENARIO'] + for_hist_sort['pax_h_uam_all_CUM_SCENARIO']
    
    return for_hist_sort['pax_h_total_SCENARIO'].copy()



pax_h_total_S1 = ret_cumsum('cm_metric_scen1').reset_index(drop=True)
pax_h_total_S2 = ret_cumsum('cm_metric_scen2').reset_index(drop=True)
pax_h_total_S3 = ret_cumsum('cm_metric_scen3').reset_index(drop=True)



plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

# Optional: Set x-axis as percentage values
plt.gca().xaxis.set_major_formatter(mtick.PercentFormatter(xmax=len(pax_h_total_S1)))

plt.plot(pax_h_total_S1, label='metric 1')
plt.plot(pax_h_total_S2, label='metric 2')
plt.plot(pax_h_total_S3, label='metric 3')

plt.xlabel('UAM conn ercentage')
plt.ylabel('PAXh system')

plt.legend()

plt.savefig('C:/Users/chris/plots/PAXh.png', dpi=1200, bbox_inches='tight', transparent=False) ## from ',dpi...': for hi-res poster-plot
plt.show()
plt.clf()
