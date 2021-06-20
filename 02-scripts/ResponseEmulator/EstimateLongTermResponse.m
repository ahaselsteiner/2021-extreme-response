DO_1D = false;
DO_10M_WATER = false;
DO_VARIOUS_QUANTILES = false;



suffix = '_artificial1000';
load('ArtificialTimeSeries5039years.mat');
n = 365.25 * 24 * 1000;
%n = length(A.t);
t = A.t(1:n);
v1hr = A.V(1:n);
hs = A.Hs(1:n);
s = A.S(1:n);
tz = sqrt((2 .* pi .* hs) ./ (9.81 .* s));
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

if DO_10M_WATER
    R = ResponseEmulator10mWaterDepth;
    suffix = [suffix '_10m'];
    moment_label = 'Stochastic 10 m moment (MNm)';
else
    R = ResponseEmulator;
    moment_label = 'Stochastic 30 m moment (MNm)';
end

n_short = 1000;
p = rand(n_short, 1);
r_short = R.ICDF1hr(v1hr(1:n_short), hs(1:n_short), tp(1:n_short), p);

n = length(t);
r = [];
r_onlywind = [];
r_fixedh = [];
n_per_year = 365.25 * 24;
disp('Drawing random samples: response emulator.');
for i = 0 : floor(n / n_per_year)
    disp([num2str(i + 1) '/' num2str(ceil(n / n_per_year))]);
    if i < floor(n / n_per_year)
        temp = v1hr(1 + i*n_per_year : (i + 1) * n_per_year);
        p = rand(length(temp), 1);
        rpart = R.ICDF1hr(temp, hs(1 + i*n_per_year : (i + 1) * n_per_year), tp(1 + i*n_per_year : (i + 1) * n_per_year), p);
        if DO_1D
            rpart_w = R.ICDF1hr(temp, zeros(n_per_year, 1), zeros(n_per_year, 1), p);
            h_associated = 0.4 + 0.0071 * temp.^2;
            t_associated = 2.7 * + 6.5 .* sqrt(h_associated / 9.81);
            rpart_fixedh = R.ICDF1hr(temp, h_associated, t_associated, p);
        end
    else
        temp = v1hr(1 + i * n_per_year : end);
        p = rand(length(temp), 1);
        rpart = R.ICDF1hr(temp, hs(1 + i * n_per_year : end), tp(1 + i*n_per_year : end), p);
        if DO_1D
            rpart_w = R.ICDF1hr(temp, zeros(size(temp)), zeros(size(temp)), p);
            h_associated = 0.4 + 0.0071 * temp.^2;
            t_associated = 2.7 * + 6.5 .* sqrt(h_associated / 9.81);
            rpart_fixedh = R.ICDF1hr(temp, h_associated, t_associated, p);
        end
    end
    r = [r; rpart];
    if DO_1D
        r_onlywind = [r_onlywind; rpart_w];
        r_fixedh = [r_fixedh; rpart_fixedh];
    end
end

block_length = 365.25 * 24;
full_years = floor(n / block_length);
pds = [];
maxima = zeros(full_years, 1);
blocks = zeros(full_years, block_length);
block_maxima = zeros(full_years, 1);
block_max_i = zeros(full_years, 1);

disp('Forming blocks.');
for i = 1 : full_years
    disp([num2str(i) '/' num2str(full_years) ' years']);
    blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
    [block_maxima(i), maxid] = max(blocks(i,:));
    block_max_i(i) = maxid + (i - 1) * block_length;
end

% Calculate x50
x50_all_emp = quantile(r, 1 - 1 / (50 * 365.25 * 24));
pd = fitdist(block_maxima, 'GeneralizedExtremeValue');
x50_am_emp = quantile(block_maxima, 1 - 1 / 50);
x50_am_pred = icdf(pd, 1 - 1 / 50);

