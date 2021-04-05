suffix = '_artificial500';
load('ArtificialTimeSeries503years.mat');
n = 365.25 * 24 * 500;
%n = length(A.t);
t = A.t(1:n);
v1hr = A.V(1:n);
hs = A.Hs(1:n);
s = A.S(1:n);
tz = sqrt((2 .* pi .* hs) ./ (9.81 .* s));
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

% suffix = '_coastDat2';
% D = importDatasetDFromCSV();
% half_year = 365/2 * 24;
% t = D.t(half_year : end);
% v1hr = D.V(half_year : end);
% hs = D.Hs(half_year : end);
% tz = D.Tz(half_year : end);
% tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

R = ResponseEmulator;
n_short = 1000;
p = rand(n_short, 1);
r_short = R.ICDF1hr(v1hr(1:n_short), hs(1:n_short), tp(1:n_short), p);

n = length(t);
disp('Drawing random samples: uniform.');
p = rand(n, 1);
disp('Drawing random samples: response emulator.');
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

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

% Plot
figure('Position', [100 100 1200 800])
layout = tiledlayout(4,3);
nexttile([1 3])
yyaxis left 
plot(t(1:n_short), r_short);
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n_short), v1hr(1:n_short));
ylabel('1-hour wind speed (m/s)')
xlim([t(1) t(n_short)]);
box off

nexttile([1 3])
hold on
plot(t(1:n), r);
plot(t(block_max_i), r(block_max_i), 'xr');
ylabel('Overturning moment (Nm)')
xlabel('Time (s)');

nexttile([2 1])
hold on
scatter(v1hr, hs, 2, [0.5 0.5 0.5])
scatter(v1hr(block_max_i), hs(block_max_i), 30, block_maxima, 'filled', 'MarkerEdgeColor', 'k');
c = colorbar;
c.Label.String = 'Overturning moment of annual extreme (Nm)';
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m/s)') 
ylabel('Significant wave height (m)')

nexttile([2 1])
hold on
sp = (2 * pi * hs(block_max_i)) ./ (9.81 * tp(block_max_i).^2);
scatter(v1hr, hs, 2, [0.5 0.5 0.5])
scatter(v1hr(block_max_i), hs(block_max_i), 30, sp, 'filled', 'MarkerEdgeColor', 'k');
c = colorbar;
%caxis([1/40 1/25])
%c.Ticks = [1/40 1/30 1/25];
%c.TickLabels = {'1/40', '1/30', '1/25'};  
c.Label.String = 'Steepness of annual extreme (-)';
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m/s)') 
ylabel('Significant wave height (m)')

nexttile([2 1])
hold on
pd = fitdist(block_maxima, 'GeneralizedExtremeValue');
x50_emp = quantile(block_maxima, 1 - 1 / 50);
x50_pred = icdf(pd, 1 - 1 / 50);
plot(x50_pred, x50_emp, 'ok', 'markerfacecolor', [0.3 0.3 1]);
text(x50_pred, 0.9 * x50_pred, {'Empirical 50-year', 'return value'}, ...
    'horizontalalignment', 'left', 'color', 'blue', 'fontsize', 6);
h = qqplot(block_maxima, pd);
set(h(1), 'Marker', 'x')
set(h(1), 'MarkerEdgeColor', 'r')
set(h(2), 'Color', 'k')
set(h(3), 'Color', 'k')
title('');
xlabel('Quantiles of GEV distribution (Nm)');
ylabel('Quantiles of sample (Nm)');

layout.Padding = 'compact';

exportgraphics(layout, ['gfx/ResponseTimeSeries' suffix '.jpg']) 
exportgraphics(layout, ['gfx/ResponseTimeSeries' suffix '.pdf']) 

%x1_am = pd.icdf(exp(-1));


