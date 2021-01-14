# %%
# Load data, preprocess them, plot them

import numpy as np
import matplotlib.pyplot as plt
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
#hs_s = const_s * g * tp_s ** 2 / (2 * math.pi)


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
axs[1].set_xlabel(tp_label)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
fig_rawdata.savefig('gfx/EnvironmentalDataset.pdf', bbox_inches='tight')

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
plt.show()


# %%
# Fit 3D joint distribution model and plot fits.

# Define the structure of the probabilistic model that will be fitted to the
# dataset.
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
dist_description_t = {'name': 'Lognormal_SigmaMu',
                      'dependency': (1,  None, 1), #Shape, Location, Scale
                      'functions': ('asymdecrease3', None, 'lnsquare2'), #Shape, Location, Scale
                      'min_datapoints_for_fit': 50
                      }


# Fit the model to the data.
fit = Fit((v, hs, tp),
          (dist_description_v, dist_description_hs, dist_description_t))
joint_dist = fit.mul_var_dist
dist_v = joint_dist.distributions[0]


fig1 = plt.figure(figsize=(12.5, 4), dpi=150)
ax1 = fig1.add_subplot(131)
ax2 = fig1.add_subplot(132)
ax3 = fig1.add_subplot(133)
plot_marginal_fit(v, dist_v, fig=fig1, ax=ax1, label='$v$ (m s$^{-1}$)', dataset_char='D')
plot_dependence_functions(fit=fit, fig=fig1, ax1=ax2, ax2=ax3, unconditonal_variable_label=v_label)
fig1.subplots_adjust(wspace=0.25, bottom=0.15)
figure_folder = 'gfx/'
figure_fname = figure_folder + 'FitVHs'
plt.savefig(figure_fname, dpi=dpi_for_printing_figures, facecolor='w', edgecolor='w',
        orientation='portrait', papertype=None, format=None,
        transparent=False, bbox_inches=None, pad_inches=0.1,
        frameon=None, metadata=None)

dist_t = joint_dist.distributions[2]
inspect_t = fit.multiple_fit_inspection_data[2]

marker_discrete='o'
markersize_discrete=5
markerfacecolor_discrete='lightgray'
markeredgecolor_discrete='k'
style_dependence_function='b-'
legend_fontsize=8
factor_draw_longer=1.1

fig2 = plt.figure(figsize=(12.5, 4), dpi=150)
ax1 = fig2.add_subplot(131)
sorted_hs = np.sort(hs)
sorted_hs = sorted_hs[0::1000] # In paper's figure with 1, for speed higher
n = sorted_hs.size
i = np.array(range(n)) + 1
pi = np.divide((i - 0.5), n)
theoretical_quantiles = joint_dist.marginal_icdf(pi, dim=1)
color_sample = 'k'
marker_sample = 'x'
marker_size = 10
color_fit = 'b'
plt.scatter(theoretical_quantiles, sorted_hs, c=color_sample, s=marker_size, 
    marker=marker_sample, linewidths=1)
plt.plot([0, max(theoretical_quantiles)], [0, max(theoretical_quantiles)], c=color_fit)
xlabel_string = 'Theoretical quantiles, $h_s$ (m)'
ylabel_string = 'Ordered values, $h_s$ (m)'
plt.xlabel(xlabel_string)
plt.ylabel(ylabel_string)
ax1.spines['right'].set_visible(False)
ax1.spines['top'].set_visible(False)

ax2 = fig2.add_subplot(132)
plt.sca(ax2)
dp_function =   r'$\ln(' + str('%.3g' % dist_t.scale.a) + \
                r'+' + str('%.3g' % dist_t.scale.b) + \
                r'\sqrt{h_s / g})$'
scale_at = inspect_t.scale_at
x1 = np.linspace(0, max(scale_at) * factor_draw_longer, 100)
plt.plot(scale_at, np.log(inspect_t.scale_value),
            marker_discrete,
            markersize=markersize_discrete,
            markerfacecolor=markerfacecolor_discrete,
            markeredgecolor=markeredgecolor_discrete,)
