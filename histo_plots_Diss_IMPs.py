# -*- coding: utf-8 -*-
"""
Created on Sat Aug 17 20:40:04 2024

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt

in_file = 'C:/TUMdissDATA/odpair_lvm2035_23712030_onlybav_exp.csv'

df = pd.read_csv(in_file)#, nrows=10019)


## demand impedance (imp_demand)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand impedance [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_demand']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['imp_demand'], bins='fd', color='blue')
#plt.savefig('C:/Users/chris/plots/imp_demand_23712030.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/imp_demand_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()




## travel time ratio impedance (imp_ttime)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Travel time ratio impedance [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_ttime']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['imp_ttime'], bins='fd', color='blue')
#plt.savefig('C:/Users/chris/plots/imp_ttime_23712030.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/imp_ttime_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## distance impedance (imp_distance)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Distance impedance [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_distance']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['imp_distance'], bins='fd', color='blue')
#plt.savefig('C:/Users/chris/plots/imp_distance_23712030.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/imp_distance_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


