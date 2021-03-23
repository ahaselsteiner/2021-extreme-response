suffix = '_artificial500';
load('ArtificialTimeSeries508years.mat');
n = 365.24 * 24 * 500;
%n = length(A.t);
t = A.t(1:n);
v1hr = A.V(1:n);
hs = A.Hs(1:n);
s = A.S(1:n);
tz = sqrt((2 .* pi .* hs) ./ (9.81 .* s));
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

% suffix = '_artificial50';
% load('ArtificialTimeSeries51years.mat');
% n = 365.24 * 24 * 50;
% %n = length(A.t);
% t = A.t(1:n);
% v1hr = A.V(1:n);
% hs = A.Hs(1:n);
% s = A.S(1:n);
% tz = sqrt((2 .* pi .* hs) ./ (9.81 .* s));
% tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

% suffix = '_coastDat2';
% D = importDatasetDFromCSV();
% half_year = 365/2 * 24;
% t = D.t(half_year : end);
% v1hr = D.V(half_year : end);
% hs = D.Hs(half_year : end);
% tz = D.Tz(half_year : end);
% tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

R = ResponseEmulator;
n = 1000;
p = rand(n, 1);
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

figure('Position', [100 100 1200 800])
layout = tiledlayout(4,3);
nexttile([1 3])
yyaxis left 
plot(t(1:n), r);
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hour wind speed (m/s)')
xlim([t(1) t(n)]);
box off

n = length(t);
p = rand(n, 1);
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

block_length = 365.25 * 24;
full_years = floor(n / block_length);
pds = [];
maxima = zeros(full_years, 1);
blocks = zeros(full_years, block_length);
block_maxima = zeros(full_years, 1);
block_max_i = zeros(full_years, 1);
for i = 1 : full_years
    blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
    [block_maxima(i), maxid] = max(blocks(i,:));
    block_max_i(i) = maxid + (i - 1) * block_length;
end

nexttile([1 3])
hold on
yyaxis left 
plot(t(1:n), r);
plot(t(block_max_i), r(block_max_i), 'xr');
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hour wind speed (m/s)') 
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
caxis([1/40 1/25])
c.Ticks = [1/40 1/30 1/25];
c.TickLabels = {'1/40', '1/30', '1/25'};  
c.Label.String = 'Steepness of annual extreme (-)';
box off
set(gca, 'XLim', [0, get(gca, 'XLim') * [0; 1]])
set(gca, 'YLim', [0, get(gca, 'YLim') * [0; 1]])
xlabel('1-hour wind speed (m/s)') 
ylabel('Significant wave height (m)')

nexttile([2 1])
pd = fitdist(block_maxima, 'GeneralizedExtremeValue');
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

x1_am = pd.icdf(exp(-1));
x50_am = pd.icdf(1 - 1/50);


figure('Position', [100 100 900 500])
layout = tiledlayout(2,3);
axs = gobjects(6,1);
response_quantiles = [0.5 0.90 0.95];
for i = 1 : 3
    axs(i) = nexttile(i)
    response_quantile = response_quantiles(i);

    HDC.v = [3 : 2 : 37];
    HDC.hs = [4.8   4.75  4.85  5.05  5.4   5.85  6.45  7.15  8.    8.9  ...
        9.9  10.95 12.05 13.05 13.95 14.7  15.05 14.65];
    HDC.tp = R.tpbreaking(HDC.hs);
    HDC.r = R.ICDF1hr(HDC.v, HDC.hs, HDC.tp, response_quantile);

    IFORM.v = [3 : 2 : 37];
    IFORM.hs = [4.04315297  4.12920946  4.3018694   4.56832996  4.93456815  5.40542683 ...
      5.98541001  6.67513839  7.46840187  8.35168793  9.3062699  10.29836998 ...
     11.28675709 12.21439403 12.99515329 13.49944388 13.44351053 10.77269547];
    IFORM.tp = R.tpbreaking(IFORM.hs);
    IFORM.r = R.ICDF1hr(IFORM.v, IFORM.hs, IFORM.tp, response_quantile);

    HDC3d.v = [zeros(1, 5) + 10, zeros(1, 7) + 15, zeros(1, 9) + 20, zeros(1, 11) + 25, ...
        zeros(1, 11) + 30, zeros(1, 10) + 35, zeros(1,3) + 40];
    HDC3d.tp = [4:1:8, 4:1:10, 4:1:12, 5:1:15, 6:1:16, 8:1:17, 13:1:15];
    HDC3d.hs = [2.53173368 3.19510417 3.91335884 4.52937104 ...
     5.01602721, 2.60282609 3.48992959 4.3083047  5.04892388 ...
     5.73193509 6.24995537 6.59457612, 2.50906735 3.55482679 4.56478178 5.55231783 6.47480862 ...
     7.30803931 7.9784241  8.48790181 8.74751375, 3.10204817  4.38187789  ...
     5.60762783  6.81088122  7.97538425  9.04264091 ...
     9.97726028 10.73933716 11.2496693  11.44413393 11.11084557, 3.57574695 ...
     4.97246684  6.50169525  7.94746561  9.33996798 10.65420517 ...
     11.86345709 12.91004791 13.72360281 14.20768759 14.1814108 5.2 ...
     6.6668862   8.52965439 10.19484159 11.76382308 13.19914032 ...
     14.49034801 15.53561057 16.21090588 16.12669259, 10.4 12.64255248 13.94488443];
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
    plot(IFORM.v, IFORM.hs, '-k', 'linewidth', lw);
    plot(HDC.v, HDC.hs, ':k', 'linewidth', lw);
    sz = 25;
    scatter(IFORM.v, IFORM.hs, sz, IFORM.r / x50_am, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC.v, HDC.hs, sz, HDC.r / x50_am, 'filled', 'MarkerEdgeColor', 'black')
    xticks([0 10 20 25 30 40]);
    caxis([0.4 1])
    if i == 1
        legend('IFORM', 'Highest density', 'location', 'northwest', 'box', 'off');
    end
    if i == 3
        cb = colorbar;
        cb.Layout.Tile = 'east';
        cb.Label.String = ['Oveturning moment / ' num2str(x50_am, '%.3G') ' Nm'];
    end
    
    [max_iform, maxi] = max(IFORM.r / x50_am);
    txt = ['\leftarrow '  num2str(max_iform, '%4.3f')];
    text(IFORM.v(maxi), IFORM.hs(maxi), txt);
    
    [max_hdc, maxi] = max(HDC.r / x50_am);
    txt = [num2str(max_hdc, '%4.3f') ' \rightarrow'];
    text(HDC.v(maxi), HDC.hs(maxi), txt, 'HorizontalAlignment','right')
    
    title([num2str(response_quantile) '-quantile']);
    set(gca, 'Layer', 'top')
    
    axs(3 + i) = nexttile(3 + i);
    hold on
    patch(x,y, pp_color, 'EdgeColor', 'none', 'HandleVisibility', 'off')
    text(12.5, text_y, 'power production', 'horizontalalignment', 'center');
    text(33, text_y, 'parked', 'horizontalalignment', 'center');
    lw = 1;
    sz = 25;
    scatter(HDC3d.v, HDC3d.hs, sz, HDC3d.r / x50_am, 'filled', 'MarkerEdgeColor', 'black')
    [max_hdc3, maxi] = max(HDC3d.r / x50_am);
    txt = [num2str(max_hdc3, '%4.3f') ' \rightarrow'];
    text(HDC3d.v(maxi), HDC3d.hs(maxi), txt, 'HorizontalAlignment','right')
    if i == 1
        text(2, 18, '3D contour');
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
