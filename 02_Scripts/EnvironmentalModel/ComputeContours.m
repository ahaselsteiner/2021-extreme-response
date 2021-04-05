load('count');
alpha = 1 / (50 * 365.25 * 24);
threshold = findThreshold(count, alpha)

[T, H] = meshgrid(t, h);

figure('Position', [100 100 1200 600])
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
    M = contour(T, H, slice, [threshold, threshold], 'r', 'linewidth', 2);
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
    plot(dcs_tp, dcs_hs, 'xk', 'linewidth', 2);
    deltaw = w(2) - w(1);
    title([num2str(w(i) - deltaw / 2) ' m s^{-1} < v < ' num2str(w(i) + deltaw / 2) ' m s^{-1}']);
    caxis([0 10000000]);
end
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel(layout, 'Spectral peak period (s)');
ylabel(layout, 'Significant wave height (m)')
sgtitle(['3D contour, \alpha = ' num2str(alpha, '%2.2e')]);
exportgraphics(layout, 'gfx/3DcontourTp.jpg') 
exportgraphics(layout, 'gfx/3DcontourTp.pdf') 
writematrix([Cv Chs Ctp1],'Data/hdc_3d.csv') 

% 2D projection
VHsProjection = sum(count,3);
threshold2D = findThreshold(VHsProjection, alpha);
[W, H] = meshgrid(w, h);
[iform_w, iform_h] = count2iform(w, h, VHsProjection', alpha, 5);

figure('Position', [100 100 500 400])
layout = tiledlayout(1,1);
nexttile
hold on
nanSlice = VHsProjection;
nanSlice(VHsProjection==0) = nan;
handle = pcolor(W, H, nanSlice');
handle.EdgeColor = 'none';
M = contour(W, H, VHsProjection', [threshold2D, threshold2D], 'r', 'linewidth', 2);
h_hd = plot(NaN, '-r', 'linewidth', 2);
h_iform = plot(iform_w, iform_h, '--r', 'linewidth', 2);
legend([h_hd, h_iform], 'Highest density', 'IFORM', 'location', 'northwest', 'box', 'off');

title(['2D projection, \alpha = ' num2str(alpha,'%2.2e')]);
caxis([0 10000000]);
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel('1-hour wind speed (m s^{-1})');
ylabel('Significant wave height (m)')
exportgraphics(layout, 'gfx/2Dcontours.jpg') 
exportgraphics(layout, 'gfx/2Dcontours.pdf') 

% HD contour
figure
hold on
Ctop = M(:,45:end);
Ctopv = wrev(Ctop(1,:));
Ctophs = wrev(Ctop(2,:));
[Ctopv, ia] = unique(Ctopv);
Ctophs = Ctophs(ia);
Cv = 3:2:max(Ctop(1,:));
Chs = interp1(Ctopv, Ctophs, Cv);
%steepnessMax = @(v) 0.02 + (0.08 - 0.02) * v / 35;
steepnessMax = @(v) (v <= 19) .* (0.035 + (0.088 - 0.035) / 19 * v) + (v > 19) .* 0.088;
medianSteepness = @(v) 0.071 - 0.06 * exp(-0.11 * v);
CsTz1 = steepnessMax(Cv);
CTz1 = sqrt(2 * pi * Chs ./ (9.81 * CsTz1));
Ctp1 = 1.2796 * CTz1;
CsTz2 = medianSteepness(Cv);
CTz2 = sqrt(2 * pi * Chs ./ (9.81 * CsTz2));
Ctp2 = 1.2796 * CTz2;

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

plot(Cv, Chs, '-k');
scatter(Cv, Chs, 50, CsTz1, 'filled', 'markeredgecolor', 'k');
c = colorbar;
c.Label.String = 'Steepness (-)';
xlabel('1-hour wind speed (m s^{-1})');
ylabel('Significant wave height (m)')

writematrix([Cv' Chs' Ctp1'],'Data/hdc_2d_maxsteepness.csv') 
writematrix([Cv' Chs' Ctp2'],'Data/hdc_2d_mediansteepness.csv') 

%IFORM contour
Ctop = M(:,45:end);
Cv = wrev(iform_w(1:25));
Chs = wrev(iform_h(1:25));
C_iform_v = 3:2:max(Cv);
C_iform_hs = interp1(Cv, Chs, C_iform_v);

CsTz1 = steepnessMax(C_iform_v);
CTz1 = sqrt(2 * pi * C_iform_hs ./ (9.81 * CsTz1));
C_iform_tp1 = 1.2796 * CTz1;
CsTz2 = medianSteepness(C_iform_v);
CTz2 = sqrt(2 * pi * C_iform_hs ./ (9.81 * CsTz2));
C_iform_tp2 = 1.2796 * CTz2;

writematrix([C_iform_v' C_iform_hs' C_iform_tp1'],'Data/iform_2d_maxsteepness.csv') 
writematrix([C_iform_v' C_iform_hs' C_iform_tp2'],'Data/iform_2d_mediansteepness.csv') 

function threshold =  findThreshold(count, alpha)
    totCount =  sum(sum(sum(count)));
    threshold = 0;
    inHdrProb = 1;
    while inHdrProb > (1 - alpha)
        threshold = threshold + 1;
        inHdrProb = sum(count(count > threshold)) / totCount;
    end
end
