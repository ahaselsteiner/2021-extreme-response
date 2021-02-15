R = ResponseEmulator;

tp = [3:1:20];
v = [0:1:50];
hs = [0:0.5:9];


[tmesh, vmesh, hmesh] = meshgrid(tp, v, hs);
sigmas = R.sigma(vmesh, hmesh, tmesh);
mus = R.mu(vmesh, hmesh, tmesh);
rmedian = R.ICDF1hr(vmesh, hmesh, tmesh, 0.5);

figure
subplot(2, 1, 1);
plot(v, R.mu(v, 3, 10));
ylabel('mu');
subplot(2, 1, 2);
plot(v, R.sigma(v, 3, 10));
ylabel('sigma');
xlabel('v_{1hr} (m/s)');


% Plot response of v curves.
figure('Position', [100 100 500 600])
vv = [3:2:25 26 30 35 40 45 50];
% Plot result from simulation
nexttile
addpath('03_Calm_Sea_Complete_Wind')
load 'CalmSeaComplete.mat';
OvrAllSeeds = [Ovr_S1; Ovr_S2; Ovr_S3; Ovr_S4; Ovr_S5; Ovr_S6];
OvrAllSeeds = OvrAllSeeds(:, 1:18);
hold on
ms = 50;
for i = 1 : 6
    h = scatter(vv, OvrAllSeeds(i,:), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
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
ylim([0 16 * 10^7]);
xlabel('1-hr wind speed (m/s)');
ylabel('Max 1-hr overturning moment (Nm)');
fit_string = [num2str(round(fitted_curve.a)) ' * v^2'];
legend({'Simulation seed', 'Average over seeds', fit_string}, 'location', 'southeast');
legend box off
title('Aeroelastic simulation');
% Plot results from emulator
nexttile
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
meanR= mean(r');
plot(vv, meanR, '-k', 'linewidth', 2);
FT = fittype('a * x.^2');
fitted_curve = fit(vv(vv > 25)', meanR(vv > 25)', FT);
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
fit_string = [num2str(round(fitted_curve.a)) ' * v^2'];
legend({'Simulation seed', 'Average over seeds', fit_string}, 'location', 'southeast');
legend box off
ylim([0 16 * 10^7]);
xlabel('1-hr wind speed (m/s)');
ylabel('Max 1-hr overturning moment (Nm)');
title('Statistical response simulator');
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.jpg') 
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.pdf') 

figure
vslice = [10];   
hslice = [];
tslice = [3 7 15];
slice(tmesh, vmesh, hmesh, rmedian, tslice, vslice, hslice)
c = colorbar;
c.Label.String = 'Median maximum 1-hr oveturning moment (Nm) ';
ylabel('1-hr wind speed (m/s)');
zlabel('Significant wave height (m)');
xlabel('Peak period (s)');
view(3)
%exportgraphics(gca, 'gfx/ResponseField3d.jpg') 
%exportgraphics(gca, 'gfx/ResponseField3d.pdf') 


v = [0:0.2:50];
hs = [0:0.1:9];
[vmesh, hmesh] = meshgrid(v, hs);
tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
sigmas = R.sigma(vmesh, hmesh, tpbreaking(hmesh));
mus = R.mu(vmesh, hmesh, tpbreaking(hmesh));
rmedian = R.ICDF1hr(vmesh, hmesh, tpbreaking(hmesh), 0.5);

capacity = 18.77 * 10^7;
figure
contourf(vmesh, hmesh, rmedian)
hold on
c = colorbar;
c.Label.String = 'Median maximum 1-hr oveturning moment (Nm) ';
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');
%exportgraphics(gca, 'gfx/ResponseFieldAtBreakingTp.pdf') 

