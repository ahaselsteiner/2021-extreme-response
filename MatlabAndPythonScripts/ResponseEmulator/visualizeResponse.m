R = ResponseEmulator;
FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)

tp_temp = [3:1:20];
v_temp = [0:1:50];
hs_temp = [0:0.5:9];


[tmesh, vmesh, hmesh] = meshgrid(tp_temp, v_temp, hs_temp);
sigmas = R.sigma(vmesh, hmesh, tmesh);
mus = R.mu(vmesh, hmesh, tmesh);
rmedian = R.ICDF1hr(vmesh, hmesh, tmesh, 0.5);

figure
hss = 0;
tpp = 10;
t = tiledlayout(3, 1);
nexttile
plot(vv, R.k(vv, hss));
ylabel('k (-)');
nexttile
plot(vv, R.mu(vv, hss, tpp));
ylabel('\mu');
nexttile
plot(vv, R.sigma(vv, hss, tpp));
ylabel('\sigma');
xlabel('v_{1hr} (m/s)');
sgtitle(['hs = ' num2str(hss) ', tp = ' num2str(tpp)]);


% Plot response of v curves.
figure('Position', [100 100 500 600])
t = tiledlayout(2, 1);
% Plot result from simulation
ax1 = nexttile
addpath('03_Calm_Sea_Complete_Wind')
load 'CalmSeaComplete.mat';
OvrAllSeeds = [Ovr_S1; Ovr_S2; Ovr_S3; Ovr_S4; Ovr_S5; Ovr_S6];
OvrAllSeeds = OvrAllSeeds(:, 1:18);
vv = vv(1:18);
hold on
ms = 50;
for i = 1 : 6
    h = scatter(vv, OvrAllSeeds(i,:), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
for tpi = 1 : 4
    h = scatter(v(1:14), squeeze(max(Ovr(1:14, 1, tpi, :), [], 4)), ms, 'MarkerFaceColor', [0 0 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
meanOvr = mean(OvrAllSeeds);
plot(vv, meanOvr, '-k', 'linewidth', 2);
FT = fittype('a * x.^2');
fitted_curve = fit(vv(vv > 25)', meanOvr(vv > 25)', FT);
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
fit_string = [num2str(round(fitted_curve.a)) ' * v^2'];
legend({'Simulation seed', 'Average over seeds', fit_string}, 'location', 'southeast');
legend box off
xlabel('');
ylabel('');
title('Aeroelastic simulation, h_s = 0 m');
% Plot results from emulator
ax2 = nexttile
hold on
n = 6;
r = nan(length(vv), n);
for i = 1 : length(vv)
    r(i, :) = R.randomSample1hr(vv(i), 0, 0, n);
end
for i = 1 : n
    h = scatter(vv, r(:, i), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
meanR = mean(r');
plot(vv, meanR, '-k', 'linewidth', 2);
FT = fittype('a * x.^2');
fitted_curve = fit(vv(vv > 25)', meanR(vv > 25)', FT);
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
fit_string = [num2str(round(fitted_curve.a)) ' * v^2'];
legend({'Simulation seed', 'Average over seeds', fit_string}, 'location', 'southeast');
legend box off
xlabel('');
ylabel('');
linkaxes([ax1 ax2],'xy')
xlabel(t, '1-hr wind speed (m/s)');
ylabel(t, 'Max 1-hr overturning moment (Nm)');
t.TileSpacing = 'compact';
title('Statistical response emulator, h_s = 0 m');

exportgraphics(gcf, 'gfx/ResponseAtCalmSea.jpg') 
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.pdf') 

fig = figure('position', [100, 100, 900, 400]);
clower = 7.3E6;
cupper = max(max(max(rmedian)));
t = tiledlayout(1, 2);
nexttile
vslice = [10];   
hslice = [];
tslice = [3 7 15];
slice(tmesh, vmesh, hmesh, rmedian, tslice, vslice, hslice)
caxis([clower cupper]);
ylabel('1-hour wind speed (m/s)');
zlabel('Significant wave height (m)');
xlabel('Peak period (s)');
view(3)

nexttile
vv = [0:0.2:50];
hss = [0:0.1:9];
[vmesh, hmesh] = meshgrid(vv, hss);
tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
sigmas = R.sigma(vmesh, hmesh, tpbreaking(hmesh));
mus = R.mu(vmesh, hmesh, tpbreaking(hmesh));
rmedian = R.ICDF1hr(vmesh, hmesh, tpbreaking(hmesh), 0.5);
contourf(vmesh, hmesh, rmedian, 10)
hold on
caxis([clower cupper]);
c = colorbar;
c.Label.String = 'Median maximum 1-hr oveturning moment (Nm) ';
c.Layout.Tile = 'east';
xlabel('1-hour wind speed (m/s)');
ylabel('Significant wave height (m)');
exportgraphics(fig, 'gfx/MedianResponseFullField.jpg') 
exportgraphics(fig, 'gfx/MedianResponseFullField.pdf') 

