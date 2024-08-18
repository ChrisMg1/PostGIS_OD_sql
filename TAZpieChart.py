# -*- coding: utf-8 -*-
"""
Created on Sat Aug 17 09:26:56 2024

@author: chris
"""


import matplotlib.pyplot as plt


# see '2020_07_08_LVMBY_Daten_Anwendungsdokumentation.pdf'
labels = 'Study Area', 'Influence Area', 'Outer Area'
sizes = [4870, 1220, 569]
total = sum(sizes)
colorsdef=['blue', 'skyblue', 'slateblue']

plt.figure()
axes = plt.axes()


plt.pie(sizes, labels=labels, colors=colorsdef, autopct=lambda p: '{:.0f}'.format(p * total / 100))

#plt.savefig('C:/Users/chris/plots/Imp_Logit_param.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig('C:/Users/chris/plots/TAZpieChart.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX

plt.show()
plt.clf()
