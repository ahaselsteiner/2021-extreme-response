import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import interp1d

from viroconcom.read_write import read_contour
from matplotlib.patches import Polygon

v_label = 'Wind speed (m/s)'
hs_label = 'Significant wave height (m)'
r_label = 'Response, e.g. overturning moment'
fs = 8 # Font size for within figure

v_pp = np.array([0, 5, 14, 15, 18, 20, 25])
r_pp = np.array([0, 4, 14, 15, 15, 14, 12])

fr = interp1d(v_pp, r_pp, kind='cubic')
v_pp_fine = np.linspace(0, 25, num=50, endpoint=True)
v_pa_fine = np.linspace(25.01, 41, num=30, endpoint=True)

v_pa = np.arange(25.1, 41, 1) # Parked mode
r_pa = 0.008 * np.square(v_pa)

v = np.hstack((v_pp_fine, v_pa)).ravel()
r = np.hstack((fr(v_pp_fine), r_pa)).ravel()

r = r / max(r)

fig, axs = plt.subplots(2,1, figsize=(5,8), sharex=True)
axs[0].plot(v, r, c='black')
axs[0].plot([25, 25], [0, 1.1], '--k', linewidth=0.8)
axs[0].text(23.5, 0.25, 'Cut-out wind speed', fontsize=fs, rotation=90,
    verticalalignment='center')
axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[0].set_ylabel(r_label)
axs[0].set_ylim([0, 1.1])

c = read_contour('doe_john_dataset_d_50.txt')
contour_hs = c[0]
contour_v = c[1] * (90/10) ** 0.14 # Convert wind speed to hub height.
contour_v = contour_v * 0.95 # Convert 10-min wind speed to 1-hr wind speed.
axs[1].plot(np.append(contour_v, contour_v[0]), np.append(contour_hs, contour_hs[0]), 
    '--b', label='Environmental contour')

axs[1].annotate('environmental contour', xy=(7.9, 5.3), xytext=(8, 3),
            arrowprops=dict(arrowstyle="->", color='blue'), size=fs, c='blue')
fsurface_v_pp  = [0,  5,  14,  15,   18,  20,  25]
fsurface_hs_pp = [13, 12, 8.3, 8.0,  8.0, 8.5, 10]
fsurface_v_pa  = [25.01, 34, 40, 41]
fsurface_hs_pa = [12,   10, 3, 0]
fhs_pp = interp1d(fsurface_v_pp, fsurface_hs_pp, kind='cubic')
fhs_pa = interp1d(fsurface_v_pa, fsurface_hs_pa, kind='quadratic')
fsurface_v = np.hstack((v_pp_fine, v_pa_fine)).ravel()
fsurface_hs = np.hstack((fhs_pp(v_pp_fine), fhs_pa(v_pa_fine))).ravel()

verts = [(0, 15), *zip(fsurface_v, fsurface_hs), (45, 15)]
poly = Polygon(verts, facecolor='salmon', edgecolor='red', linewidth=0, label='Failure region')
axs[1].add_patch(poly)
axs[1].text(17, 10.5, 'failure region', horizontalalignment='center', c='black', size=fs)
axs[1].plot(fsurface_v, fsurface_hs, c='red', label='Failure surface')
axs[1].annotate('failure surface', xy=(14, 8.5), xytext=(3, 7),
            arrowprops=dict(arrowstyle="->", color='red'), size=fs, c='red')
axs[1].plot([25, 25], [0, 14], '--k', linewidth=0.8)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
axs[1].set_xlabel(v_label)
axs[1].set_ylabel(hs_label)
axs[1].set_xlim([0, 40])
axs[1].set_ylim([0, 13])


fig.savefig('ProblemFigure.pdf', bbox_inches='tight')
plt.show()
