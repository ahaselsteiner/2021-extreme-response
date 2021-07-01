R30 = ResponseEmulator;
R10 = ResponseEmulator10mWaterDepth;

load('iform_2d_mediansteepness.csv')
IFORM_median.v = iform_2d_mediansteepness(:,1);
IFORM_median.hs = iform_2d_mediansteepness(:,2);
IFORM_median.tp = iform_2d_mediansteepness(:,3);
load('iform_2d_mediansteepness_1year.csv')
IFORM_1year.v = iform_2d_mediansteepness_1year(:,1);
IFORM_1year.hs = iform_2d_mediansteepness_1year(:,2);
IFORM_1year.tp = iform_2d_mediansteepness_1year(:,3);

[V, H] = meshgrid([0:1:40], [0:0.5:20]);
Tmedian = nan(size(H));
TmaxS = nan(size(H));
R30_medianS = nan(size(H));
R10_medianS = nan(size(H));

response_quantile = 0.5;
for i = 1 : size(V, 1)
    for j = 1 : size(V, 2)
        s_temp = medianSteepnessAtV(V(i, j));
        Tmedian(i, j) = sqrt(2 * pi * H(i,j) ./ (9.81 * s_temp));
        R30_medianS(i, j) = R30.ICDF1hr(V(i,j), H(i,j), Tmedian(i,j), response_quantile);
        R10_medianS(i, j) = R10.ICDF1hr(V(i,j), H(i,j), Tmedian(i,j), response_quantile);
    end
end

figure('Position', [100 100 800 350]);
layout = tiledlayout(1, 2);
for i = 1 : 2
    nexttile
    hold on
    if i == 1
        R = R30_medianS;
        levels = [100:25:250 300];
        thick_level = [275 275];
        title('30 m water depth');
    else
        R = R10_medianS;
        levels = [85:10:105 125];
        thick_level = [115 115];
        title('10 m water depth');
    end

    
    [M, c] = contour(V, H, R / 10^6 ,levels, '-', 'ShowText','on');
    c.LineWidth = 1.5;
    text_h  = clabel(M, c, 'fontsize', 6, 'LabelSpacing',50);
    [M, ct] = contour(V, H, R / 10^6 ,thick_level, '-', 'ShowText','on');
    ct.LineWidth = 4;
    text_ht  = clabel(M, ct, 'fontsize', 6, 'LabelSpacing',50, 'fontweight', 'bold');
    h_iform = plot(IFORM_median.v, IFORM_median.hs, '.-k', 'linewidth', 1.5, 'markersize', 12);
    legend(h_iform, '50-year IFORM contour', 'box', 'off');
    cb = colorbar;
    cb.Label.String = 'Median 1-hour maximum moment (MNm)';
end
xlabel(layout, 'Wind speed (m s^{-1})');
ylabel(layout, 'Significant wave height (m)');

exportgraphics(layout, 'gfx/ResponseLinesAndIFORM.jpg') 
exportgraphics(layout, 'gfx/ResponseLinesAndIFORM.pdf')
