# -*- coding: utf-8 -*-
"""
Created on Tue Apr  5 16:43:33 2022

@author: chris
"""
import numpy as np
import matplotlib.pyplot as plt

# Formeln zunächst aus Schnabel/Lohse
# Terminologie von 
# https://cgi.ptvgroup.com/vision-help/VISUM_2021_DEU/Content/1_Nachfragemodell/1_3_EVA-Verkehrsverteilung_und_Moduswahl.htm?Highlight=eva2

plot_type = 'single1'

max_u = 100
a = 0.5
b = 3
c = 15
Amin = 50
beta = 7
F=15

def my_phi(x_in, a, b, c):
    return (a/(1+np.exp(b-(c*x_in))))



x = np.linspace(0.01, max_u, 10*max_u)


f1_x = (x**(-a)) # Kirchhoff bzw. Potenz
f2_x = np.exp(-a * x)  # Logit bzw. Exponent
#f3_x = np.exp(-((beta * ((x/Amin)-1))**2))  # Modifizierte Exp.Funktion, s. Schnabel/Lohse
f4_x = (1+x)**(-my_phi(x, a, b, c))  # EVA1
f5_x = (1+(x/c)**b)**(-a)  # EVA2
f6_x = 1 / (1+(x/b)**a)  # Schiller
f7_x = np.exp(-c*( ((x**b)-1)/b ) )  # BoxCox
f8_x = 1 / ((x**b)+(c*(x**a)))  # TModel


#Btest = 4*(1+(A/F)**beta)**(-alpha1)  # My evaluation for connections

plt.figure()
axes = plt.axes()
axes.set_ylim([0, 1.3])
#plt.title('Vergleich verschiedener Bewertungsfunktionen')
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)


plt.plot(x, f1_x, label='Potenzfunktion')
plt.plot(x, f2_x, label='Exponentialfunktion')
#plt.plot(x, f3_x, label='Mod. Exponentialfunktion')
plt.plot(x, f4_x, label='EVA1')
plt.plot(x, f5_x, label='EVA2')
plt.plot(x, f6_x, label='Schiller')
#plt.plot(x, f7_x, label='BoxCox')
plt.plot(x, f8_x, label='TModel')

#plt.plot(A, Btest, label='CM EVAL', color='#4b0082', linewidth=6)

# horizontal / vertical ines
#plt.axvline(x=max_u/2, color='r', linestyle = 'dotted')
plt.axhline(y=1, color='black', linestyle = 'dotted')
plt.legend()

plt.xlabel('Impedance')
plt.ylabel('Utility')


plt.show()


