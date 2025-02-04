# -*- coding: utf-8 -*-
"""
Created on Sat Aug 17 09:26:56 2024

@author: chris
"""


import matplotlib.pyplot as plt
import cm_params

plt.rc('font', size=cm_params.SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=cm_params.SMALL_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=cm_params.MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=cm_params.SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=cm_params.BIGGER_SIZE)  # fontsize of the figure title


# see '2020_07_08_LVMBY_Daten_Anwendungsdokumentation.pdf'
labels = 'Study Area', 'Influence Area', 'Outer Area'
sizes = [4870, 1220, 569]
total = sum(sizes)
colorsdef=['silver', 'violet', 'skyblue']

plt.figure()
axes = plt.axes()

plt.pie(sizes, 
        labels=labels, 
        colors=colorsdef, 
        autopct=lambda p: '{:.0f}'.format(p * total / 100),
        wedgeprops = {"edgecolor" : "black", 'linewidth': 0.5, 'antialiased': True})


#plt.savefig('C:/Users/chris/plots/TAZpieChart.png', dpi=1200, bbox_inches='tight', transparent=True) ## png/dpi for (hi-res) poster-plot
plt.savefig('C:/Users/chris/plots/TAZpieChart.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
#plt.savefig('C:/Users/chris/plots/TAZpieChart.svg', transparent=True)

plt.show()
plt.clf()
