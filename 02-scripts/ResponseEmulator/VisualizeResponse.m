R = ResponseEmulator;
FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)

%load('OvrDataEmulatorDiffSeed');

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
plot(vv, R.xi(vv, hss));
ylabel('\xi (-)');
box off
nexttile
plot(vv, R.mu(vv, hss, tpp));
ylabel('\mu (Nm)');
box off
nexttile
plot(vv, R.sigma(vv, hss, tpp));
ylabel('\sigma (Nm)');
xlabel('Wind speed (m s^{-1})');
box off
%sgtitle('Parameter values at h_s = 0 m');
exportgraphics(gcf, 'gfx/ResponseParametersHs0.jpg') 
exportgraphics(gcf, 'gfx/ResponseParametersHs0.pdf') 

% Plot response of v curves.
figure('Position', [100 100 500 600])
t = tiledlayout(2, 1);
% Plot result from simulation
ax1 = nexttile;
load 'CalmSeaComplete.mat'; % will also give variable 'vv'
OvrAllSeeds = [Ovr_S1; Ovr_S2; Ovr_S3; Ovr_S4; Ovr_S5; Ovr_S6];
OvrAllSeeds = OvrAllSeeds(:, 1:18);
vv = vv(1:18);
hold on
ms = 30;
for tpi = 1 : 4
    h = scatter(v(1:end), squeeze(max(Ovr(1:end, 1, tpi, :), [], 4)) / 10^6, ms, 'MarkerFaceColor', [0 0 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if tpi > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
meanOvr = mean(OvrAllSeeds);
FT = fittype('a * x.^2');
fitted_curve = fit(vv(vv > 25)', meanOvr(vv > 25)' / 10^6, FT);
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
fit_string = [num2str(fitted_curve.a, '%.4f') ' * v^2'];
legend({'Simulation seed (n = 4)', fit_string}, 'location', 'southeast');
legend box off
xlim([0 45])
xlabel('');
ylabel('');
title('Multiphysics simulation, {\it h_s} = 0 m');
% Plot results from emulator
ax2 = nexttile
hold on
n = 20;
vv = [1, vv];
r = nan(length(vv), n);
for i = 1 : length(vv)
    r(i, :) = R.randomSample1hr(vv(i), 0, 0, n);
end
for i = 1 : n
    h = scatter(vv, r(:, i) / 10^6, ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
vvv = 0:0.01:50;
set(h, 'HandleVisibility', 'off')
h = plot(fitted_curve);
set(h, 'linewidth', 2)
set(h, 'linestyle', '--')
fit_string = [num2str(fitted_curve.a, '%.4f') ' * v^2'];
legend({['Random realization (n = ' num2str(n) ')'], fit_string}, 'location', 'southeast');
legend box off
xlim([0 45])
xlabel('');
ylabel('');
linkaxes([ax1 ax2],'xy')
xlabel(t, '1-hour wind speed (m s^{-1})');
ylabel(t, 'Max 1-hour overturning moment (MNm)');
t.TileSpacing = 'compact';
title('Statistical response emulator, {\it h_s} = 0 m');
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.jpg') 
exportgraphics(gcf, 'gfx/ResponseAtCalmSea.pdf') 



% Plot response contours
fig = figure('position', [100, 100, 750, 850]);
t = tiledlayout(4,3);
for tpid = 1 : 4
    ax1 = nexttile;
    robserved  = squeeze(max(Ovr(:, :, tpid, :), [], 4))';
    robserved(robserved == 0) = NaN;
    [vmesh, hmesh] = meshgrid(v, hs);
    contourf(vmesh, hmesh, robserved / 10^6, 10)
    clower = 10;
    cupper = 380;
    caxis([clower cupper]);
    if tpid == 1
        title(['Multiphysics simulation, {\it t_{p' num2str(tpid) '}}']);
    else
        title(['{\it t_{p' num2str(tpid) '}}']);
    end

    ax2 = nexttile;
    vv = [0:0.5:45];
    hss = [0:0.2:15];
    [vmesh, hmesh] = meshgrid(vv, hss);
    rmesh = R.ICDF1hr(vmesh, hmesh, tp(hmesh, tpid), 0.5);
    contourf(vmesh, hmesh, rmesh / 10^6, 10)
    caxis([clower cupper]);
    if tpid == 1 
        title(['Emulator median response, {\it t_{p' num2str(tpid) '}}']);
    else
        title(['{\it t_{p' num2str(tpid) '}}']);
    end
    if tpid == 4
        c1 = colorbar;
        c1.Label.String = '1-hour maximum oveturning moment (MNm) ';
        c1.Layout.Tile = 'south';
    end

    
    ax4 = nexttile;
    [vmesh, hmesh] = meshgrid(v, hs);
    rmesh = R.ICDF1hr(vmesh, hmesh, tp(hmesh, tpid), 0.5);
    rmesh(isnan(robserved)) = NaN;
    imagesc(vmesh(1,:), hmesh(:,1), (rmesh - robserved) ./ robserved * 100, 'AlphaData',~isnan(rmesh));
    set(gca, 'YDir', 'normal')
    colormap(ax4, redblue)
    caxis([-30, 30]);
    if tpid == 1
        title('Difference');
    end
    if tpid == 4
        c3 = colorbar;
        c3.Label.String = 'Difference (emulator - multiphyisics; %) ';
        c3.Layout.Tile = 'south';
    end
end
xlabel(t, '1-hour wind speed (m s^{-1})');
ylabel(t, 'Significant wave height (m)');

fig.Renderer = 'Painters';
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
xlabel(t, '1-hour maximum in multiphysics simulation (Nm)');
ylabel(t, 'Emulator median 1-hour maximum (Nm)');
exportgraphics(fig, 'gfx/CompareResponseScatter.jpg') 
exportgraphics(fig, 'gfx/CompareResponseScatter.pdf')


% Plot with 3D graphic
fig = figure('position', [100, 100, 400, 400]);
[tmesh, vmesh, hmesh] = meshgrid(tp_temp, v_temp, hs_temp);
clower = 7.3E6;
cupper = max(max(max(rmedian)));
vslice = [10];   
hslice = [];
tslice = [3 7 15];
slice(tmesh, vmesh, hmesh, rmedian, tslice, vslice, hslice)
caxis([clower cupper]);
ylabel('1-hour wind speed (m s^{-1})');
zlabel('Significant wave height (m)');
xlabel('Peak period (s)');
view(3)

%exportgraphics(fig, 'gfx/MedianResponseFullField.jpg') 
%exportgraphics(fig, 'gfx/MedianResponseFullField.pdf') 

