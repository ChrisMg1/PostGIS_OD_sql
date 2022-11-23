# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 18:15:43 2022

@author: chris
"""

import numpy as np

from matplotlib import cm
from matplotlib.colors import Normalize 
from scipy.interpolate import interpn

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

def monoExp(x, m, t, b):
    return m * np.exp(-t * x) + b

def ret_cumsum(scenario, od_df_data):
    # sum values
    sum_PAXh_base = od_df_data['pax_h_base'].sum()
    #sum_PAXh_UAM = od_df_data['pax_h_uam_all'].sum()
    
    # sort df according to metric values of input scenario
    for_hist_sort = od_df_data.sort_values(scenario, ascending=False)  # False for descending!
    
    # Make Cumsum of passenger-hours
    # note: still all demand (demand_ivoev, iv+oev), no capacity restriction
    for_hist_sort['pax_h_base_CUM_SCENARIO'] = for_hist_sort['pax_h_base'].cumsum()
    for_hist_sort['pax_h_uam_all_CUM_SCENARIO'] = for_hist_sort['pax_h_uam_all'].cumsum()
    
    # total passenger-hours in the system
    for_hist_sort['pax_h_total_SCENARIO'] = sum_PAXh_base - for_hist_sort['pax_h_base_CUM_SCENARIO'] + for_hist_sort['pax_h_uam_all_CUM_SCENARIO']
    
    print(scenario)
    print(for_hist_sort)
    
    return for_hist_sort['pax_h_total_SCENARIO'].copy()


pax_h_total_S1 = ret_cumsum('cm_metric_scen1', for_hist).reset_index(drop=True)
pax_h_total_S2 = ret_cumsum('cm_metric_scen2', for_hist).reset_index(drop=True)
pax_h_total_S3 = ret_cumsum('cm_metric_scen3', for_hist).reset_index(drop=True)

pax_h_total_dist = ret_cumsum('directdist', for_hist).reset_index(drop=True)


plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

# Optional: Set x-axis as percentage values
plt.gca().xaxis.set_major_formatter(mtick.PercentFormatter(xmax=len(pax_h_total_S1)))

plt.plot(pax_h_total_S1, label='metric 1')
plt.plot(pax_h_total_S2, label='metric 2')
plt.plot(pax_h_total_S3, label='metric 3')

plt.plot(pax_h_total_dist, label='distance')

plt.xlabel('UAM conn ercentage')
plt.ylabel('PAXh system')

plt.legend()

plt.savefig('C:/Users/chris/plots/PAXh.png', dpi=1200, bbox_inches='tight', transparent=False) ## from ',dpi...': for hi-res poster-plot
plt.show()
plt.clf()


#TODO: Plot PAXh vs. distance
def density_scatter( x , y, ax = None, sort = True, bins = 20, addXlabel='', addYlabel='', **kwargs )   :
    """
    Scatter plot colored by 2d histogram
    """
    if ax is None :
        fig , ax = plt.subplots()
    data , x_e, y_e = np.histogram2d( x, y, bins = bins, density = True )
    z = interpn( ( 0.5*(x_e[1:] + x_e[:-1]) , 0.5*(y_e[1:]+y_e[:-1]) ) , data , np.vstack([x,y]).T , method = "splinef2d", bounds_error = False)

    #To be sure to plot all data
    z[np.where(np.isnan(z))] = 0.0

    # Sort the points by density, so that the densest points are plotted last
    if sort :
        idx = z.argsort()
        x, y, z = x[idx], y[idx], z[idx]
        
    
    
    ax.set_xlabel(addXlabel)
    ax.set_ylabel(addYlabel)
    
    ax.scatter( x, y, c=z, **kwargs )

    norm = Normalize(vmin = np.min(z), vmax = np.max(z))
    cbar = fig.colorbar(cm.ScalarMappable(norm = norm), ax=ax)
    cbar.ax.set_ylabel('Point Density')

    return ax

# Optional for test data only
x = np.random.normal(size=1000)
y = x * 3 + np.random.normal(size=1000)

# Test vs. final plot
plot_dense_out = density_scatter( x,y, bins = [30,30], addXlabel = 'Distance [km]', addYlabel = 'Demand [PAX]' )
#plot_dense_out = density_scatter( for_hist['directdist'], for_hist['demand_ivoev'], bins = [30,30] )

plot_dense_out.figure.savefig('C:/Users/chris/plots/distVSdemand_dense_scatter.png', dpi=1200, bbox_inches='tight', transparent=False)




