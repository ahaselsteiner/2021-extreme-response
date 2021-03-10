R = ResponseEmulator;
FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)

tp_temp = [3:1:20];
v_temp = [0:1:50];
hs_temp = [0:0.5:9];


[tmesh, vmesh, hmesh] = meshgrid(tp_temp, v_temp, hs_temp);
sigmas = R.sigma(vmesh, hmesh, tmesh);
mus = R.mu(vmesh, hmesh, tmesh);
rmedian = R.ICDF1hr(vmesh, hmesh, tmesh, 0.5);

% Parameter values at h=0
figure('Position', [100 100 500 600])
t = tiledlayout(3, 1);
vv = [0:0.05:45];
hss = 0;
tpp = 10;
nexttile
plot(vv, R.k(vv, hss));
ylabel('k (-)');
box off
nexttile
plot(vv, R.mu(vv, hss, tpp));
ylabel('\mu (Nm)');
box off
nexttile
plot(vv, R.sigma(vv, hss, tpp));
ylabel('\sigma (Nm)');
xlabel('v_{1hr} (m/s)');
box off
%sgtitle(['hs = ' num2str(hss) ', tp = ' num2str(tpp)]);
%sgtitle('Parameter values at h_s = 0 m');
exportgraphics(gcf, 'gfx/ResponseParametersHs0.jpg') 
exportgraphics(gcf, 'gfx/ResponseParametersHs0.pdf') 

% Plot response of v curves.
figure('Position', [100 100 500 600])
t = tiledlayout(2, 1);
% Plot result from simulation
ax1 = nexttile
addpath('03_Calm_Sea_Complete_Wind')
load 'CalmSeaComplete.mat'; % will also give variable 'vv'
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
legend({'Random realization', 'Average over realizations', fit_string}, 'location', 'southeast');
legend box off
xlabel('');
ylabel('');
linkaxes([ax1 ax2],'xy')
xlabel(t, '1-hour wind speed (m/s)');
ylabel(t, 'Max 1-hour overturning moment (Nm)');
t.TileSpacing = 'compact';
title('Statistical response emulator, h_s = 0 m');
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.jpg') 
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.pdf') 

