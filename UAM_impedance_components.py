# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 17:46:26 2022

@author: chris

This is only for function plot at the moment. 

The metric application is done in the rsp. SQL-scripts. 

"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import maxwell

def bathtub2 (x_in, l, r, a1l, a1r):
    if (x_in < ((l + r) / 2)):
        return (1 / (1 + np.exp( a1l * (x_in - l)) ))
    elif (x_in >= ((l + r) / 2)):
        return (1 / (1 + np.exp(-a1r * (x_in - r)) ))
    else:
        return None

def PAX_max(x_in, d, w, s):
	return 1-d*maxwell.pdf(w*(x_in - s))

def TTIME_Logit(x_in, p, a2):
    return (1 / (1 + np.exp(a2 * (x_in - p)) ))


## Create values for variables (visualization/plot only, not parametrization)
max_rat = 3
max_PAX = 15
max_dist = 500

x_rat = np.arange(0.01, max_rat, 0.01).tolist()
x_PAX = np.arange(0.01, max_PAX, 0.01).tolist()
x_dist = np.arange(0, max_dist, 0.01).tolist()

#### (1) plot distance impedence (bathtub)

## Set parameters
shift_left_dist = 75.0
shift_right_dist = 350.0
a1l_in=0.1
a1r_in=0.1

## Create values with function and plot
bathtub_vals = []
for i in x_dist:
    bathtub_vals.append(bathtub2(i, shift_left_dist, shift_right_dist, a1l_in, a1r_in))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_dist, bathtub_vals)
plt.xlabel('Distance [km]')
plt.ylabel('UAM Impedance (normalized)')
plt.savefig('C:/Users/chris/plots/Imp_Distance_bathtub.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_Distance_bathtub.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


#### (2) Plot travel time impedance (Logit)

## Set parameters
p_in = 1.0
a2_in = 5.0


TTIME_Logit_vals = []
for i in x_rat:
    TTIME_Logit_vals.append(TTIME_Logit(i, p_in, a2_in))
    
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_rat, TTIME_Logit_vals)
plt.xlabel('Travel Time Ratio PuT/PrT [min/min]')
plt.ylabel('UAM Impedance (normalized)')

# Plot singularity
# plt.scatter(0, 1, s=100, facecolors='none', edgecolors='#1f77b4')
plt.savefig('C:/Users/chris/plots/Imp_TTratio_logit.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_TTratio_logit.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


#### (3.1) plot capacity impedence ('Maxwell')

## Set parameters
d_in = 1.7034
w_in = 0.35
s_in = 0.0

PAX_vals = []
for i in x_PAX:
    PAX_vals.append(PAX_max(i, d_in, w_in, s_in))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_PAX, PAX_vals)
plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')
plt.savefig('C:/Users/chris/plots/Imp_demand_Maxwell.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_demand_Maxwell.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



#### (3.2) plot capacity impedence ('bathtub2')

## Set parameters
shift_left_PAX = 2.0
shift_right_PAX = 6.0
a1l_in_pax = 3.4
a1r_in_pax = 3.4

PAX_vals2 = []
for i in x_PAX:
    PAX_vals2.append(bathtub2(i, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_PAX, PAX_vals2)
plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')
#plt.savefig('C:/Users/chris/plots/Imp_demand_Logit.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_demand_Logit.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

print(bathtub2(6.0, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))
print(bathtub2(2.0, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))
print(bathtub2(4.0, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))
print(bathtub2(0.00001, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))
print(bathtub2(10000, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))




