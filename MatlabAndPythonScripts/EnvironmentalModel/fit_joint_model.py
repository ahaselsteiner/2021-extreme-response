# %%
# Load data, preprocess them, plot them

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import csv, math

from viroconcom.fitting import Fit
from viroconcom.plot import plot_marginal_fit, plot_dependence_functions
from viroconcom.contours import HighestDensityContour, sort_points_to_form_continous_line


dpi_for_printing_figures = 300

v = list()
hs = list()
tz = list()
tp = list()

path = 'DForNREL.txt'
with open(path, newline='') as csv_file:
    reader = csv.reader(csv_file, delimiter=';')
    idx = 0
    for row in reader:
        if idx == 0:
            v_label = row[1][1:] # Ignore first char (is a white space).
            hs_label = row[2][1:] # Ignore first char (is a white space).
            tz_label = row[3][1:] # Ignore first char (is a white space).
        if idx > 0: # Ignore the header
            v.append(float(row[1]))
            hs.append(float(row[2]))
            tz.append(float(row[3]))
        idx = idx + 1
tp_label = 'Spectral peak period (s)'

hs = np.array(hs)
v = np.array(v) # This is the 1-hr wind speed at hub height, see IEC 61400-1:2019 p. 34
tz = np.array(tz)
tp = 1.2796 * tz # Assuming a JONSWAP spectrum with gamma = 3.3

# Calculate a constant steepness curve
const_s = 1 / np.array([15])
hs_s = np.arange(0.1, 11, 0.2)
g = 9.81
steepness = 2 * math.pi * hs / ( g * tp ** 2)
steepness_label = 'Peak steepness (-)'
tp_s = np.sqrt((2 * math.pi * hs_s) / (g * const_s))


fig_rawdata, axs = plt.subplots(1, 2, figsize=(8, 4), dpi=300, sharey=True)
axs[0].scatter(v, hs, c='black', s=5, alpha=0.5, rasterized=True)
axs[0].set_xlabel(v_label)
axs[0].set_ylabel(hs_label)
axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].scatter(tp, hs, c='black', s=5, alpha=0.5, rasterized=True)
axs[1].plot(tp_s, hs_s, c='blue')
axs[1].text(8, 8, 'Steepness = 1/15', fontsize=8, rotation=71,
    horizontalalignment='center', verticalalignment='center',
    c='blue')
const_ss =  1 / np.array([20, 30, 40, 50])
for const_s in const_ss:
    tp_s = np.sqrt((2 * math.pi * hs_s) / (g * const_s))
    axs[1].plot(tp_s, hs_s, c='blue')
axs[1].text(11.5, 11.1, '1/20', fontsize=8, horizontalalignment='center', 
    c='blue')
axs[1].text(14.2, 11.1, '1/30', fontsize=8, horizontalalignment='center', 
    c='blue')
axs[1].text(16.7, 11.1, '1/40', fontsize=8, horizontalalignment='center', 
    c='blue')
axs[1].text(18.9, 11.1, '1/50', fontsize=8, horizontalalignment='center', 
    c='blue')
axs[1].set_xlabel(tp_label)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
fig_rawdata.savefig('gfx/EnvironmentalDataset.pdf', bbox_inches='tight')

fig_sim_points, axs = plt.subplots(1, 2, figsize=(9,4), dpi=300, sharey=True)
inc = 2
hs_sim = np.append(0, np.arange(1, 15 + inc, inc))
inc = 2
v_sim = np.append(0, np.arange(1, 25 + inc, inc))
v_sim = np.append(v_sim, np.array([26, 30, 35, 40, 45]))
vgrid, hsgrid = np.meshgrid(v_sim, hs_sim)
axs[0].scatter(v, hs, c='black', s=5, alpha=0.5, rasterized=True)
axs[0].scatter(vgrid, hsgrid, c='red', s=10)

verts = [(-0.5, 8), (8, 8), (8, 10), (16, 10), (16, 12), (20, 12), (20, 15.5), (-0.5, 15.5)]
poly = Polygon(verts, facecolor='1', edgecolor='1')
axs[0].add_patch(poly)

axs[0].set_xlabel(v_label)
axs[0].set_ylabel(hs_label)
axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].scatter(tp, hs, c='black', s=5, alpha=0.5, rasterized=True)
hs_s = np.arange(0, 15, 0.1)
sps = [1/15, 1/20]
for i in range(2):
    sp = sps[i]
    tp_s = np.sqrt((2 * math.pi * hs_s) / (g * sp))
    axs[1].plot(tp_s, hs_s, c='blue', zorder=9)
    tp_sim = np.sqrt((2 * math.pi * hs_sim) / (g * sp))
    axs[1].scatter(tp_sim, hs_sim, c='red', s=10, zorder=10)
add_to_tp = [8, 20]
for i in range(2):
    axs[1].plot(tp_s + 1 / (1 + np.power(hs_s + 2, 0.5)) * add_to_tp[i], hs_s, c='blue', zorder=9)
    axs[1].scatter(tp_sim + 1 / (1 + np.power(hs_sim + 2, 0.5)) * add_to_tp[i], hs_sim, c='red', s=10, zorder=10)

axs[1].set_xlabel(tp_label)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
fig_sim_points.savefig('gfx/SimulationPoints.pdf', bbox_inches='tight')


