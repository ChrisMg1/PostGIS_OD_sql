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

max_u = 1
a = np.log(4)
b = 3
c = 15
Amin = 50
beta = 7
F=15

def my_phi(x_in, a, b, c):
    return (a/(1+np.exp(b-(c*x_in))))



x  = np.linspace(0.01, max_u, 100*max_u)
x2 = np.linspace(0, 3, 599)


f1_x = (x**(-a)) # Kirchhoff bzw. Potenz
f2_x = np.exp(-a * x)  # Logit bzw. Exponent
f3_x = np.exp(-((beta * ((x/Amin)-1))**2))  # Modifizierte Exp.Funktion, s. Schnabel/Lohse
f4_x = (1+x)**(-my_phi(x, a, b, c))  # EVA1
f5_x = (1+(x/c)**b)**(-a)  # EVA2
f6_x = 1 / (1+(x/b)**a)  # Schiller
f7_x = np.exp(-c*( ((x**b)-1)/b ) )  # BoxCox
f8_x = 1 / ((x**b)+(c*(x**a)))  # TModel


#Btest = 4*(1+(A/F)**beta)**(-alpha1)  # My evaluation for connections

plt.figure()


axes = plt.axes()
axes.set_ylim([0, 1.0])
#plt.title('Vergleich verschiedener Bewertungsfunktionen')
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)


plt.plot(x, f1_x, label='Potenzfunktion')
plt.plot(x, f2_x, label='Exponentialfunktion')
plt.plot(x, f3_x, label='Mod. Exponentialfunktion')
plt.plot(x, f4_x, label='EVA1')
plt.plot(x, f5_x, label='EVA2')
plt.plot(x, f6_x, label='Schiller')
plt.plot(x, f7_x, label='BoxCox')
plt.plot(x, f8_x, label='TModel')

#plt.plot(A, Btest, label='CM EVAL', color='#4b0082', linewidth=6)

# horizontal / vertical ines
#plt.axvline(x=max_u/2, color='r', linestyle = 'dotted')
#plt.axhline(y=1, color='black', linestyle = 'dotted')
plt.legend()

plt.xlabel('Impedance')
plt.ylabel('Utility')


#plt.savefig('plots/finUtility.png')
plt.show()
plt.clf()


#### (2) Plot exp w/different parameters

## Set parameters
d_in = 1.7034
w_in = 0.35
s_in = 0

#PAX_vals = []
#for i in x_PAX:
#    PAX_vals.append(PAX_max(i, d_in, w_in, s_in))

a1 = 0.5
a2 = 1.0
a3 = np.log(4)
a4 = 2.0
a5 = 10.0


fa1_x = np.exp(-a1 * x2)  # Logit bzw. Exponent
fa2_x = np.exp(-a2 * x2)  # Logit bzw. Exponent
fa3_x = np.exp(-a3 * x2)  # Logit bzw. Exponent
fa4_x = np.exp(-a4 * x2)  # Logit bzw. Exponent
fa5_x = np.exp(-a5 * x2)  # Logit bzw. Exponent

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(x2, fa1_x, label=r'$ \beta = $' + str(a1))
plt.plot(x2, fa2_x, label=r'$ \beta = $' + str(a2))
plt.plot(x2, fa3_x, label=r'$ \beta = $' + 'ln(4)')
plt.plot(x2, fa4_x, label=r'$ \beta = $' + str(a4))
plt.plot(x2, fa5_x, label=r'$ \beta = $' + str(a5))
plt.xlabel('Impedance')
plt.ylabel('Utility')
plt.legend()
#plt.savefig('C:/Users/chris/plots/Imp_Logit_param.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig('C:/Users/chris/plots/Imp_Logit_param.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

