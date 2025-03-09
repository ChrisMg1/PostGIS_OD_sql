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

import cm_params

def bathtub2 (x_in, l, r, a1l, a1r):
    if (x_in > 1.5 * r):   # avoid out-of-range errors; ONLY FOR 'U'-SHAPE !!! threshold seems sufficient for bathtub, not for logit
        return 1.0
    elif (x_in < ((l + r) / 2)):
        return (1.0 / (1.0 + np.exp( a1l * (x_in - l)) ))
    elif (x_in >= ((l + r) / 2.0)):
        return (1.0 / (1.0 + np.exp(-a1r * (x_in - r)) ))
    else:
        raise ValueError("CM: Invalid Thresholds etc.")

def PAX_max(x_in, d, w, s):
	return 1.0-d*maxwell.pdf(w*(x_in - s))

def TTIME_Logit(x_in, p, a2):
    if (x_in > 3.0 * p):   # avoid out-of-range errors
        if (a2 >= 0.0):
            return 0.0
        elif (a2 < 0.0):
            return 1.0
        else:
            raise ValueError("CM: Invalid Thresholds etc.")
    elif (x_in <= 3.0 * p):
        return (1.0 / (1.0 + np.exp(a2 * (x_in - p)) ))
    else:
        raise ValueError("CM: Invalid Thresholds etc.")


print('(1) Plot distance impedence (bathtub)')

## Set parameters
shift_left_dist = 75.0
shift_right_dist = 350.0
a1l_in_dist = 0.1
a1r_in_dist = 0.1

bathtub_vals = []

max_dist = 500
x_dist = np.arange(0.0, max_dist, 0.01).tolist()

for i in x_dist:
    bathtub_vals.append(bathtub2(i, shift_left_dist, shift_right_dist, a1l_in_dist, a1r_in_dist))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_dist, bathtub_vals)
plt.xlabel('Distance [km]')
plt.ylabel('UAM Impedance (normalized)')
plt.savefig('C:/Users/chris/plots/Imp_Distance_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_Distance_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


print('(2) Plot travel time impedance (Logit)')

## Set parameters
p_in = 1.0
a2_in = 5.0

TTIME_Logit_vals = []

max_rat = 3
x_rat = np.arange(0.0, max_rat, 0.01).tolist()

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


#### (3.0) Passengers

max_PAX = 15
x_PAX = np.arange(0.0, max_PAX, 0.01).tolist()

print('(3.1) Plot vehicle capacity impedence (Maxwell)')

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



print('(3.2) Plot vehicle capacity impedence (bathtub2)')

## Set parameters
shift_left_PAX = 2.0
shift_right_PAX = 6.0
a1l_in_pax = 4.0
a1r_in_pax = 4.0

PAX_vals2 = []

for i in x_PAX:
    PAX_vals2.append(bathtub2(i, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_PAX, PAX_vals2)
plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')
plt.savefig('C:/Users/chris/plots/Imp_PAXperFLIGHT_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_PAXperFLIGHT_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


#### (4.0) Total demand threshold

max_thresh = 1000
x_thresh = np.arange(0.0, max_thresh, 0.01).tolist()

print('(4.1) No minimum (Logit)')

## Set parameters
p_thresh_in = 768.0 # 32.0 * 24.0: According paper Lukas
a2_thresh_in = -1.0 # positive/negative for reverse


demand_threshold_logit = []

for i in x_thresh:
    demand_threshold_logit.append(TTIME_Logit(i, p_thresh_in, a2_thresh_in))
    
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_thresh, demand_threshold_logit)
plt.xlabel('Demand [PAX / day]')
plt.ylabel('UAM Impedance (normalized)')

# Plot vertiport throughput
plt.axvline(p_thresh_in * 1, color='red', linestyle='dashed', linewidth=1)

plt.savefig('C:/Users/chris/plots/Imp_PAXperDAY_logit.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_PAXperDAY_logit.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


print('(4.2) With minimum (bathtub2)')

## Set parameters
shift_left_demand = 96.0 # 24 * 4: Approx. 1 flight per hour
shift_right_demand = 768.0 # 32.0 * 24.0: According paper Lukas
a1l_in_demand = 1.0
a1r_in_demand = 1.0

demand_threshold_bathtub = []

for i in x_thresh:
    demand_threshold_bathtub.append(bathtub2(i, shift_left_demand, shift_right_demand, a1l_in_demand, a1r_in_demand))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_thresh, demand_threshold_bathtub)
plt.xlabel('Demand [PAX / day]')
plt.ylabel('UAM Impedance (normalized)')

# Plot vertiport throughput
plt.axvline(shift_left_demand * 1, color='green', linestyle='dashed', linewidth=1) # min
plt.axvline(shift_right_demand * 1, color='red', linestyle='dashed', linewidth=1) # max

plt.savefig('C:/Users/chris/plots/Imp_PAXperDAY_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig('C:/Users/chris/plots/Imp_PAXperDAY_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()
