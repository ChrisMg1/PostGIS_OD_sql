# -*- coding: utf-8 -*-
"""
Created on Tue Apr  5 16:43:33 2022

@author: chris
"""
import numpy as np
import matplotlib.pyplot as plt

plot_type = 'single1'

max_u = 120
alpha1 = 0.1
alpha2 = 0.3
alpha3 = 1.2
Amin = 50
beta = 7
F=15

def my_phi(A, E, F, WP):
    return (E/(1+np.exp(F*(1-(A/WP)))))



A = np.linspace(0, max_u, 10*max_u)


B1 = A**(-alpha1)
B2 = np.exp(-alpha1 * A)
B3 = np.exp(-((beta * ((A/Amin)-1))**2))
B4 = (1+A)**(-my_phi(A, 1, 4.5, 50))
B5 = (1+(A/F)**beta)**(-alpha1)

plt.figure()
plt.title('Vergleich verschiedener Bewertungsfunktionen')
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)

plt.plot(A, B1, label='Potenzfunktion')
plt.plot(A, B2, label='Exponentialfunktion')
plt.plot(A, B3, label='Mod. Exponentialfunktion')
plt.plot(A, B4, label='EVA1')
plt.plot(A, B5, label='EVA2')

# horizontal / vertical ines
#plt.axvline(x=max_u/2, color='r', linestyle = 'dotted')
plt.axhline(y=1, color='black', linestyle = 'dotted')
plt.legend()

plt.xlabel('Aufwand')
plt.ylabel('Bewertung')


plt.show()