fig = figure('position', [100, 100, 900, 400]);
t = tiledlayout(1,1);
ax1 = nexttile
hold on
for tpi = 3
    h = scatter(v, squeeze(max(Ovr(:, 1, tpi, :), [], 4)), ms, 'MarkerFaceColor', [0 0 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
end
n = 6;
r = nan(length(vv), n);
for i = 1 : length(vv)
    r(i, :) = R.randomSample1hr(vv(i), 3, tp(3, tpi), n);
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
legend box off
xlabel('');
ylabel('');
linkaxes([ax1 ax2],'xy')
xlabel(t, '1-hour wind speed (m/s)');
ylabel(t, 'Max 1-hour overturning moment (Nm)');
t.TileSpacing = 'compact';
legend({'Aeroelastic simulation', 'Response emulator seed', 'Response emulator mean'}, 'location', 'southeast');
legend box off
title(['Statistical response emulator, h_s = 3 m, t_p = ' num2str(tp(3, tpi))]);


% Plot response contours
fig = figure('position', [100, 100, 750, 850]);
t = tiledlayout(4,3);
for tpid = 1 : 4
    ax1 = nexttile;
    robserved  = squeeze(max(Ovr(:, :, tpid, :), [], 4))';
    robserved(robserved == 0) = NaN;
    [vmesh, hmesh] = meshgrid(v, hs);
    contourf(vmesh, hmesh, robserved, 10)
    clower = 0.1 * 10^8;
    cupper = 3.8 * 10^8;
    caxis([clower cupper]);
    if tpid == 1
        title(['Aeroelastic simulation, t_{p' num2str(tpid) '}']);
    else
        title(['t_{p' num2str(tpid) '}']);
    end

    ax2 = nexttile;
    vv = [0:0.5:45];
    hss = [0:0.2:15];
    [vmesh, hmesh] = meshgrid(vv, hss);
    r50 = R.ICDF1hr(vmesh, hmesh, tp(hmesh, tpid), 0.5);
    contourf(vmesh, hmesh, r50, 10)
    caxis([clower cupper]);
    if tpid == 1 
        title(['Emulator median response, t_{p' num2str(tpid) '}']);
    else
        title(['t_{p' num2str(tpid) '}']);
    end
    if tpid == 4
        c1 = colorbar;
        c1.Label.String = '1-hour maximum oveturning moment (Nm) ';
        c1.Layout.Tile = 'south';
    end
    %linkaxes([ax1 ax2],'xy')


    ax3 = nexttile;
    [vmesh, hmesh] = meshgrid(v, hs);
    r50 = R.ICDF1hr(vmesh, hmesh, tp(hmesh, tpid), 0.5);
    r50(isnan(robserved)) = NaN;
    contourf(vmesh, hmesh, robserved - r50, 10)
    colormap(ax3, redblue)
    caxis([-5 * 10^7, 5 * 10^7]);
    if tpid == 1
        title('Difference');
    end
    if tpid == 4
        c2 = colorbar;
        c2.Label.String = 'Difference (Nm) ';
        c2.Layout.Tile = 'south';
    end
end
xlabel(t, '1-hour wind speed (m/s)');
ylabel(t, 'Significant wave height (m)');
    
exportgraphics(fig, 'gfx/CompareResponse2D.jpg') 
exportgraphics(fig, 'gfx/CompareResponse2D.pdf') 

% Plot response comparision as scatter
fig = figure('position', [100, 100, 1400, 350]);
t = tiledlayout(1, 5);
ax1 = nexttile;
robserved_all = [];
r50_all = [];
ms = 5;
for tpid = 1 : 4
    nexttile
    robserved  = squeeze(max(Ovr(:, :, tpid, :), [], 4))';
    robserved(robserved == 0) = NaN;
    r50 = R.ICDF1hr(vmesh, hmesh, tp(hmesh, tpid), 0.5);
    robserved_all = [robserved_all; robserved(:)];
    r50_all = [r50_all; r50(:)];
    scatter(robserved(:), r50(:), ms, 'ok');
    hold on
    plot([0, max(r50(:))], [0, max(r50(:))], '--r'); 
    title(['t_{p' num2str(tpid) '}']);
end
axes(ax1);
scatter(robserved_all, r50_all, ms, 'ok');
hold on
plot([0, max(r50_all)], [0, max(r50_all)], '--r'); 
title('All simulated conditions');
xlabel(t, '1-hour maximum in aeroelastic simulation (Nm)');
ylabel(t, 'Emulator median 1-hour maximum (Nm)');
exportgraphics(fig, 'gfx/CompareResponseScatter.jpg') 
exportgraphics(fig, 'gfx/CompareResponseScatter.pdf') 


% Plot with 3D graphic
fig = figure('position', [100, 100, 900, 400]);
[tmesh, vmesh, hmesh] = meshgrid(tp_temp, v_temp, hs_temp);
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
vv = [0:0.5:45];
hss = [0:0.2:15];
[vmesh, hmesh] = meshgrid(vv, hss);
tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
sigmas = R.sigma(vmesh, hmesh, tpbreaking(hmesh));
mus = R.mu(vmesh, hmesh, tpbreaking(hmesh));
rmedian = R.ICDF1hr(vmesh, hmesh, tpbreaking(hmesh), 0.5);
contourf(vmesh, hmesh, rmedian, 10)
hold on
caxis([clower cupper]);
c = colorbar;
c.Label.String = 'Median maximum 1-hour oveturning moment (Nm) ';
c.Layout.Tile = 'east';
xlabel('1-hour wind speed (m/s)');
ylabel('Significant wave height (m)');
exportgraphics(fig, 'gfx/MedianResponseFullField.jpg') 
exportgraphics(fig, 'gfx/MedianResponseFullField.pdf') 

