vv = [0:1:45];    
hss = [0:0.5:15];
tpid = 2;
[vmesh, hmesh] = meshgrid(vv, hss);

R = ResponseEmulator();
r = R.ICDF1hr(vmesh, hmesh, R.tp(hmesh, tpid), 0.5);

B = ResponseEmulator10mWaterDepth;
b = B.ICDF1hr(vmesh, hmesh, B.tp(hmesh, tpid), 0.5);

fig = figure('position', [100, 100, 1100, 450]);
layout = tiledlayout(1, 2);
nexttile();
mesh(vmesh, hmesh, b / 1E6, 'edgecolor', 'k')
ylabel('Significant wave height (m)')
xlabel('1-hour wind speed (m s^{-1})')
zlabel('Median 1-hour maximum 10-m moment (MNm)');
nexttile();
mesh(vmesh, hmesh, r / 1E6, 'edgecolor', 'k')
ylabel('Significant wave height (m)')
xlabel('1-hour wind speed (m s^{-1})')
zlabel('Median 1-hour maximum 30-m moment (MNm)');

fig.Renderer = 'Painters';
exportgraphics(fig, 'gfx/response_mesh.pdf')
exportgraphics(fig, 'gfx/response_mesh.jpg', 'Resolution', 300)