% Plot serial correlation' influence on the response
rps = logspace(0,2,500);
rvs_am_emp = quantile(block_maxima, 1 - 1 ./ rps);
rvs_all_emp = quantile(r, 1 - 1 ./ (rps * 365.25 * 24));
fig = figure('Position', [100 100 350 350]);
hold on
plot(rps, rvs_am_emp / 10^6, '-b');
plot(rps, rvs_all_emp / 10^6, '--r');
plot(50, x50_am_emp / 10^6, 'ok', 'markerfacecolor', 'blue');
plot(50, x50_all_emp / 10^6, 'ok', 'markerfacecolor', 'red');
text(50, 1.03 * x50_all_emp / 10^6, [num2str((x50_all_emp / x50_am_emp - 1) * 100, '%4.1f') '% too high'], ...
    'fontsize', 8, 'horizontalalignment', 'center', 'color', 'red');
xlabel('Return period (years)');
ylabel('Return value (MNm)');
legend('Annual maxima', 'Complete time series', 'box', 'off', 'location', 'southeast');
exportgraphics(fig, 'gfx/SerialCorrelation.jpg') 
exportgraphics(fig, 'gfx/SerialCorrelation.pdf') 

% Plot 2D
figure('Position', [100 100 1200 800])
layout = tiledlayout(4,3);
axs = gobjects(5,1); 
axs(1) = nexttile([1 3]);
yyaxis left 
plot(days(t(1:n_short)), r_short / 10^6);
ylabel(moment_label)
ylim([0 200])
yyaxis right 
plot(days(t(1:n_short)), v1hr(1:n_short));
xlabel('Time (days)');
ylabel('1-hour wind speed (m s^{-1})')
xlim(days([t(1) t(n_short)]));
box off

axs(2) = nexttile([1 3]);
hold on
plot(years(t(1:n)), r / 10^6);
plot(years(t(block_max_i)), r(block_max_i) / 10^6, 'xr');
ylabel(moment_label)
xlabel('Time (years)');
ylim([0 500])

axs(3) = nexttile([2 1]);
hold on
ms_am = 25;
scatter(v1hr, hs, 2, [0.5 0.5 0.5])
scatter(v1hr(block_max_i), hs(block_max_i), ms_am, block_maxima / 10^6, 'filled');
c = colorbar;
c.Label.String = [moment_label(1:end-5) 'of annual extreme (MNm)'];
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m s^{-1})') 
ylabel('Significant wave height (m)')

axs(4) = nexttile([2 1]);
hold on
sp = (2 * pi * hs(block_max_i)) ./ (9.81 * tp(block_max_i).^2);
scatter(v1hr, hs, 2, [0.5 0.5 0.5])
scatter(v1hr(block_max_i), hs(block_max_i), ms_am, sp, 'filled');
c = colorbar;
c.Label.String = 'Steepness of annual extreme (-)';
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m s^{-1})') 
ylabel('Significant wave height (m)')

axs(5) = nexttile([2 1]);
axs(5) = exceedancePlot(block_maxima / 10^6, 1, '-k.', axs(5));
temp = '50-year extreme';
plot(x50_am_emp / 10^6, 1/50, 'ob','markersize', 10, 'LineWidth',2, 'displayname', temp);
current_xlims = xlim;
xlim([min(block_maxima / 10^6), current_xlims(2)]);
ylim([0.5*10^(-3), 1]);
xlabel(moment_label);
ylabel('Annual exceedance probability (-)');

layout.Padding = 'compact';
exportgraphics(layout, ['gfx/ResponseTimeSeries' suffix '.jpg']) 

for i = 1 : 2
    exportgraphics(axs(i), ['gfx/ResponseTimeSeries' suffix '_axs' ...
        num2str(i) '.jpg'], 'resolution', 300) 
end

