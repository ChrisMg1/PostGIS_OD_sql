# -*- coding: utf-8 -*-
"""
Created on Sat Apr 20 15:34:12 2024

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

df = pd.read_csv(in_file)#, nrows=1950)

df.insert(0, "demand_pkwTot", df['demand_pkw'] + df['demand_pkwm'])

modeLABELS = ['PrT (Car)', 'PuT', 'Bike', 'Walk']

# Purged demand study area
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot([df['demand_pkwTot'][(df.demand_pkwTot >= 0.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_put'][(df.demand_put >= 0.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_bike'][(df.demand_bike >= 0.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_walk'][(df.demand_walk >= 0.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ]
             ], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
#plt.savefig('C:/Users/chris/plots/box_demand_purged_study.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/box_demand_purged_study.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

# Fictional demand greater equal 1 study area
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot([df['demand_pkwTot'][(df.demand_pkwTot >= 1.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_put'][(df.demand_put >= 1.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_bike'][(df.demand_bike >= 1.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ], 
             df['demand_walk'][(df.demand_walk >= 1.0) & (df.fromzone_no != df.tozone_no) & (df.fromzone_by == 1) & (df.tozone_by == 1) ]
             ], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
#plt.savefig('C:/Users/chris/plots/box_demand_GEQ1_study.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/box_demand_GEQ1_study.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



# Purged demand model area
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot([df['demand_pkwTot'][(df.demand_pkwTot >= 0.0)], 
             df['demand_put'][(df.demand_put >= 0.0)], 
             df['demand_bike'][(df.demand_bike >= 0.0)], 
             df['demand_walk'][(df.demand_walk >= 0.0)]
             ], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
#plt.savefig('C:/Users/chris/plots/box_demand_purged_model.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.savefig('C:/Users/chris/plots/box_demand_purged_model.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()

# Fictional demand greater equal 1 model area
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.boxplot([df['demand_pkwTot'][(df.demand_pkwTot >= 1.0)], 
             df['demand_put'][(df.demand_put >= 1.0)], 
             df['demand_bike'][(df.demand_bike >= 1.0)], 
             df['demand_walk'][(df.demand_walk >= 1.0)]
             ], 
            showfliers=False, 
            labels=modeLABELS,
            notch=False)
plt.ylabel('Demand per mode [PAX/day]')
#plt.savefig('C:/Users/chris/plots/box_demand_GEQ1_model.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.savefig('C:/Users/chris/plots/box_demand_GEQ1_model.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#.show()
plt.clf()
