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

def bathtub2(x_in, li, re, a1l, a1r, transp, Nmultip):
    l = Nmultip * li
    r = Nmultip * re    
    if (x_in > 2.0 * r):   # avoid out-of-range errors; ONLY FOR 'U'-SHAPE !!! threshold seems sufficient for bathtub, not for logit
        return 1.0
    elif (x_in < ((l + r) * transp)):
        #return 1.0-(1.0 / (1.0 + (np.exp(-a1l * (x_in - l )) ))) # alternative line
        return (1.0 / (1.0 + (np.exp( a1l * (x_in - l) )) ))
    elif (x_in >= ((l + r) * transp)):
        return (1.0 / (1.0 + (np.exp(-a1r * (x_in - r) )) ))
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


output_folder_ic = 'C:/Users/chris/plots/v06/factorFunctions/'

print('(1) Plot distance impedence (bathtub)')

## Set parameters
shift_left_dist = 60.0 # minimum limit according to Rothfeld et. al.
shift_right_dist = 300.0 # from lit. review (Lilium distance)
a1l_in_dist = 0.1
a1r_in_dist = 0.1
transition_point = 0.5 # Transition from left-hand (logit) function to right-hand (logit) function

bathtub_vals = []


x_dist = np.arange(0.0, 500, 0.01).tolist()

for i in x_dist:
    bathtub_vals.append(bathtub2(i, shift_left_dist, shift_right_dist, a1l_in_dist, a1r_in_dist, transition_point, 1.0))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_dist, bathtub_vals)
plt.xlabel('Distance [km]')
plt.ylabel('UAM Impedance (normalized)')

# Plot demand window
plt.axvline(shift_left_dist * 1, color='green', linestyle='dashed', linewidth=1) # min
plt.axvline(shift_right_dist * 1, color='red', linestyle='dashed', linewidth=1) # max

#plt.savefig(output_folder_ic + 'Imp_Distance_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig(output_folder_ic + 'Imp_Distance_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

print('(2) Plot travel time impedance (Logit)')

## Set parameters
p_in = 1.0 # default: 1.0
a2_in = 5.0 # default: 5.0

TTIME_Logit_vals = []


x_rat = np.arange(0.0, 3.0, 0.01).tolist()

for i in x_rat:
    TTIME_Logit_vals.append(TTIME_Logit(i, p_in, a2_in))
    
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_rat, TTIME_Logit_vals)
plt.xlabel('Travel Time Ratio PuT/PrT [min/min]')
plt.ylabel('UAM Impedance (normalized)')

# Plot singularity
# plt.scatter(0, 1, s=100, facecolors='none', edgecolors='#1f77b4')
#plt.savefig(output_folder_ic + 'Imp_TTratio_logit.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig(output_folder_ic + 'Imp_TTratio_logit.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


#### (3.0) Passengers

x_PAX = np.arange(0.0, 15, 0.01).tolist()

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
#plt.savefig(output_folder_ic + 'Imp_demand_Maxwell.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig(output_folder_ic + 'Imp_demand_Maxwell.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()



print('(3.2) Plot vehicle capacity impedence (bathtub2)')

## Set parameters
shift_left_PAX = 2.0
shift_right_PAX = 6.0
a1l_in_pax = 4.0
a1r_in_pax = 4.0
transition_point = 0.5 # Transition from left-hand (logit) function to right-hand (logit) function

PAX_vals2 = []

for i in x_PAX:
    PAX_vals2.append(bathtub2(i, shift_left_PAX, shift_right_PAX, a1l_in_pax, a1r_in_pax, transition_point, 1.0))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_PAX, PAX_vals2)
plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')
#plt.savefig(output_folder_ic + 'Imp_PAXperFLIGHT_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig(output_folder_ic + 'Imp_PAXperFLIGHT_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()


#### (4.0) Total demand threshold


x_demand = np.arange(0.0, 2500, 0.01).tolist()

print('(4.1) No minimum (Logit)')

## Set parameters
p_thresh_in = 768.0 # 32.0 * 24.0: According paper Lukas
a2_thresh_in = -0.1 # positive/negative for reverse


demand_threshold_logit = []

for i in x_demand:
    demand_threshold_logit.append(TTIME_Logit(i, p_thresh_in, a2_thresh_in))
    
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_demand, demand_threshold_logit)
plt.xlabel('Demand [PAX / day]')
plt.ylabel('UAM Impedance (normalized)')

# Plot vertiport throughput
plt.axvline(p_thresh_in * 1, color='red', linestyle='dashed', linewidth=1)

#plt.savefig(output_folder_ic + 'Imp_PAXperDAY_logit.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig(output_folder_ic + 'Imp_PAXperDAY_logit.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()




print('(4.2) With minimum (bathtub2)')

## Set parameters
shift_left_demand = 96.0 # Approx. 1 flight per hour: 24*4=96 _OR_ 12 flights per day: 12*4=48
shift_right_demand = 768.0 # 32.0*24.0=768: According paper Lukas, 32 PAX per hour
a1l_in_demand = 0.1
a1r_in_demand = 0.1
transition_point = 0.5 # Transition from left-hand (logit) function to right-hand (logit) function

demand_threshold_bathtub = []

for i in x_demand:
    demand_threshold_bathtub.append(bathtub2(i, shift_left_demand, shift_right_demand, a1l_in_demand, a1r_in_demand, transition_point, 1.0))

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x_demand, demand_threshold_bathtub)
plt.xlabel('Demand [PAX / day]')
plt.ylabel('UAM Impedance (normalized)')

# Plot vertiport throughput
plt.axvline(shift_left_demand * 1, color='green', linestyle='dashed', linewidth=1) # min
plt.axvline(shift_right_demand * 1, color='red', linestyle='dashed', linewidth=1) # max

#plt.savefig(output_folder_ic + 'Imp_PAXperDAY_bathtub2.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
#plt.savefig(output_folder_ic + 'Imp_PAXperDAY_bathtub2.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.show()
plt.clf()


print('(4.3) With minimum, playing around (bathtub2/LogBath)')

## Set parameters

shift_left_demand = 288.0 # e.g. 24*3*4=288 or 24*4=96 _OR_ 12 flights per day: 12*4=48
shift_right_demand = 768.0 # 32.0*24.0=768: According paper Lukas, 32 PAX per hour
a1l_in_demand = 0.02  # 0.02
a1r_in_demand = 0.1
transition_point = 0.65 # Transition from left-hand (logit) function to right-hand (logit) function

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

for n_vert in range(1, 4):
    demand_threshold_LogBath = []
    for i in x_demand:
        demand_threshold_LogBath.append(bathtub2(i, shift_left_demand, shift_right_demand, a1l_in_demand, a1r_in_demand, transition_point, n_vert))
    plt.plot(x_demand, demand_threshold_LogBath, label=r"$n_{vert}$ = " + str(n_vert))

plt.legend()
plt.xlabel('Demand [PAX / day]')
plt.ylabel('UAM Impedance (normalized)')

# Plot min/max, e.g. vertiport throughput
#plt.axvline(shift_left_demand * 1, color='green', linestyle='dashed', linewidth=1) # min
#plt.axvline(shift_right_demand * 1, color='red', linestyle='dashed', linewidth=1) # max

#plt.savefig(output_folder_ic + 'Imp_PAXperDAY_LogBath.png', dpi=600, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig(output_folder_ic + 'Imp_PAXperDAY_LogBath.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()