% Export ax3 and ax5 as own figure to control size better.
figure('Position', [100 100 300 300])
ax = nexttile();
hold on
ms_am = 15;
scatter(v1hr, hs, 2, [0.5 0.5 0.5])
scatter(v1hr(block_max_i), hs(block_max_i), ms_am, block_maxima / 10^6, 'filled');
c = colorbar;
c.Label.String = [moment_label(1:end-6) ' of annual maxima (MNm)'];
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m s^{-1})') 
ylabel('Significant wave height (m)')
exportgraphics(ax, ['gfx/ResponseTimeSeries' suffix '_axs3.jpg'], 'Resolution', 300) 

figure('Position', [100 100 300 300])
ax = nexttile();
ax = exceedancePlot(block_maxima / 10^6, 1, '-k.', ax);
plot(x50_am_emp / 10^6, 1/50, 'ob','markersize', 8, 'LineWidth',2, 'displayname', temp);
current_xlims = xlim;
xlim([min(block_maxima / 10^6), current_xlims(2)]);
ylim([0.5*10^(-3), 1]);
xlabel(moment_label);
ylabel('Annual exceedance probability (-)');
exportgraphics(ax, ['gfx/ResponseTimeSeries' suffix '_axs5.pdf']) 

%x1_am = pd.icdf(exp(-1));


if DO_VARIOUS_QUANTILES
    response_quantiles = [0.5 0.8 0.9 0.99];
else
    response_quantiles = [0.5];
end
load('hdc_2d_maxsteepness.csv')
HDC2d_maxsteep.v = hdc_2d_maxsteepness(:,1);
HDC2d_maxsteep.hs = hdc_2d_maxsteepness(:,2);
HDC2d_maxsteep.tp = hdc_2d_maxsteepness(:,3);
load('hdc_2d_mediansteepness.csv')
HDC2d_median.v = hdc_2d_mediansteepness(:,1);
HDC2d_median.hs = hdc_2d_mediansteepness(:,2);
HDC2d_median.tp = hdc_2d_mediansteepness(:,3);
load('iform_2d_maxsteepness.csv')
IFORM_maxsteep.v = iform_2d_maxsteepness(:,1);
IFORM_maxsteep.hs = iform_2d_maxsteepness(:,2);
IFORM_maxsteep.tp = iform_2d_maxsteepness(:,3);
load('iform_2d_mediansteepness.csv')
IFORM_median.v = iform_2d_mediansteepness(:,1);
IFORM_median.hs = iform_2d_mediansteepness(:,2);
IFORM_median.tp = iform_2d_mediansteepness(:,3);
load('hdc_3d.csv')
HDC3d.v = hdc_3d(:,1);
HDC3d.hs = hdc_3d(:,2);
HDC3d.tp = hdc_3d(:,3);

[V, H] = meshgrid([0:1:40], [0:0.5:20]);
Tmedian = nan(size(H));
TmaxS = nan(size(H));
R_medianS = nan(size(H));
R_maxS = nan(size(H));
for i = 1 : size(V, 1)
    for j = 1 : size(V, 2)
        s_temp = medianSteepnessAtV(V(i, j));
        Tmedian(i, j) = sqrt(2 * pi * H(i,j) ./ (9.81 * s_temp));
        s_temp = maxSteepnessAtV(V(i, j));
        TmaxS(i, j) = sqrt(2 * pi * H(i,j) ./ (9.81 * s_temp));
        R_medianS(i, j) = R.ICDF1hr(V(i,j), H(i,j), Tmedian(i,j), response_quantiles(1));
        R_maxS(i, j) = R.ICDF1hr(V(i,j), H(i,j), TmaxS(i,j), response_quantiles(1));
        if length(response_quantiles) > 1
            for k = 1 : length(response_quantiles) - 1
                RHighQuantile_medianS(k, i, j) = R.ICDF1hr(V(i,j), H(i,j), Tmedian(i,j), response_quantiles(k + 1));
                RHighQuantile_maxS(k, i, j) = R.ICDF1hr(V(i,j), H(i,j), TmaxS(i,j), response_quantiles(k + 1));
            end
        end
    end