plt.plot(x1, np.log(dist_t.scale(x1)),
            style_dependence_function, label=dp_function)
plt.xlabel(hs_label)
plt.ylabel('$μ_{tz}$')
plt.legend(frameon=False, prop={'size': legend_fontsize})
ax2.spines['right'].set_visible(False)
ax2.spines['top'].set_visible(False)

ax3 = fig2.add_subplot(133)
plt.sca(ax3)
dp_function =   r'$' + str('%.4f' % dist_t.shape.a) + \
                r' + ' + str('%.3g' % dist_t.shape.b) + \
                r' / (1 + ' + str('%.3g' % dist_t.shape.c) + ' h_s )$'
shape_at = inspect_t.shape_at
x1 = np.linspace(0, max(shape_at) * factor_draw_longer, 100)
plt.plot(shape_at, inspect_t.shape_value,
            marker_discrete,
            markersize=markersize_discrete,
            markerfacecolor=markerfacecolor_discrete,
            markeredgecolor=markeredgecolor_discrete,)
plt.plot(x1, dist_t.shape(x1),
             style_dependence_function,
             label=dp_function)
plt.xlabel(hs_label)
plt.ylabel('$σ_{tz}$')
plt.legend(frameon=False, prop={'size': legend_fontsize})
ax3.spines['right'].set_visible(False)
ax3.spines['top'].set_visible(False)
figure_fname = figure_folder + 'FitHsTz'
plt.savefig(figure_fname, dpi=dpi_for_printing_figures, facecolor='w', edgecolor='w',
        orientation='portrait', papertype=None, format=None,
        transparent=False, bbox_inches=None, pad_inches=0.1,
        frameon=None, metadata=None)
#plt.show()

# %%
# Calculate isosurface where density is almost zero

from skimage.measure import marching_cubes_lewiner
from mpl_toolkits.mplot3d import Axes3D

v_step = 1.0
h_step = 0.2
t_step = 0.2
v1d = np.arange(0, 50, v_step)
vgrid, h, t = np.mgrid[0:50:v_step, 0:22:h_step, 0:22:t_step]
f = np.empty_like(vgrid)
for i in range(vgrid.shape[0]):
    for j in range(vgrid.shape[1]):
        for k in range(vgrid.shape[2]):
            f[i,j,k] = joint_dist.pdf([vgrid[i,j,k], h[i,j,k], t[i,j,k]])
print('Done with calculating f')


#iso_val = 1E-10 # 50-yr HDC has a density value of ca. 9.1 E-9
alpha = 1 / (50 * 365.25 * 24)

HDC = HighestDensityContour(fit.mul_var_dist, return_period=50,
    state_duration=1, limits=[(0, 50), (0, 25), (0, 25)])
print('50-yr HDC has a density value of ' + str(HDC.fm))
iso_val = HDC.fm

#verts, faces, _, _ = marching_cubes_lewiner(f, iso_val, 
#    spacing=(v_step, h_step, t_step))


#fig = plt.figure()
#ax = fig.add_subplot(111, projection='3d')
#ax.plot_trisurf(verts[:, 0], verts[:,1], faces, verts[:, 2], cmap='Spectral',
#                lw=1)
#ax.set_xlabel('Wind speed (m/s)')
#ax.set_ylabel('Significant wave height (m)')
#ax.set_zlabel('Zero-up-crossing period (s)')

# %%
# Plot some slices
import seaborn as sns

fig3 = plt.figure()
ax = fig3.add_subplot(111)

contours_at_v = [1, 5, 10, 15, 20, 25, 30, 35]
c = sns.color_palette(None, len(contours_at_v))

fig4, axs = plt.subplots(2, 4, sharex=True, sharey=True, 
    figsize=(8.5,5), dpi=300)
 
