load('D.mat');

half_year = 365/2 * 24;

t = D.t(half_year : end);
v1hr = D.V1hr(half_year : end);
hs = D.Hs(half_year : end);
tz = D.Tz(half_year : end);
tp = 1.2796 * tz; % Assuming a JONSWAP spectrum with gamma = 3.3

R = ResponseEmulator;
n = 1000;
p = rand(n, 1);
r = R.ICDF1hr(v1hr(1:n), hs(1:n), tp(1:n), p);

figure
yyaxis left 
plot(t(1:n), r);
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hr wind speed (m/s)')
xlim([t(1) t(n)]);


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

figure()
subplot(2, 1, 1)
hold on
yyaxis left 
plot(t(1:n), r);
plot(t(block_max_i), r(block_max_i), 'xr');
ylabel('Overturning moment (Nm)')
yyaxis right 
plot(t(1:n), v1hr(1:n));
ylabel('1-hr wind speed (m/s)') 
xlabel('Time (s)');
subplot(2, 1, 2)
pd = fitdist(block_maxima, 'GeneralizedExtremeValue');
qqplot(block_maxima, pd)

x1_am = pd.icdf(exp(-1));
x50_am = pd.icdf(1 - 1/50);


figure('Position', [100 100 900 250])
tiledlayout(1,3);

response_quantiles = [0.5 0.90 0.95];
for i = 1 : 3
    nexttile
    response_quantile = response_quantiles(i);

    HDC.v = [3 : 2 : 37];
    HDC.hs = [5. 5. 5. 5.15 5.4 5.75 6.35 7.05 7.9 8.85 9.95 11.1 ...
     12.2 13.25 14.15 14.85 15.1 14.55];
    HDC.tp = R.tpbreaking(HDC.hs);
    HDC.r = R.ICDF1hr(HDC.v, HDC.hs, HDC.tp, response_quantile);

    IFORM.v = [3 : 2 : 37];
    IFORM.hs = [ 4.1813075   4.31982528  4.45515316  4.63534418  4.91139501  5.31650706 ...
      5.86769763  6.56401926  7.39117007  8.32700302  9.33825991 10.38286802 ...
     11.41011393 12.35470575 13.12327318 13.57407459 13.41291495 10.54162581];
    IFORM.tp = R.tpbreaking(IFORM.hs);
    IFORM.r = R.ICDF1hr(IFORM.v, IFORM.hs, IFORM.tp, response_quantile);

    hold on
    lw = 1;
    plot(IFORM.v, IFORM.hs, '-k', 'linewidth', lw);
    plot(HDC.v, HDC.hs, ':k', 'linewidth', lw);
    sz = 25;
    scatter(IFORM.v, IFORM.hs, sz, IFORM.r / x50_am, 'filled', 'MarkerEdgeColor', 'black')
    scatter(HDC.v, HDC.hs, sz, HDC.r / x50_am, 'filled', 'MarkerEdgeColor', 'black')
    plot([25, 25], [0 16], 'color', [0.5 0.5 0.5]);
    xticks([0 10 20 25 30 40]);
    xlabel('1-hr wind speed (m/s)') 
    if i == 1
        ylabel('Significant wave height (m)');
    end
    xlim([0 40]);
    ylim([0 16]);
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
end
exportgraphics(gcf, 'gfx/ResponseAtContour.jpg') 
exportgraphics(gcf, 'gfx/ResponseAtContour.pdf') 