end

if DO_VARIOUS_QUANTILES
    figure('Position', [100 100 1400 800])
    layout = tiledlayout(3, length(response_quantiles));
else
    figure('Position', [80 50 350 950])
    response_quantiles = response_quantiles(1);
    layout = tiledlayout(3, 1);
end
axs = gobjects(6,1);
caxislim = [0.4 1.1];


for i = 1 : length(response_quantiles)
    
    response_quantile = response_quantiles(i);
    HDC2d_maxsteep.r = R.ICDF1hr(HDC2d_maxsteep.v, HDC2d_maxsteep.hs, HDC2d_maxsteep.tp, response_quantile);
    HDC2d_median.r = R.ICDF1hr(HDC2d_median.v, HDC2d_median.hs, HDC2d_median.tp, response_quantile);
    IFORM_maxsteep.r = R.ICDF1hr(IFORM_maxsteep.v, IFORM_maxsteep.hs, IFORM_maxsteep.tp, response_quantile);
    IFORM_median.r = R.ICDF1hr(IFORM_median.v, IFORM_median.hs, IFORM_median.tp, response_quantile);
    HDC3d.r = R.ICDF1hr(HDC3d.v, HDC3d.hs, HDC3d.tp, response_quantile);
    axs(i) = nexttile(i);
    hold on
    x = [0 25 25 0];
    y = [0 0 20 20];
    pp_color = [0.8 0.8 0.8];
    text_y = 1.5;
    patch(x,y, pp_color, 'EdgeColor', 'none', 'HandleVisibility', 'off')
    text(12.5, text_y, 'power production', 'horizontalalignment', 'center');
    text(33, text_y, 'parked', 'horizontalalignment', 'center');
    lw = 1;
    plot(IFORM_median.v, IFORM_median.hs, '-k', 'linewidth', lw);
    plot(HDC2d_median.v, HDC2d_median.hs, ':k', 'linewidth', lw);
    if i == 1
        Rgrid = R_medianS;
    else
        Rgrid = squeeze(RHighQuantile_medianS(i - 1, :, :));
    end
    [M, c] = contour(V, H, Rgrid / x50_am_emp, [1, 1], ...
        '-', 'ShowText','on');
    clabel(M, c, 'fontsize', 6, 'LabelSpacing',50)
    c.LineWidth = 1;
    sz = 25;
    scatter(IFORM_median.v, IFORM_median.hs, sz, IFORM_median.r / x50_am_emp, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC2d_median.v, HDC2d_median.hs, sz, HDC2d_median.r / x50_am_emp, 'filled', 'MarkerEdgeColor', 'black')
    xticks([0 10 20 25 30 40]);
    caxis(caxislim)
    if i == 1
        legend('IFORM, median steepness', 'Highest density, median s.', 'location', 'northwest', 'box', 'off');
    end
    
    [max_iform, maxi] = max(IFORM_median.r / x50_am_emp);
    txt = ['\leftarrow '  num2str(max_iform, '%4.3f')];
    text(IFORM_maxsteep.v(maxi), IFORM_maxsteep.hs(maxi), txt);
    
    [max_hdc, maxi] = max(HDC2d_median.r / x50_am_emp);
    txt = [num2str(max_hdc, '%4.3f') ' \rightarrow'];
    text(HDC2d_median.v(maxi), HDC2d_median.hs(maxi), txt, 'HorizontalAlignment','right')
    if length(response_quantiles) > 1
        title([num2str(response_quantile) '-quantile']);
    end
    set(gca, 'Layer', 'top')    
    if DO_10M_WATER
        title('10 m moment');
    else
        title('30 m moment');
    end

    axs(length(response_quantiles) + i) = nexttile(length(response_quantiles) + i);
    hold on
    x = [0 25 25 0];
    y = [0 0 20 20];
    pp_color = [0.8 0.8 0.8];
    text_y = 1.5;
    patch(x,y, pp_color, 'EdgeColor', 'none', 'HandleVisibility', 'off')
    text(12.5, text_y, 'power production', 'horizontalalignment', 'center');
    text(33, text_y, 'parked', 'horizontalalignment', 'center');
    lw = 1;
    plot(IFORM_maxsteep.v, IFORM_maxsteep.hs, '-k', 'linewidth', lw);
    plot(HDC2d_maxsteep.v, HDC2d_maxsteep.hs, ':k', 'linewidth', lw);
    if i == 1
        Rgrid = R_maxS;
    else
        Rgrid = squeeze(RHighQuantile_maxS(i - 1, :, :));
    end
    [M, c] = contour(V, H, Rgrid / x50_am_emp, [1 1], ...
        '-', 'ShowText','on');
    clabel(M, c, 'fontsize', 6, 'LabelSpacing',50)
    c.LineWidth = 1;
    sz = 25;
    scatter(IFORM_maxsteep.v, IFORM_maxsteep.hs, sz, IFORM_maxsteep.r / x50_am_emp, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC2d_maxsteep.v, HDC2d_maxsteep.hs, sz, HDC2d_maxsteep.r / x50_am_emp, 'filled', 'MarkerEdgeColor', 'black')
    xticks([0 10 20 25 30 40]);
    caxis(caxislim)
    if i == 1
        legend('IFORM, max. steepness', 'Highest density, max. s.', 'location', 'northwest', 'box', 'off');
    end
    if i == length(response_quantiles)
        cb = colorbar;
        cb.Layout.Tile = 'east';
        cb.Label.String = [moment_label(12:end-6) ' / ' num2str(x50_am_emp / 10^6, '%.0f') ' MNm'];
    end
    
    [max_iform, maxi] = max(IFORM_maxsteep.r / x50_am_emp);
    txt = ['\leftarrow '  num2str(max_iform, '%4.3f')];
    text(IFORM_maxsteep.v(maxi), IFORM_maxsteep.hs(maxi), txt);
    
    [max_hdc, maxi] = max(HDC2d_maxsteep.r / x50_am_emp);
    txt = [num2str(max_hdc, '%4.3f') ' \rightarrow'];
    text(HDC2d_maxsteep.v(maxi), HDC2d_maxsteep.hs(maxi), txt, 'HorizontalAlignment','right')
    set(gca, 'Layer', 'top')
    

    axs(2 * length(response_quantiles) + i) = nexttile(2 * length(response_quantiles) + i);
    hold on
    patch(x,y, pp_color, 'EdgeColor', 'none', 'HandleVisibility', 'off')
    text(12.5, text_y, 'power production', 'horizontalalignment', 'center');
    text(33, text_y, 'parked', 'horizontalalignment', 'center');
    lw = 1;
    sz = 25;
    scatter(HDC3d.v, HDC3d.hs, sz, HDC3d.r / x50_am_emp, 'filled', 'MarkerEdgeColor', 'black')
    [max_hdc3, maxi] = max(HDC3d.r / x50_am_emp);
    txt = [num2str(max_hdc3, '%4.3f') ' \rightarrow'];
    text(HDC3d.v(maxi), HDC3d.hs(maxi), txt, 'HorizontalAlignment','right')
    if i == 1
        text(2, 18, '3D highest density');
    end
    xticks([0 10 20 25 30 40]);

    caxis(caxislim)
    set(gca, 'Layer', 'top')
end
xlabel(layout, '1-hour wind speed (m s^{-1})') 
ylabel(layout, 'Significant wave height (m)');
linkaxes(axs,'xy')

exportgraphics(layout, ['gfx/ResponseAtContour' suffix '.jpg']) 
exportgraphics(layout, ['gfx/ResponseAtContour' suffix '.pdf']) 
