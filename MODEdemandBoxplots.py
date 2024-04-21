# -*- coding: utf-8 -*-
"""
Created on Sat Apr 20 15:34:12 2024

@author: chris
"""

import pandas as pd
import matplotlib.pyplot as plt

in_file = 'C:/TUMdissDATA/demandWITHbavariaFLAG2.csv'
abs_y = 0.00001

df = pd.read_csv(in_file)#, nrows=1000000)


demand_pkwTot = df['demand_pkw'] + df['demand_pkwm']
df.insert(0, "demand_pkwTot", demand_pkwTot)
df=df.drop(['demand_pkw', 'demand_pkwm'], axis=1)

# todo: compare int vs. float??
# dfGEQ1 = df[(df >= 1.0).any(axis=1)]
df = df[(df[['demand_pkwTot', 'demand_put', 'demand_bike', 'demand_walk']] >= 0).all(axis=1)]
dfGEQ1 = df[(df[['demand_pkwTot', 'demand_put', 'demand_bike', 'demand_walk']] >= 1).all(axis=1)]

modeLABELS = ['Car', 'PuT', 'Bike', 'Walk']

plt.figure()
axes = plt.axes()

plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot(df[['demand_pkwTot', 'demand_put', 'demand_bike', 'demand_walk']], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
# plt.ylim(-abs_y, abs_y)
plt.savefig('C:/Users/chris/plots/box_demand_purged.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()


plt.figure()
axes = plt.axes()

plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot(dfGEQ1[['demand_pkwTot', 'demand_put', 'demand_bike', 'demand_walk']], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
# plt.ylim(-abs_y, abs_y)
plt.savefig('C:/Users/chris/plots/box_demand_GEQ1.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()


