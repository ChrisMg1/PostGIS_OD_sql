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

def bathtub2 (x_in, l, r, a1):
    if (x_in < ((l + r) / 2)):
        return (1 / (1 + np.exp( a1 * (x_in - l)) ))
    elif (x_in >= ((l + r) / 2)):
        return (1 / (1 + np.exp(-a1 * (x_in - r)) ))
    else:
        return None


def imp_rel2(x_in, p, a2):
    return (1 / (1 + np.exp(a2 * (x_in - p)) ))


def PAX_max(x_in, d, w, s):
	return 1-d*maxwell.pdf(w*(x_in - s))

## Create values for variables
max_PAX = 15
max_rat = 3
max_dist = 500

x_rat = np.arange(0.01, max_rat, 0.01).tolist()
x_PAX = np.linspace(0.01, max_PAX, 10*max_PAX)
x_dist = np.arange(0, max_dist, 0.1).tolist()


## Set parametrs
shift_right = 350
shift_left = 75
a1_in=0.1




## plot distance impedence (bathtub)
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

## Create values with function and plot
bathtub_vals = []
for i in x_dist:
    bathtub_vals.append(bathtub2(i, shift_left, shift_right, a1_in))
plt.plot(x_dist, bathtub_vals)

plt.xlabel('Distance [km]')
plt.ylabel('UAM Impedance (normalized)')

plt.savefig('C:/Users/chris/plots/Distance_bathtub.png', dpi=1200, bbox_inches='tight', transparent=True) ## from ',dpi...': for hi-res poster-plot
plt.show()
plt.clf()


## plot capacity impedence (Maxwell)
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)


PAX_vals = []
for i in x_PAX:
    PAX_vals.append(PAX_max(i, 1.7034, 0.35, 0))
## play with parameters and plot
plt.plot(x_PAX, PAX_vals)

#print(min(PAX_vals))


plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')

plt.savefig('C:/Users/chris/plots/demand_Maxwell.png', dpi=1200, bbox_inches='tight', transparent=True) ## from ',dpi...': for hi-res poster-plot
plt.show()
plt.clf()


## Plot travel time impedance (Logit)
plt.figure()

## cut canvas
axes = plt.axes()
#axes.set_xlim([1, 5])
#axes.set_ylim([0, 1.1])
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)


## Create values with function and plot relation PuT / PrT

a2_in = 15
p_in = 1.0

imp_rel_vals = []
for i in x_rat:
    imp_rel_vals.append(imp_rel2(i, p_in, a2_in))
plt.plot(x_rat, imp_rel_vals)

plt.xlabel('Travel Time Ratio PuT/PrT')
plt.ylabel('UAM Impedance (normalized)')

# Plot singularity
plt.scatter(0, 1, s=100, facecolors='none', edgecolors='#1f77b4')
plt.savefig('C:/Users/chris/plots/TTratio_logit.png', dpi=1200, bbox_inches='tight', transparent=True) ## from ',dpi...': for hi-res poster-plot
plt.show()
plt.clf()
