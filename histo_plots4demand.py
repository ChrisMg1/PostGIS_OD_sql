# -*- coding: utf-8 -*-
"""
Created on Tue Apr  2 22:43:08 2024

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt
import cm_params

plt.rc('font', size=cm_params.SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=cm_params.SMALL_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=cm_params.MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=cm_params.SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=cm_params.BIGGER_SIZE)  # fontsize of the figure title

in_file = 'C:/TUMdissDATA/demandWITHbavariaFLAG2.csv'

for_hist = pd.read_csv(in_file)#, nrows=1000)


# min, max, and len of total demand
total_demand = for_hist['demand_all_person']
max_tot = total_demand.max()
print('total_demand: ', max_tot)
min_tot = total_demand.min()
print('total_demand: ', min_tot)
len_tot = len(total_demand)
print('total_demand: ', len_tot)

# min, max, and len of total demand with filter
total_demand_filter = for_hist[(for_hist.demand_all_person_purged >= 1)]['demand_all_person_purged']
max_tot_fil = total_demand_filter.max()
print('total_demand_filter: ', max_tot_fil)
min_tot_fil = total_demand_filter.min()
print('total_demand_filter: ', min_tot_fil)
len_tot_fil = len(total_demand_filter)
print('total_demand_filter: ', len_tot_fil)



# min, max, and len of bavarian demand
bav_demand = for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person']
max_bav = bav_demand.max()
print('bav_demand: ', max_bav)
min_bav = bav_demand.min()
print('bav_demand: ', min_bav)
len_bav = len(bav_demand)
print('bav_demand: ', len_bav)

# min, max, and len of bavarian demand with filter
bav_demand_filter = for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1) & (for_hist.fromzone_no != for_hist.tozone_no)]['demand_all_person_purged']
max_bav_fil = bav_demand_filter.max()
print('bav_demand_filter: ', max_bav_fil)
min_bav_fil = bav_demand_filter.min()
print('bav_demand_filter: ', min_bav_fil)
len_bav_fil = len(bav_demand_filter)
print('bav_demand_filter: ', len_bav_fil)



## Total demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len_tot, ',') + ')')
plt.ylim( (pow(10,-0.5),pow(10,8)) )

plt.hist(total_demand, edgecolor='darkgrey', bins = 'doane', log=True)
plt.savefig('C:/Users/chris/plots/demand_person_ALL.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.savefig('C:/Users/chris/plots/demand_person_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()


## Total demand with filter
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len_tot_fil, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(total_demand_filter, edgecolor='darkgrey', bins = 'doane', log=True)
#plt.savefig('C:/Users/chris/plots/demand_person_ALL_filterGEQ1.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.show()
plt.clf()


## Bavaria demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand study area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len_bav, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(bav_demand, edgecolor='darkgrey', bins = 'doane', log=True)
#plt.savefig('C:/Users/chris/plots/demand_person_BAV.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.show()
plt.clf()


## Bavaria demand with filter
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Purged passenger demand study area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len_bav_fil, ',') + ')')
plt.ylim( (pow(10,-0.5),pow(10,8)) )

plt.hist(bav_demand_filter, edgecolor='darkgrey', bins = 'doane', log=True)
plt.savefig('C:/Users/chris/plots/demand_person_BAV_purged.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.savefig('C:/Users/chris/plots/demand_person_BAV_purged.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()
