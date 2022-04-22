# -*- coding: utf-8 -*-
"""
Created on Tue Apr  5 16:43:33 2022

@author: chris
"""
import numpy as np
import matplotlib.pyplot as plt
# from utility_functions import simple_utility

plot_type = 'logit'

beta = 0.2

max_u = 180

# Utility of alternatives
u1 = 20
u2 = 50
u3 = 80
u4 = 110
u5 = 140

A = np.linspace(0, max_u, 10*max_u)

P1l = np.exp(-beta * A) / (np.exp(-beta * u1)+np.exp(-beta * A))
P2l = np.exp(-beta * A) / (np.exp(-beta * u2)+np.exp(-beta * A))
P3l = np.exp(-beta * A) / (np.exp(-beta * u3)+np.exp(-beta * A))
P4l = np.exp(-beta * A) / (np.exp(-beta * u4)+np.exp(-beta * A))
P5l = np.exp(-beta * A) / (np.exp(-beta * u5)+np.exp(-beta * A))

P3k = A**(-beta) / (u3**(-beta)+A**(-beta))

Z1 = beta * np.exp(-beta * (A - u1)) / (1 + np.exp(-beta * (A - u1)))**2
Z2 = beta * np.exp(-beta * (A - u2)) / (1 + np.exp(-beta * (A - u2)))**2
Z3 = beta * np.exp(-beta * (A - u3)) / (1 + np.exp(-beta * (A - u3)))**2
Z4 = beta * np.exp(-beta * (A - u4)) / (1 + np.exp(-beta * (A - u4)))**2
Z5 = beta * np.exp(-beta * (A - u5)) / (1 + np.exp(-beta * (A - u5)))**2

plt.figure()
plt.xticks(np.arange(0, max_u, step=10))
plt.yticks(np.arange(0, 1, step=0.1))
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
if (plot_type == 'logit'): 
    plt.plot(A, P1l)
    plt.plot(A, P2l)
    plt.plot(A, P3l)
    plt.plot(A, P4l)
    plt.plot(A, P5l)
    
    plt.plot(A, Z1)
    plt.plot(A, Z2)
    plt.plot(A, Z3)
    plt.plot(A, Z4)
    plt.plot(A, Z5)
    
    plt.title('Logit')
    
    
elif (plot_type == 'compare'):    
    plt.plot(A, P3l, label='logit')
    plt.plot(A, P3k, label='kirchhoff')

plt.legend()
plt.xlabel('Aufwand')
plt.ylabel('Wahlwahrscheinlichkeit')


plt.show()