hs_axlim = 21
for i, axi in enumerate(axs):
    for j, subax in enumerate(axi):
        idx = i * 4 + j
        filter_v = contours_at_v[idx]
        v_ind = np.where(v1d == filter_v)
        v_ind = v_ind[0].astype(int)[0]
        CS = ax.contour(t[v_ind,:,:], h[v_ind,:,:], f[v_ind,:,:], 
            [iso_val], colors=[c[idx]])
        CSsub = subax.contour(t[v_ind,:,:], h[v_ind,:,:], f[v_ind,:,:], 
            [iso_val], colors=[c[idx]])
        fmt = {}
        strs = [f'{filter_v} m/s']
        for l, s in zip(CS.levels, strs):
            fmt[l] = s
        ax.clabel(CS, CS.levels, fmt=fmt, inline=True, fontsize=8)
        subax.clabel(CSsub, CS.levels, fmt=fmt, inline=True, fontsize=8)
        v_threshold = 0.5
        mask = (v > filter_v - v_threshold) & (v < filter_v + v_threshold)
        subax.scatter(tp[mask], hs[mask], c='black', s=5, alpha=0.5, 
            zorder=-2, rasterized=True)
        subax.spines['right'].set_visible(False)
        subax.spines['top'].set_visible(False)
ax.scatter(tp, hs,c='black', s=5, alpha=0.5, zorder=-2, rasterized=True)
ax.plot([3, 3], [0, hs_axlim], '--k')
ax.text(2.5, 10, 'Eigenfrequency', fontsize=8, rotation=90,
    verticalalignment='center')
ax.set_ylim([0, hs_axlim])
ax.set_xlim([0, 20])
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.set_xlabel(tp_label)
ax.set_ylabel(hs_label)

fs = 10
fig4.tight_layout(rect=(0.075,0.1,1,1))
fig4.text(0.56, 0.075, tp_label,
         ha='center', 
         fontsize=fs, 
         weight='bold')
fig4.text(0.04, 0.56, hs_label,
         va='center', 
         rotation='vertical', 
         fontsize=fs, 
         weight='bold')


fig3.tight_layout()
fig3.savefig('gfx/DensityAlmost0AtDifferentWindSpeeds.pdf', 
bbox_inches='tight')
fig4.savefig('gfx/DensityAlmost0AtDifferentWindSpeedsSubplots.pdf', 
    bbox_inches='tight')

# %%
# Calculate a 2D wind-wave contour.

# Define the structure of the 2D joint distribution
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
fit2D = Fit((v, hs), (dist_description_v, dist_description_hs))
dist2D = fit2D.mul_var_dist
print('Done with fitting the 2D joint distribution')

limits = [(0, 45), (0, 25)]
deltas = [0.05, 0.05]
HDC2D = HighestDensityContour(dist2D, return_period=50, state_duration=3, 
    limits=limits, deltas=deltas)
print('Done with calcluating the 2D HDC')

v_step = 0.1
h_step = 0.1
vgrid, hgrid = np.mgrid[0:45:v_step, 0:22:h_step]
f = np.empty_like(vgrid)
for i in range(vgrid.shape[0]):
    for j in range(vgrid.shape[1]):
        f[i,j] = dist2D.pdf([vgrid[i,j], hgrid[i,j]])
print('Done with calculating f')

fig5, ax = plt.subplots(1,1, figsize=(5,5), dpi=300)
ax.scatter(v, hs, c='black', s=5, alpha=0.5, rasterized=True)
CS = ax.contour(vgrid, hgrid, f, [HDC2D.fm], colors='blue')

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
dc_v = np.arange(3, 25.1, 2)
dc_v = np.append(dc_v, [26, 30, 35])
dc_hs = np.interp(dc_v, contour_v_upper, contour_hs_upper)

ax.plot(dc_v, dc_hs, 'ob')


ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.set_xlim([0, 40])
ax.set_ylim([0, 16])
ax.set_xlabel(v_label)
ax.set_ylabel(hs_label)

fig5.savefig('gfx/WindWaveHDC.pdf', bbox_inches='tight')

plt.show()
# %%
