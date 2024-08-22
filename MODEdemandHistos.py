# -*- coding: utf-8 -*-
"""
Created on Tue Apr 16 20:54:34 2024

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

# todo: Change to xxx2.csv
in_file = 'C:/TUMdissDATA/demandPERmodeNOod.csv'

df = pd.read_csv(in_file)#, nrows=10000)


bin_number = 31

## Pkw + PkwM = PrT demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand private transport (car) model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len(df['demand_pkw'] + df['demand_pkwm']), ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['demand_pkw'] + df['demand_pkwm'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_pkw_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## PuT demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand public transport model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len(df['demand_put']), ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['demand_put'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_put_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## walk demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand walk model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len(df['demand_walk']), ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['demand_walk'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_walk_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()

## walk demand
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand bike model area [PAX/day]')
plt.ylabel('Frequency (n=' + format(len(df['demand_bike']), ',') + ')')
plt.ylim( (pow(10,0),pow(10,8)) )

plt.hist(df['demand_bike'], edgecolor='darkgrey', bins = bin_number, log=True)
plt.savefig('C:/Users/chris/plots/demand_bike_ALL.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.show()
plt.clf()