figure('Position', [100 100 700 800])
response_quantiles = [0.5 0.90];
layout = tiledlayout(3, length(response_quantiles));
axs = gobjects(6,1);
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
for i = 1 : length(response_quantiles)
    axs(i) = nexttile(i);
    response_quantile = response_quantiles(i);

    HDC2d_maxsteep.r = R.ICDF1hr(HDC2d_maxsteep.v, HDC2d_maxsteep.hs, HDC2d_maxsteep.tp, response_quantile);
    HDC2d_median.r = R.ICDF1hr(HDC2d_median.v, HDC2d_median.hs, HDC2d_median.tp, response_quantile);
    IFORM_maxsteep.r = R.ICDF1hr(IFORM_maxsteep.v, IFORM_maxsteep.hs, IFORM_maxsteep.tp, response_quantile);
    IFORM_median.r = R.ICDF1hr(IFORM_median.v, IFORM_median.hs, IFORM_median.tp, response_quantile);
    HDC3d.r = R.ICDF1hr(HDC3d.v, HDC3d.hs, HDC3d.tp, response_quantile);
    
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
    sz = 25;
    scatter(IFORM_maxsteep.v, IFORM_maxsteep.hs, sz, IFORM_maxsteep.r / x50_emp, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC2d_maxsteep.v, HDC2d_maxsteep.hs, sz, HDC2d_maxsteep.r / x50_emp, 'filled', 'MarkerEdgeColor', 'black')
    xticks([0 10 20 25 30 40]);
    caxis([0.4 1])
    if i == 1
        legend('IFORM, max. steepness', 'Highest density, max. s.', 'location', 'northwest', 'box', 'off');
    end
    if i == length(response_quantiles)
        cb = colorbar;
        cb.Layout.Tile = 'east';
        cb.Label.String = ['Oveturning moment / ' num2str(x50_emp, '%.3G') ' Nm'];
    end
    
    [max_iform, maxi] = max(IFORM_maxsteep.r / x50_emp);
    txt = ['\leftarrow '  num2str(max_iform, '%4.3f')];
    text(IFORM_maxsteep.v(maxi), IFORM_maxsteep.hs(maxi), txt);
    
    [max_hdc, maxi] = max(HDC2d_maxsteep.r / x50_emp);
    txt = [num2str(max_hdc, '%4.3f') ' \rightarrow'];
    text(HDC2d_maxsteep.v(maxi), HDC2d_maxsteep.hs(maxi), txt, 'HorizontalAlignment','right')
    
    title([num2str(response_quantile) '-quantile']);
    set(gca, 'Layer', 'top')
    
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
    plot(IFORM_median.v, IFORM_median.hs, '-k', 'linewidth', lw);
    plot(HDC2d_median.v, HDC2d_median.hs, ':k', 'linewidth', lw);
    sz = 25;
    scatter(IFORM_median.v, IFORM_median.hs, sz, IFORM_median.r / x50_emp, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC2d_median.v, HDC2d_median.hs, sz, HDC2d_median.r / x50_emp, 'filled', 'MarkerEdgeColor', 'black')
    xticks([0 10 20 25 30 40]);
    caxis([0.4 1])
    if i == 1
        legend('IFORM, median steepness', 'Highest density, median s.', 'location', 'northwest', 'box', 'off');
    end
    
    [max_iform, maxi] = max(IFORM_median.r / x50_emp);
    txt = ['\leftarrow '  num2str(max_iform, '%4.3f')];
    text(IFORM_maxsteep.v(maxi), IFORM_maxsteep.hs(maxi), txt);
    
    [max_hdc, maxi] = max(HDC2d_median.r / x50_emp);
    txt = [num2str(max_hdc, '%4.3f') ' \rightarrow'];
    text(HDC2d_median.v(maxi), HDC2d_median.hs(maxi), txt, 'HorizontalAlignment','right')
    set(gca, 'Layer', 'top')
    
    axs(2 * length(response_quantiles) + i) = nexttile(2 * length(response_quantiles) + i);
    hold on
    patch(x,y, pp_color, 'EdgeColor', 'none', 'HandleVisibility', 'off')
    text(12.5, text_y, 'power production', 'horizontalalignment', 'center');
    text(33, text_y, 'parked', 'horizontalalignment', 'center');
    lw = 1;
    sz = 25;
    scatter(HDC3d.v, HDC3d.hs, sz, HDC3d.r / x50_emp, 'filled', 'MarkerEdgeColor', 'black')
    [max_hdc3, maxi] = max(HDC3d.r / x50_emp);
    txt = [num2str(max_hdc3, '%4.3f') ' \rightarrow'];
    text(HDC3d.v(maxi), HDC3d.hs(maxi), txt, 'HorizontalAlignment','right')
    if i == 1
        text(2, 18, '3D highest density');
    end
    xticks([0 10 20 25 30 40]);

    caxis([0.4 1])
    set(gca, 'Layer', 'top')
end
xlabel(layout, '1-hour wind speed (m s^{-1})') 
ylabel(layout, 'Significant wave height (m)');
linkaxes(axs,'xy')

exportgraphics(layout, ['gfx/ResponseAtContour' suffix '.jpg']) 
exportgraphics(layout, ['gfx/ResponseAtContour' suffix '.pdf']) 
