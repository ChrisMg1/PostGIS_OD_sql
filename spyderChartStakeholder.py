# -*- coding: utf-8 -*-
"""
Created on Thu Oct  3 08:04:23 2024

@author: chris

Credits to
https://stackoverflow.com/questions/52910187/how-to-make-a-polygon-radar-spider-chart-in-python
"""

import numpy as np

import matplotlib.pyplot as plt
from matplotlib.patches import Circle, RegularPolygon
from matplotlib.path import Path
from matplotlib.projections.polar import PolarAxes
from matplotlib.projections import register_projection
from matplotlib.spines import Spine
from matplotlib.transforms import Affine2D

import cm_params

plt.rc('font', size=cm_params.SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=cm_params.SMALL_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=cm_params.MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=2.2*cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=1.3*cm_params.SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=cm_params.SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=cm_params.BIGGER_SIZE)  # fontsize of the figure title


def radar_factory(num_vars, frame='circle'):
    """Create a radar chart with `num_vars` axes.

    This function creates a RadarAxes projection and registers it.

    Parameters
    ----------
    num_vars : int
        Number of variables for radar chart.
    frame : {'circle' | 'polygon'}
        Shape of frame surrounding axes.

    """
    # calculate evenly-spaced axis angles
    theta = np.linspace(0, 2*np.pi, num_vars, endpoint=False)
    
    class RadarTransform(PolarAxes.PolarTransform):
        def transform_path_non_affine(self, path):
            # Paths with non-unit interpolation steps correspond to gridlines,
            # in which case we force interpolation (to defeat PolarTransform's
            # autoconversion to circular arcs).
            if path._interpolation_steps > 1:
                path = path.interpolated(num_vars)
            return Path(self.transform(path.vertices), path.codes)

    class RadarAxes(PolarAxes):

        name = 'radar'
        
        PolarTransform = RadarTransform

        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            # rotate plot such that the first axis is at the top
            self.set_theta_zero_location('N')

        def fill(self, *args, closed=True, **kwargs):
            """Override fill so that line is closed by default"""
            return super().fill(closed=closed, *args, **kwargs)

        def plot(self, *args, **kwargs):
            """Override plot so that line is closed by default"""
            lines = super().plot(*args, **kwargs)
            for line in lines:
                self._close_line(line)

        def _close_line(self, line):
            x, y = line.get_data()
            # FIXME: markers at x[0], y[0] get doubled-up
            if x[0] != x[-1]:
                x = np.concatenate((x, [x[0]]))
                y = np.concatenate((y, [y[0]]))
                line.set_data(x, y)

        def set_varlabels(self, labels):
            self.set_thetagrids(np.degrees(theta), labels)

        def _gen_axes_patch(self):
            # The Axes patch must be centered at (0.5, 0.5) and of radius 0.5
            # in axes coordinates.
            if frame == 'circle':
                return Circle((0.5, 0.5), 0.5)
            elif frame == 'polygon':
                return RegularPolygon((0.5, 0.5), num_vars,
                                      radius=.5, edgecolor="k")
            else:
                raise ValueError("unknown value for 'frame': %s" % frame)

        def draw(self, renderer):
            """ Draw. If frame is polygon, make gridlines polygon-shaped """
            if frame == 'polygon':
                gridlines = self.yaxis.get_gridlines()
                for gl in gridlines:
                    gl.get_path()._interpolation_steps = num_vars
            super().draw(renderer)


        def _gen_axes_spines(self):
            if frame == 'circle':
                return super()._gen_axes_spines()
            elif frame == 'polygon':
                # spine_type must be 'left'/'right'/'top'/'bottom'/'circle'.
                spine = Spine(axes=self,
                              spine_type='circle',
                              path=Path.unit_regular_polygon(num_vars))
                # unit_regular_polygon gives a polygon of radius 1 centered at
                # (0, 0) but we want a polygon of radius 0.5 centered at (0.5,
                # 0.5) in axes coordinates.
                spine.set_transform(Affine2D().scale(.5).translate(.5, .5)
                                    + self.transAxes)


                return {'polar': spine}
            else:
                raise ValueError("unknown value for 'frame': %s" % frame)

    register_projection(RadarAxes)
    return theta


## CM: Stakeholder society
data1 = [['Existing Transport Supply', '\nVehicle Technology', '\nTransport Demand'],
        ('', 
         [[1.0, 0.1, 0.5]])
        ]

N = len(data1[0])
theta = radar_factory(N, frame='polygon')

spoke_labels = data1.pop(0)
title, case_data = data1[0]

fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(projection='radar'))
#fig.subplots_adjust(top=0.85, bottom=0.05)

ax.set_rgrids([0.1, 0.5, 1.0])
#ax.set_title(title,  position=(0.5, 1.1), ha='center')

for d in case_data:
    line = ax.plot(theta, d)
    ax.fill(theta, d, alpha=0.25, label='_nolegend_')
ax.set_varlabels(spoke_labels)


#plt.savefig('C:/Users/chris/plots/spider_societypax.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/spider_societypax.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()



## CM: Stakeholder manufacturers
data2 = [['Existing Transport Supply', '\nVehicle Technology', '\nTransport Demand'],
        ('', 
         [[0.1, 1.0, 0.5]])
        ]

N = len(data2[0])
theta = radar_factory(N, frame='polygon')

spoke_labels = data2.pop(0)
title, case_data = data2[0]

fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(projection='radar'))
#fig.subplots_adjust(top=0.85, bottom=0.05)

ax.set_rgrids([0.1, 0.5, 1.0])
#ax.set_title(title,  position=(0.5, 1.1), ha='center')

for d in case_data:
    line = ax.plot(theta, d)
    ax.fill(theta, d, alpha=0.25, label='_nolegend_')
ax.set_varlabels(spoke_labels)


#plt.savefig('C:/Users/chris/plots/spider_manufacturers.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/spider_manufacturers.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()


## CM: Stakeholder operators
data3 = [['Existing Transport Supply', '\nVehicle Technology', '\nTransport Demand'],
        ('', 
         [[0.5, 0.1, 1.0]])
        ]

N = len(data3[0])
theta = radar_factory(N, frame='polygon')

spoke_labels = data3.pop(0)
title, case_data = data3[0]

fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(projection='radar'))
#fig.subplots_adjust(top=0.85, bottom=0.05)

ax.set_rgrids([0.1, 0.5, 1.0])
#ax.set_title(title,  position=(0.5, 1.1), ha='center')

for d in case_data:
    line = ax.plot(theta, d)
    ax.fill(theta, d, alpha=0.25, label='_nolegend_')
ax.set_varlabels(spoke_labels)


#plt.savefig('C:/Users/chris/plots/spider_operators.png', dpi=1200, bbox_inches='tight', transparent=True) ## high-res for poster
plt.savefig('C:/Users/chris/plots/spider_operators.pdf', bbox_inches='tight', transparent=True) ## pdf for LaTeX
plt.show()
plt.clf()

