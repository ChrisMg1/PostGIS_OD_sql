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

# min, max, and len of total demand
total_demand = for_hist['demand_all_person']
max_tot = total_demand.max()
print(max_tot)
min_tot = total_demand.min()
print(min_tot)
len_tot = len(total_demand)
print(len_tot)

# min, max, and len of total demand with filter >= 0 etc.
total_demand_filter = for_hist[(for_hist.demand_all_person_purged >= 1)]['demand_all_person_purged']
max_tot_fil = total_demand_filter.max()
print(max_tot_fil)
min_tot_fil = total_demand_filter.min()
print(min_tot_fil)
len_tot_fil = len(total_demand_filter)
print(len_tot_fil)



# min, max, and len of bavarian demand
bav_demand = for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person']
max_bav = bav_demand.max()
print(max_bav)
min_bav = bav_demand.min()
print(min_bav)
len_bav = len(bav_demand)
print(len_bav)

# min, max, and len of bavarian demand with filter >= 0 etc.
bav_demand_filter = for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1) & (for_hist.demand_all_person_purged >= 1)]['demand_all_person_purged']
max_bav_fil = bav_demand_filter.max()
print(max_bav_fil)
min_bav_fil = bav_demand_filter.min()
print(min_bav_fil)
len_bav_fil = len(bav_demand_filter)
print(len_bav_fil)



## Total demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand model area')
plt.ylabel('Frequency (n=' + format(len_tot, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

# plt.hist(for_hist['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.hist(total_demand, edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## Total demand with filter >0
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand model area')
plt.ylabel('Frequency (n=' + format(len_tot_fil, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

# plt.hist(for_hist[(for_hist.demand_all_person >= 0)]['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.hist(total_demand_filter, edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_ALL_filterGT0.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()




## Bavaria demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand study area')
plt.ylabel('Frequency (n=' + format(len_bav, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

# plt.hist(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1)]['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.hist(bav_demand, edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_BAV.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## Bavaria demand with filter >0
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Passenger demand study area')
plt.ylabel('Frequency (n=' + format(len_bav_fil, ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

# plt.hist(for_hist[(for_hist.fromzone_by == 1) & (for_hist.tozone_by == 1) & (for_hist.demand_all_person >= 0)]['demand_all_person'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.hist(bav_demand_filter, edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_person_BAV_filterGT0.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()
