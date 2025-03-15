# -*- coding: utf-8 -*-
"""
Created on Sat Aug 17 20:40:04 2024

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



# Files and df for impedances:
in_file = 'C:/TUMdissDATA/odpair_lvm2035_23712030_onlybav_exp.csv'
df = pd.read_csv(in_file)#, nrows=10019)

print(df.head())
print(df.columns)


# Files and df for utilities:
in_file2 = 'C:/TUMdissDATA/odpair_lvm2035_11856015_onlybav_groupedBF_exp.csv'
df2 = pd.read_csv(in_file2)#, nrows=10019)

print(df2.head())
print(df2.columns)

# between 0 and 1: Plot limits for impedance
R_low = -0.01
R_high = 1.01

# between 0.25 and 1: Plot limits for utility
U_low = 0.19
U_high = 1.01

output_folder = 'C:/Users/chris/plots/v02/impedancesANDutilities/'

## 1a: travel time ratio distribution
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Travel Time Ratio PuT/PrT [min/min]')
plt.ylabel('Frequency (n=' + format(len(df['ttime_ratio']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['ttime_ratio'], bins='doane', color='blue', range=[0, 12])  # x-range limited due to arbitrary calibration values
plt.axvline(df['ttime_ratio'][df.ttime_ratio <= 12.0].mean(), color='r', linestyle='dashed', linewidth=1)
plt.text(df['ttime_ratio'][df.ttime_ratio <= 12.0].mean()*1.1, y.max() * 0.97, 'mean: {:.2f}'.format(df['ttime_ratio'][df.ttime_ratio <= 12.0].mean()), color = 'r')
#plt.savefig(output_folder + 'scen0_1a_ttime_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_1a_ttime_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

## 1b: travel time ratio impedance (imp_ttime)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Intermediate impedance $\mathregular{R_{tratio}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_ttime']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_ttime'], bins='doane', color='coral')
#plt.savefig(output_folder + 'scen0_1b_imp_ttime_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_1b_imp_ttime_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



## 2a: distance distribution
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Distance [km]')
plt.ylabel('Frequency (n=' + format(len(df['directdist']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['directdist'], bins='doane', color='blue')
plt.axvline(df['directdist'].mean(), color='r', linestyle='dashed', linewidth=1)
plt.text(df['directdist'].mean()*1.1, y.max() * 0.97, 'mean: {:.2f}'.format(df['directdist'].mean()), color = 'r')
#plt.savefig(output_folder + 'scen0_2a_distance_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_2a_distance_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

## 2b: distance impedance (imp_distance)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Intermediate impedance $\mathregular{R_{dist}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_distance']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_distance'], bins='doane', color='coral')
#plt.savefig(output_folder + 'scen0_2b_imp_distance_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_2b_imp_distance_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



## 3a: demand distribution
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Demand [PAX/day]')
plt.ylabel('Frequency (n=' + format(len(df['demand_all_person_purged']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['demand_all_person_purged'], bins='doane', color='blue', log=True)
plt.axvline(df['demand_all_person_purged'].mean(), color='r', linestyle='dashed', linewidth=1)
plt.text(df['demand_all_person_purged'].mean()*1.1, y.max() * 0.97, 'mean: {:.2f}'.format(df['demand_all_person_purged'].mean()), color = 'r')
#plt.savefig(output_folder + 'scen0_3a_demand_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_3a_demand_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

## 3b: demand impedance (imp_demand)
plt.figure()
axes = plt.axes()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Intermediate impedance $\mathregular{R_{demand}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_demand']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_demand'], bins='doane', color='coral', log=True)
#plt.savefig(output_folder + 'scen0_3b_imp_demand_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'scen0_3b_imp_demand_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



## Combined impedance Scenario 1 (df$imp_tot_scen1_common)
plt.figure()
axes = plt.axes()
axes.set_xlim(R_low, R_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Combined impedance $\mathregular{R_{comb}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_tot_scen1_common']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_tot_scen1_common'], bins='doane', color='darkviolet')

# Plot min and max values
plt.axvline(0.0, color='darkviolet', linestyle='dashed', linewidth=1)
plt.axvline(1.0, color='darkviolet', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'imp_tot_scen1_common_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'imp_tot_scen1_common_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Utility Scenario 1 (df2$u_ample_scen1_common)
plt.figure()
axes = plt.axes()
axes.set_xlim(U_low, U_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Utility $\mathregular{U_A}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df2['u_ample_scen1_common']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df2['u_ample_scen1_common'], bins='doane', color='forestgreen')

# Plot min and max values
plt.axvline(0.25, color='forestgreen', linestyle='dashed', linewidth=1)
plt.axvline(1.00, color='forestgreen', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'UA_scen1_common_11856015.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'UA_scen1_common_11856015.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Combined impedance Scenario 2 (df$imp_tot_scen2_society)
plt.figure()
axes = plt.axes()
axes.set_xlim(R_low, R_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Combined impedance $\mathregular{R_{comb}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_tot_scen2_society']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_tot_scen2_society'], bins='doane', color='darkviolet')

# Plot min and max values
plt.axvline(0.0, color='darkviolet', linestyle='dashed', linewidth=1)
plt.axvline(1.0, color='darkviolet', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'imp_tot_scen2_society_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'imp_tot_scen2_society_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Utility Scenario 2 (df2$u_ample_scen2_society)
plt.figure()
axes = plt.axes()
axes.set_xlim(U_low, U_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Utility $\mathregular{U_A}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df2['u_ample_scen2_society']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df2['u_ample_scen2_society'], bins='doane', color='forestgreen')

# Plot min and max values
plt.axvline(0.25, color='forestgreen', linestyle='dashed', linewidth=1)
plt.axvline(1.00, color='forestgreen', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'UA_scen2_society_11856015.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'UA_scen2_society_11856015.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Combined impedance Scenario 3 (df$imp_tot_scen3_technology)
plt.figure()
axes = plt.axes()
axes.set_xlim(R_low, R_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Combined impedance $\mathregular{R_{comb}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_tot_scen3_technology']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_tot_scen3_technology'], bins='doane', color='darkviolet')

# Plot min and max values
plt.axvline(0.0, color='darkviolet', linestyle='dashed', linewidth=1)
plt.axvline(1.0, color='darkviolet', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'imp_tot_scen3_technology_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'imp_tot_scen3_technology_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Utility Scenario 3 (df2$u_ample_scen3_technology)
plt.figure()
axes = plt.axes()
axes.set_xlim(U_low, U_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Utility $\mathregular{U_A}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df2['u_ample_scen3_technology']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df2['u_ample_scen3_technology'], bins='doane', color='forestgreen')

# Plot min and max values
plt.axvline(0.25, color='forestgreen', linestyle='dashed', linewidth=1)
plt.axvline(1.00, color='forestgreen', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'UA_scen3_technology_11856015.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'UA_scen3_technology_11856015.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Combined impedance Scenario 4 (df$imp_tot_scen4_operator)
plt.figure()
axes = plt.axes()
axes.set_xlim(R_low, R_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Combined impedance $\mathregular{R_{comb}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_tot_scen4_operator']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_tot_scen4_operator'], bins='doane', color='darkviolet')

# Plot min and max values
plt.axvline(0.0, color='darkviolet', linestyle='dashed', linewidth=1)
plt.axvline(1.0, color='darkviolet', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'imp_tot_scen4_operator_23712030.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'imp_tot_scen4_operator_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Utility Scenario 4 (df2$u_ample_scen4_operator)
plt.figure()
axes = plt.axes()
axes.set_xlim(U_low, U_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Utility $\mathregular{U_A}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df2['u_ample_scen4_operator']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df2['u_ample_scen4_operator'], bins='doane', color='forestgreen')

# Plot min and max values
plt.axvline(0.25, color='forestgreen', linestyle='dashed', linewidth=1)
plt.axvline(1.00, color='forestgreen', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'UA_scen4_operator_11856015.png', dpi=500, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig(output_folder + 'UA_scen4_operator_11856015.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## Combined impedance Scenario 5 (df$imp_tot_scen5_societytec)
plt.figure()
axes = plt.axes()
axes.set_xlim(R_low, R_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Combined impedance $\mathregular{R_{comb}}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df['imp_tot_scen5_societytec']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df['imp_tot_scen5_societytec'], bins='doane', color='darkviolet')

# Plot min and max values
plt.axvline(0.0, color='darkviolet', linestyle='dashed', linewidth=1)
plt.axvline(1.0, color='darkviolet', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'imp_tot_scen5_societyTec_23712030.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.savefig(output_folder + 'imp_tot_scen5_societyTec_23712030.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()


## Utility Scenario 5 (df2$u_ample_scen5_societytec)
plt.figure()
axes = plt.axes()
axes.set_xlim(U_low, U_high)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.xlabel('Utility $\mathregular{U_A}$ [unitless]')
plt.ylabel('Frequency (n=' + format(len(df2['u_ample_scen5_societytec']), ',') + ')')
#plt.ylim( (pow(10,0),pow(10,8)) )
y, x, _ = plt.hist(df2['u_ample_scen5_societytec'], bins='doane', color='forestgreen')

# Plot min and max values
plt.axvline(0.25, color='forestgreen', linestyle='dashed', linewidth=1)
plt.axvline(1.00, color='forestgreen', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder + 'UA_scen5_societyTec_11856015.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
#plt.savefig(output_folder + 'UA_scen5_societyTec_11856015.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()