fig_steepness, axs = plt.subplots(1,3, figsize=(13,4), dpi=300)
axs[0].scatter(hs, steepness, c='black', s=5, alpha=0.5, rasterized=True)
axs[0].plot([0, 17], [1/15, 1/15], '--k')
axs[0].text(15, 1/15*1.04, '1/15', c='black')
axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[0].set_xlabel(hs_label)
axs[0].set_ylabel(steepness_label)

# Define a hs - steepness bivariate model
dist_description_hs = {'name': 'Weibull_Exp'} # Order: shape, loc, scale, shape2
dist_description_s =  {'name': 'Weibull_3p'}

from scipy.stats import weibull_min
from viroconcom.distributions import WeibullDistribution
from viroconcom.distributions import ExponentiatedWeibullDistribution
from viroconcom.distributions import MultivariateDistribution
from viroconcom.params import FunctionParam

params = weibull_min.fit(steepness, floc=0.005)
my_loc = FunctionParam('poly1', 0.0015, 0.002, None)
dist_s = WeibullDistribution(shape=params[0], loc=my_loc, scale=params[2])
dist_hs = ExponentiatedWeibullDistribution()
dist_hs.fit(hs)
joint_dist = MultivariateDistribution(distributions=[dist_hs, dist_s], 
    dependencies=[(None, None, None, None), (None, 0, None)])


# Fit the model to the data.
#fit = Fit((hs, steepness),
#          (dist_description_hs, dist_description_s))
#joint_dist = fit.mul_var_dist

trs = [1, 50, 250]
fms = np.empty(shape=(3, 1))
for i, tr in enumerate(trs):
    HDC = HighestDensityContour(joint_dist, return_period=tr, 
        state_duration=1, limits=[(0, 20), (0, 0.1)])
    fms[i] = HDC.fm

h_step = 0.05
s_step = 0.00025
h_grid, s_grid = np.mgrid[0:18:h_step, 0:0.08:s_step]
f = np.empty_like(h_grid)
for i in range(h_grid.shape[0]):
    for j in range(h_grid.shape[1]):
            f[i,j] = joint_dist.pdf([h_grid[i,j], s_grid[i,j]])
print('Done with calculating f')

axs[2].scatter(tp, hs, c='black', s=5, alpha=0.5, rasterized=True)
axs[2].spines['right'].set_visible(False)
axs[2].spines['top'].set_visible(False)
axs[2].set_xlabel(tp_label)
axs[2].set_ylabel(hs_label)

colors = ['red', 'blue', 'green']
labels = ['1-yr', '50-yr', '250-yr']
for i, (fm, c, l) in enumerate(zip(fms, colors, labels)):
    CS = axs[0].contour(h_grid, s_grid, f, [fm], 
        colors=c, label=[l])
    # Now transform the contour to tp
    hs_s_contour = CS.allsegs[0][0]
    hs_contour = hs_s_contour[:, 0]
    s_contour = hs_s_contour[:, 1]
    tp_contour = np.sqrt((2 * math.pi * hs_contour) / (g * s_contour)) 
    axs[2].plot(tp_contour, hs_contour, c=c)

sorted_s = np.sort(steepness)
sorted_s = sorted_s[0::100]
n = sorted_s.size
i = np.array(range(n)) + 1
pi = np.divide((i - 0.5), n)
steepness_dist = joint_dist.distributions[1]
#theoretical_quantiles = steepness_dist.i_cdf(pi)
theoretical_quantiles = joint_dist.marginal_icdf(pi, dim=1)

color_sample = 'k'
marker_sample = 'x'
marker_size = 10
color_fit = 'b'
axs[1].scatter(theoretical_quantiles, sorted_s, c=color_sample, s=marker_size, 
    marker=marker_sample, linewidths=1, alpha=0.5, rasterized=True)
axs[1].plot([0, max(theoretical_quantiles)], [0, max(theoretical_quantiles)], c=color_fit)
xlabel_string = 'Theoretical quantiles, steepness (-)'
ylabel_string = 'Ordered values, steepness (-)'
axs[1].set_xlabel(xlabel_string)
axs[1].set_ylabel(ylabel_string)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)


fig_steepness.savefig('gfx/Steepness.pdf', bbox_inches='tight')
#plt.show()


# %%
# Fit joint distribution and plot fits.

# Define the structure of the joint model.
dist_description_v = {'name': 'Weibull_Exp',
                      'dependency': (None, None, None, None),
                      'width_of_intervals': 2}
dist_description_hs = {'name': 'Weibull_Exp',
                       'width_of_intervals': 0.5,
                       'fixed_parameters': (None, None, None, 5),
                       # shape, location, scale, shape2
                       'dependency': (0, None, 0, None),
                       # shape, location, scale, shape2
                       'functions': ('logistics4', None, 'alpha3', None),
                       # shape, location, scale, shape2
                       'min_datapoints_for_fit': 50,
                       'do_use_weights_for_dependence_function': True}


# Fit the model to the data.
fit = Fit((v, hs),
          (dist_description_v, dist_description_hs))
joint_dist = fit.mul_var_dist
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
fig_fit.savefig(figure_fname, dpi=dpi_for_printing_figures, facecolor='w', edgecolor='w',
        orientation='portrait', papertype=None, format=None,
        transparent=False, bbox_inches=None, pad_inches=0.1,
        frameon=None, metadata=None)

#plt.show()