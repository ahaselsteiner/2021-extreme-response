# %%
# Load data, preprocess them, plot them

import numpy as np
import matplotlib.pyplot as plt
import csv, math
import pandas as pd

from viroconcom.fitting import Fit
from viroconcom.plot import plot_marginal_fit, plot_dependence_functions
from viroconcom.contours import IFormContour, HighestDensityContour, sort_points_to_form_continous_line
from viroconcom.read_write import write_contour


dpi_for_printing_figures = 300

v = list()
hs = list()

path = 'DForNREL.txt'
with open(path, newline='') as csv_file:
    reader = csv.reader(csv_file, delimiter=';')
    idx = 0
    for row in reader:
        if idx == 0:
            v_label = row[1][1:] # Ignore first char (is a white space).
            hs_label = row[2][1:] # Ignore first char (is a white space).
        if idx > 0: # Ignore the header
            v.append(float(row[1]))
            hs.append(float(row[2]))
        idx = idx + 1

hs = np.array(hs)
v = np.array(v) # This is the 1-hr wind speed at hub height, see IEC 61400-1:2019 p. 34

# %%
# Calculate a 2D wind-wave contour.

# Define the structure of the 2D joint distribution
dist_description_v = {'name': 'Weibull_Exp',
                      'dependency': (None, None, None, None),
                      'width_of_intervals': 2}
dist_description_hs = {'name': 'Weibull_Exp',
                       'fixed_parameters': (None, None, None, 5),
                       # shape, location, scale, shape2
                       'dependency': (0, None, 0, None),
                       # shape, location, scale, shape2
                       'functions': ('logistics4', None, 'alpha3', None),
                       # shape, location, scale, shape2
                       'min_datapoints_for_fit': 50,
                       'do_use_weights_for_dependence_function': True}

# Fit the model to the data.
fit = Fit((v, hs), (dist_description_v, dist_description_hs))
joint_dist = fit.mul_var_dist
print('Done with fitting the 2D joint distribution')

# Show goodness of fit plot.
dist_v = joint_dist.distributions[0]
fig_fit = plt.figure(figsize=(12.5, 4), dpi=150)
ax1 = fig_fit.add_subplot(131)
ax2 = fig_fit.add_subplot(132)
ax3 = fig_fit.add_subplot(133)
plot_marginal_fit(v, dist_v, fig=fig_fit, ax=ax1, label='$v$ (m s$^{-1}$)', dataset_char='D')
plot_dependence_functions(fit=fit, fig=fig_fit, ax1=ax2, ax2=ax3, unconditonal_variable_label=v_label)
fig_fit.subplots_adjust(wspace=0.25, bottom=0.15)
figure_folder = 'gfx/'
figure_fname = figure_folder + 'FitVHs'
#fig_fit.savefig(figure_fname + '.pdf', bbox_inches='tight')
fig_fit.savefig(figure_fname, dpi=dpi_for_printing_figures, bbox_inches='tight')


IFORMC = IFormContour(joint_dist, return_period=50, state_duration=1)

limits = [(0, 45), (0, 25)]
deltas = [0.05, 0.05]
HDC2D = HighestDensityContour(joint_dist, return_period=50, state_duration=1, 
    limits=limits, deltas=deltas)
print('Done with calcluating the 2D HDC')

v_step = 0.1
h_step = 0.1
vgrid, hgrid = np.mgrid[0:45:v_step, 0:22:h_step]
f = np.empty_like(vgrid)
for i in range(vgrid.shape[0]):
    for j in range(vgrid.shape[1]):
        f[i,j] = joint_dist.pdf([vgrid[i,j], hgrid[i,j]])
print('Done with calculating f')


fig, ax = plt.subplots(1,1, figsize=(5,5), dpi=300)
ax.scatter(v, hs, c='black', s=5, alpha=0.5, rasterized=True)
dc_v = np.array([np.arange(3, 37.1, 2), np.arange(3, 37.1 + 0.1, 2)])
dc_hs = np.empty(dc_v.shape)
for i in range(2):
    if i == 0:
        contour_v = IFORMC.coordinates[0]
        contour_hs = IFORMC.coordinates[1]
    else:
        contour_v = HDC2D.coordinates[0]
        contour_hs = HDC2D.coordinates[1]

    # Get the frontier interval and sort it.
    mask = ((contour_v < 25) & (contour_hs > 2)) | ((contour_v >= 25) & (contour_hs > 8))
    contour_v_upper = contour_v[mask]
    contour_hs_upper = contour_hs[mask]
    p = contour_v_upper.argsort()
    contour_v_upper = contour_v_upper[p]
    contour_hs_upper = contour_hs_upper[p]

    # Select design conditons along the frontier interval, one condition per 1 s Tz.
    dc_hs[i,:] = np.interp(dc_v[i,:], contour_v_upper, contour_hs_upper)


    if i == 0:
        ax.plot(np.append(contour_v, contour_v[0]), np.append(contour_hs, contour_hs[0]), '-b')
        ax.plot(dc_v[i,:], dc_hs[i,:], 'ob', label='IFORM')
    else:
        CS = ax.contour(vgrid, hgrid, f, [HDC2D.fm], colors='red')
        ax.plot(dc_v[i,:], dc_hs[i,:], 'or', label='Highest density')

    if i == 0:
        csv_name = 'iform_wind_wave.csv'
    else:
        csv_name = 'hdc_wind_wave.csv'
    
    # Write contour coordinates into a CSV file
    write_contour(dc_v[i,:], dc_hs[i,:], csv_name, label_x=v_label, label_y=hs_label)
    
    # Print coordinates to to copy them into matlab
    print('V: ')
    print(dc_v[i,:])
    print('Hs: ')
    print(dc_hs[i,:])

ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.set_xlim([0, 40])
ax.set_ylim([0, 16])
ax.set_xlabel(v_label)
ax.set_ylabel(hs_label)
ax.legend()
fig.savefig('gfx/Contour_50yr.pdf', bbox_inches='tight')

# Print coordinates in table: V_1h_hub, Tp at 1/15 steepness.
const_s = 1.0 / 15
g = 9.81
tp_iform = np.sqrt((2 * math.pi * dc_hs[0,:]) / (g * const_s))
tp_hdc = np.sqrt((2 * math.pi * dc_hs[1,:]) / (g * const_s))
tbl = pd.DataFrame(np.vstack((dc_v[0,:], dc_hs[0,:], tp_iform, dc_v[1,:], dc_hs[1,:], tp_hdc)).transpose(), 
                columns=['IFORM: V (m/s)', 'H_s (m)', 'T_p (s)', 'HDC: V (m/s)', 'H_s (m)', 'T_p (s)'])
print(tbl.to_latex(formatters=[
    lambda x : '%.2g' % x, # v
    lambda x : '%.2f' % x, # hs
    lambda x : '%.2f' % x, # tp
    lambda x : '%.2g' % x, # v
    lambda x : '%.2f' % x, # hs
    lambda x : '%.2f' % x, # tp
],
column_format='lllllll',
index=False,
escape=False))

#plt.show()
# %%