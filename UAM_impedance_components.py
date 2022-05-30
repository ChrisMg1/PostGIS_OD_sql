# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 17:46:26 2022

@author: chris
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import maxwell

def bathtub (x_in, shift_left=-1, shift_right=-350):
    if (x_in < 350):
        return (1+((x_in+shift_left)/c_dist)**b_dist)**(-a_dist)
    elif (x_in >=350):
        return max(0, min(1, 1-((1+((x_in+shift_right)/c_dist)**b_dist)**(-a_dist)) ) )
    else:
        return None

def imp_rel(x):
    return min(((1+((x+shift)/c)**b)**(-a)), 1)

max_PAX = 15
max_rat = 5
max_dist = 500

a = 0.9
b = 3
c = 0.9

shift=-1

x_rat = np.linspace(0.01, max_rat, 10*max_rat)
x_PAX = np.linspace(0.01, max_PAX, 10*max_PAX)
x_dist = np.linspace(0.01, max_dist, 10*max_dist)


a_dist = 9
b_dist = 3
c_dist = 60

#imp_rel = (1+((x_rat+shift)/c)**b)**(-a) 


# https://de.wikipedia.org/wiki/Aizermansche_Potentialfunktion
# oder
# https://de.wikipedia.org/wiki/Normalverteilung

## Plot travel time impedance (Logit)
plt.figure()

## cut canvas
axes = plt.axes()
#axes.set_xlim([1, 5])
#axes.set_ylim([0, 1.1])
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)



## Create values with function and plot
imp_rel_vals = []
for i in x_rat:
    imp_rel_vals.append(imp_rel(i))
plt.plot(x_rat, imp_rel_vals)

plt.xlabel('Travel Time Ratio PuT/PrT')
plt.ylabel('UAM Impedance (normalized)')

# Plot singularity
plt.scatter(0,1, s=100, facecolors='none', edgecolors='#1f77b4') 
plt.show()



## plot capacity impedence (Maxwell)
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

## play with parameters and plot
plt.plot(x_PAX, 1-1.7*maxwell.pdf(0.35*x_PAX))


plt.xlabel('Demand [PAX / flight]')
plt.ylabel('UAM Impedance (normalized)')

plt.show()


## plot distance impedence (bathtub)
plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

## Create values with function and plot
bathtub_vals = []
for i in x_dist:
    bathtub_vals.append(bathtub(i))
plt.plot(x_dist, bathtub_vals)

plt.xlabel('Distance [km]')
plt.ylabel('UAM Impedance (normalized)')

plt.show()




