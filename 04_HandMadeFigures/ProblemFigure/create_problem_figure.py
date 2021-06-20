import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import interp1d

from virocon import (read_ec_benchmark_dataset, get_OMAE2020_V_Hs, 
    GlobalHierarchicalModel, IFORMContour)
from matplotlib.patches import Polygon

v_label = '10-min mean wind speed (m s$^{-1}$)'
hs_label = 'Significant wave height (m)'
r_label = 'Response, e.g. overturning moment'
fs = 8 # Font size for within figure

v_pp = np.array([0, 5, 14, 15, 18, 20, 25])
r_pp = np.array([0, 4, 14, 15, 15, 14, 12])

fr = interp1d(v_pp, r_pp, kind='cubic')
v_pp_fine = np.linspace(0, 25, num=50, endpoint=True)
v_pa_fine = np.linspace(25.01, 51, num=30, endpoint=True)

v_pa = np.arange(25.1, 51, 1) # Parked mode
r_pa = 0.0055 * np.square(v_pa)

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

# Load data, fit joint model, compute contour.
data = read_ec_benchmark_dataset('ec-benchmark_dataset_D.txt')
dist_descriptions, fit_descriptions, semantics = get_OMAE2020_V_Hs()
model = GlobalHierarchicalModel(dist_descriptions)
model.fit(data, fit_descriptions)
c = IFORMContour(model, 1/(50 * 365.25 * 24))

contour_v = c.coordinates[:,0] / 0.95  
contour_hs = c.coordinates[:,1]
contour_v = contour_v * (90/10) ** 0.14 # Convert wind speed to hub height.

axs[1].plot(np.append(contour_v, contour_v[0]), np.append(contour_hs, contour_hs[0]), 
    '--b', label='Environmental contour')

axs[1].annotate('environmental contour', xy=(7.4, 4.6), xytext=(3, 2.5),
            arrowprops=dict(arrowstyle="->", color='blue'), size=fs, c='blue')
fsurface_v_pp  = [0,  5,  14,  16,  20,  25]
fsurface_hs_pp = [13, 12, 7.3, 6.2,  8.4, 11]
fsurface_v_pa  = [25.01, 27, 35, 41, 51]
fsurface_hs_pa = [15, 14.9, 14.5, 13.2, 0]
fhs_pp = interp1d(fsurface_v_pp, fsurface_hs_pp, kind='cubic')
fhs_pa = interp1d(fsurface_v_pa, fsurface_hs_pa, kind='quadratic')
fsurface_v = np.hstack((v_pp_fine, v_pa_fine)).ravel()
fsurface_hs = np.hstack((fhs_pp(v_pp_fine), fhs_pa(v_pa_fine))).ravel()

verts = [(0, 16), *zip(fsurface_v, fsurface_hs), (50, 16)]
poly = Polygon(verts, facecolor='salmon', edgecolor='red', linewidth=0, label='Failure region')
axs[1].add_patch(poly)
axs[1].text(16, 12.5, 'failure region', horizontalalignment='center', c='black', size=fs)
axs[1].plot(fsurface_v, fsurface_hs, c='red', label='Failure surface')
axs[1].annotate('failure surface', xy=(8.8, 10.6), xytext=(1, 8.2),
            arrowprops=dict(arrowstyle="->", color='red'), size=fs, c='red')
axs[1].plot([25, 25], [0, 14], '--k', linewidth=0.8)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
axs[1].set_xlabel(v_label)
axs[1].set_ylabel(hs_label)
axs[1].set_xlim([0, 50])
axs[1].set_ylim([0, 16])

fig.savefig('ProblemFigure.svg', bbox_inches='tight')
fig.savefig('ProblemFigure.pdf', bbox_inches='tight')
plt.show()
