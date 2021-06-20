import numpy as np
from numpy import cos, pi
from skimage.measure import marching_cubes_lewiner
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

from viroconcom.distributions import ExponentiatedWeibullDistribution

def fv(v):
    alpha = 12.9
    beta = 2.42
    delta = 0.761
    F = ExponentiatedWeibullDistribution(scale=alpha, shape=beta, shape2=delta)
    f = 0
    return f

def fhs(v, hs):
    f = 0
    return f

def ftz(tz, hs):
    f = 0
    return f

def fvhstz(v, hs, tp):
    f = fv * fhs(hs, v) * ftz(tz, hs)
    return f


x, y, z = pi*np.mgrid[-1:1:31j, -1:1:31j, -1:1:31j]
vol = cos(x) + cos(y) + cos(z)
iso_val=0.0
verts, faces, _, _ = marching_cubes_lewiner(vol, iso_val, spacing=(0.1, 0.1, 0.1))

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.plot_trisurf(verts[:, 0], verts[:,1], faces, verts[:, 2], cmap='Spectral',
                lw=1)
plt.show()
