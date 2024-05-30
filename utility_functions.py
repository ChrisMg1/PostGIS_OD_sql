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


R1  = np.linspace(0.01, 3, 599)

beta1 = 4
beta2 = 0.25

beta_bc = 1
tau_bc = 0.5

beta_sl = 4
Rmin_sl = min(R1)

alpha_tm = 0.3
beta_tm = 0.5
c_tm = 15

a_e = 1.2
beta_e = 3
c_e = 15

a_sc = 1.2
beta_sc = 3



def my_phi(x_in, a, b, c):                  # input for EVA1
    return (a/(1+np.exp(b-(c*x_in))))

f1_x = (R1**(-beta1)) # Kirchhoff bzw. Potenz
f2_x = np.exp(-beta2 * R1)  # Logit bzw. Exponent
f3_x = np.exp(-((beta_sl * ((R1/Rmin_sl)-1))**2))  # Modifizierte Exp.Funktion, s. Schnabel/Lohse (sl)
f4_x = (1+R1)**(-my_phi(R1, a_e, beta_e, c_e))  # EVA1 (e)
f5_x = (1+(R1/c_e)**beta_e)**(-a_e)  # EVA2 (e)
f6_x = 1 / (1+(R1/beta_sc)**a_sc)  # Schiller (sc)
f7_x = np.exp(-beta_bc*( ((R1**tau_bc)-1)/tau_bc ) )  # BoxCox (bc)
f8_x = 1 / ((R1**beta_tm)+(c_tm*(R1**alpha_tm)))  # TModel (tm)


plt.figure()
plt.ylim(0,1)
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(R1, f1_x, label='Potenzfunktion ("Kirchhoff"), ' + r'$ \beta = $' + str(beta1))
plt.plot(R1, f2_x, label='Exponentialfunktion ("Logit"), ' + r'$ \beta = $' + str(beta2))
plt.plot(R1, f3_x, label='Mod. Exponentialfunktion ("Lohse"), ' + r'$ \beta = $' + str(beta_sl))
plt.plot(R1, f4_x, label='EVA1, ' + r'$ \beta = $' + str(beta_e))
plt.plot(R1, f5_x, label='EVA2, ' + r'$ \beta = $' + str(beta_e))
plt.plot(R1, f6_x, label='Schiller, ' + r'$ \beta = $' + str(beta_sc))
plt.plot(R1, f7_x, label='BoxCox, ' + r'$ \beta = $' + str(beta_bc))
plt.plot(R1, f8_x, label='TModel, ' + r'$ \beta = $' + str(beta_tm))
plt.xlabel('Impedance')
plt.ylabel('Utility')
plt.legend(bbox_to_anchor =(0.5,-1), loc='lower center', ncol=2)
#plt.savefig('C:/Users/chris/plots/Imp_utility_param.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig('C:/Users/chris/plots/Imp_utility_param.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


#### (2) Plot exp w/different parameters
R2 = np.linspace(0, 3, 599)

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

fa1_x = np.exp(-a1 * R2)  # Logit bzw. Exponent
fa2_x = np.exp(-a2 * R2)  # Logit bzw. Exponent
fa3_x = np.exp(-a3 * R2)  # Logit bzw. Exponent
fa4_x = np.exp(-a4 * R2)  # Logit bzw. Exponent
fa5_x = np.exp(-a5 * R2)  # Logit bzw. Exponent

plt.figure()
plt.grid(color='grey', linestyle='dotted', linewidth=0.5)
plt.plot(R2, fa1_x, label=r'$ \beta = $' + str(a1))
plt.plot(R2, fa2_x, label=r'$ \beta = $' + str(a2))
plt.plot(R2, fa3_x, label=r'$ \beta = $' + 'ln(4)')
plt.plot(R2, fa4_x, label=r'$ \beta = $' + str(a4))
plt.plot(R2, fa5_x, label=r'$ \beta = $' + str(a5))
plt.xlabel('Impedance')
plt.ylabel('Utility')
plt.legend()
#plt.savefig('C:/Users/chris/plots/Imp_Logit_param.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig('C:/Users/chris/plots/Imp_Logit_param.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

np.exp(-a3 * 0.25)

1 / np.exp(1)
