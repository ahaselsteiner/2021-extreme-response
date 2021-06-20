load('count');
alpha = 1 / (50 * 365.25 * 24);
threshold = findThreshold(count, alpha)
contour_lw = 1;

[T, H] = meshgrid(t, h);

fig = figure('Position', [100 100 1200 600]);
layout = tiledlayout(2,4);
windI = [12 16 20 25 26 31 36 41] ;
Cv = [];
Chs = [];
Ctp1 = [];
for i = windI
    ax = nexttile;
    hold on
    slice = squeeze(count(i,:,:)); 
    nanSlice = slice;
    nanSlice(slice==0) = nan;
    nanimage(T(1,:), H(:,1), nanSlice);
    set(gca, 'YDir', 'normal')
    M = contour(T, H, slice, [threshold, threshold], 'r', 'linewidth', contour_lw);
    M = M(:,M(1,:) <= 25);
    dcs_tp = [];
    dcs_hs = [];
    for tpi = 3:25
        [dctp, dchs] = polyxpoly(M(1,:), M(2,:), [tpi, tpi], [18 0]);
        [mx, id] = max(dchs);
        dctp = dctp(id);
        dchs = dchs(id);
        if ~isempty(dctp)
            dcs_tp(end + 1) = dctp;
            dcs_hs(end + 1) = dchs;
        end
    end
    dcs_v = zeros(length(dcs_tp), 1) + w(i);
    Cv = [Cv; dcs_v];
    Chs = [Chs; dcs_hs'];
    Ctp1 = [Ctp1; dcs_tp'];
    plot(dcs_tp, dcs_hs, 'ok', 'markerfacecolor', 'red');
    deltaw = w(2) - w(1);
    title([num2str(w(i) - deltaw / 2) ' m s^{-1} < v < ' num2str(w(i) + deltaw / 2) ' m s^{-1}']);
    caxis([1 10000000]);
    set(gca,'ColorScale','log')
end
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel(layout, 'Spectral peak period (s)');
ylabel(layout, 'Significant wave height (m)')
sgtitle(['3D contour, \alpha = ' num2str(alpha, '%2.2e')]);

%layout.Padding = 'compact';
fig.Renderer='Painters';
exportgraphics(layout, 'gfx/3DcontourTp.jpg') 
exportgraphics(layout, 'gfx/3DcontourTp.pdf') 
writematrix([Cv Chs Ctp1],'Data/hdc_3d.csv') 

% 2D projection
VHsProjection = sum(count,3);
threshold2D = findThreshold(VHsProjection, alpha);
[W, H] = meshgrid(w, h);


% HD
M = contourc(W(1,:), H(:,1), VHsProjection', [threshold2D, threshold2D]);
Ctop = M(:,45:end);
Ctopv = wrev(Ctop(1,:));
Ctophs = wrev(Ctop(2,:));
[Ctopv, ia] = unique(Ctopv);
Ctophs = Ctophs(ia);
Cv_HD = 3:2:max(Ctop(1,:));
Chs_HD = interp1(Ctopv, Ctophs, Cv_HD);
C_HD_Sp_SMax = maxSteepnessAtV(Cv_HD);
Ctp1 = sqrt(2 * pi * Chs_HD ./ (9.81 * C_HD_Sp_SMax));
C_HD_Sz_SMedian = medianSteepnessAtV(Cv_HD);
Ctp2 = sqrt(2 * pi * Chs_HD ./ (9.81 * C_HD_Sz_SMedian));
writematrix([Cv_HD' Chs_HD' Ctp1'],'Data/hdc_2d_maxsteepness.csv') 
writematrix([Cv_HD' Chs_HD' Ctp2'],'Data/hdc_2d_mediansteepness.csv') 

%IFORM contour
[iform_w, iform_h] = count2iform(w, h, VHsProjection', alpha, 5);
Cv_IFORM = wrev(iform_w(1:25));
Chs_IFORM = wrev(iform_h(1:25));
C_iform_v = 3:2:max(Cv_IFORM);
C_iform_hs = interp1(Cv_IFORM, Chs_IFORM, C_iform_v);

C_Sp_SMax = maxSteepnessAtV(C_iform_v);
C_iform_tp1 = sqrt(2 * pi * C_iform_hs ./ (9.81 * C_Sp_SMax));
C_Sz_SMedian = medianSteepnessAtV(C_iform_v);
C_iform_tp2 = sqrt(2 * pi * C_iform_hs ./ (9.81 * C_Sz_SMedian));

writematrix([C_iform_v' C_iform_hs' C_iform_tp1'],'Data/iform_2d_maxsteepness.csv') 
writematrix([C_iform_v' C_iform_hs' C_iform_tp2'],'Data/iform_2d_mediansteepness.csv') 

% IFORM contour with a return period of 1 year
[iform_w_1year, iform_h_1year] = count2iform(w, h, VHsProjection', alpha * 50, 5);
Cv_IFORM_1year = wrev(iform_w_1year(1:25));
Chs_IFORM_1year = wrev(iform_h_1year(1:25));
C_iform_v_1year = 3:2:max(Cv_IFORM_1year);
C_iform_hs_1year = interp1(Cv_IFORM_1year, Chs_IFORM_1year, C_iform_v_1year);
C_Sz_SMedian_1year = medianSteepnessAtV(C_iform_v_1year);
C_iform_tp2_1year = sqrt(2 * pi * C_iform_hs_1year ./ (9.81 * C_Sz_SMedian_1year));
writematrix([C_iform_v_1year' C_iform_hs_1year' C_iform_tp2_1year'],'Data/iform_2d_mediansteepness_1year.csv') 

figure('Position', [100 100 400 360])
layout = tiledlayout(1,1);
nexttile
hold on
nanSlice = VHsProjection;
nanSlice(VHsProjection==0) = nan;
handle = pcolor(W, H, nanSlice');
handle.EdgeColor = 'none';
M = contour(W, H, VHsProjection', [threshold2D, threshold2D], 'r', 'linewidth', contour_lw);
h_hd = plot(NaN, '-r', 'linewidth', contour_lw);
h_iform = plot(iform_w, iform_h, '--r', 'linewidth', contour_lw);
h_ds = plot(Cv_HD, Chs_HD, 'ok', 'markerfacecolor', 'red');
plot(C_iform_v, C_iform_hs, 'ok', 'markerfacecolor', 'red');
legend([h_hd, h_iform, h_ds], 'Highest density', 'IFORM', 'Design condition', 'location', 'northwest', 'box', 'off');

title(['2D projection, \alpha = ' num2str(alpha,'%2.2e')]);
caxis([1 100000000]);
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
set(gca,'ColorScale','log')
xlim([0 45]);
ylim([0 20]);
xlabel('1-hour wind speed (m s^{-1})');
ylabel('Significant wave height (m)')
exportgraphics(layout, 'gfx/2Dcontours.jpg') 
exportgraphics(layout, 'gfx/2Dcontours.pdf') 

%Scatter plot
figure('Position', [100 100 500 400])
hold on
load('ArtificialTimeSeries50years.mat');
n = 365.24 * 24 * 50;
t = A.t(1:n);
v1hr = A.V(1:n);
hs = A.Hs(1:n);
s = A.S(1:n);
tz = sqrt((2 .* pi .* hs) ./ (9.81 .* s));
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.
ms = 20;
scatter(v1hr, hs, ms, s, 'filled', 'markeredgecolor', 'k');

plot(Cv_HD, Chs_HD, '-k');
scatter(Cv_HD, Chs_HD, 50, C_HD_Sp_SMax, 'filled', 'markeredgecolor', 'k');
c = colorbar;
c.Label.String = 'Steepness (-)';
xlabel('1-hour wind speed (m s^{-1})');
ylabel('Significant wave height (m)')



function threshold =  findThreshold(count, alpha)
    totCount =  sum(sum(sum(count)));
    threshold = 0;
    inHdrProb = 1;
    while inHdrProb > (1 - alpha)
        threshold = threshold + 1;
        inHdrProb = sum(count(count > threshold)) / totCount;
    end
end
