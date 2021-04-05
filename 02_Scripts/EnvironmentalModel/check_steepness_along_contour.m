clear

load('ArtificialTimeSeries503years.mat')
g=9.80665;
Hs = A.Hs;
V = A.V;
Tp = A.Tp;
S = A.S;

percentile = 99;
[w,thresh]=statplot(V,Hs,1,'prctile',[],[],'k-o',2,percentile);
load('hdc_2d.csv')
HDC.v = hdc_2d(:,1);
HDC.hs = hdc_2d(:,2);

figure('Position', [100 100 1100 350])
sz = 40;
layout = tiledlayout(1,3);
nexttile
hold on
step_size = 50;
ax1 = scatter(V(1:step_size:end), Hs(1:step_size:end), [], S(1:step_size:end), 'filled');
plot(HDC.v, HDC.hs, 'k-');
scatter(HDC.v + 0.5, HDC.hs, sz, maxSteepnessAtV(HDC.v), 'filled', '^', 'MarkerEdgeColor', 'k')
%scatter(HDC.v - 0.5, HDC.hs, sz, highSteepnessAtV(HDC.v), 'filled', 'v', 'MarkerEdgeColor', 'k')
scatter(HDC.v - 0.5, HDC.hs, sz, medianSteepnessAtV(HDC.v), 'filled', 'v', 'MarkerEdgeColor', 'k')
plot(w, thresh, '-k', 'linewidth', 2)
text(w(end - 20) + 1, thresh(end - 20), [num2str(percentile) 'th percentile'], ...
    'fontweight', 'bold');
ylabel('Significant wave height (m)');
ylim([0 20])
c = colorbar;
c.Label.String = 'Steepness (-)';
c.Location = 'north';

ax2 = nexttile;
hold on
[w2, thresh2] = statplot(V, S, 1, 'prctile',[],[],'k-o', 2, 50);
step_size = 10;
scatter(V(1:step_size:end), S(1:step_size:end), '.k')
plot(w2, thresh2, 'xr', 'linewidth',1, 'markersize', 5);
%plot(w2(end), thresh2(end), 'vk', 'markerfacecolor', [0.5 0.5 0.5], 'markeredgecolor', 'k');
plot(w2, medianSteepnessAtV(w2), '--k', 'linewidth', 2, 'color', [0.5 0.5 0.5]);
plot(w2(end), medianSteepnessAtV(w2(end)), 'vk', 'markerfacecolor', [0.5 0.5 0.5], 'markeredgecolor', 'k');
text(21, 0.076, '50th percentile', 'color', 'r', 'fontweight', 'bold', 'horizontalalignment', 'center');
text(1, 0.005, '0.071 - 0.06 \cdot exp(-0.11 \cdot v)', 'color', [0.5 0.5 0.5], ...
    'fontweight', 'bold');
ylabel('Steepness (-)');

Wvals=[];
Svals=[];
Tvals=[];
Hvals=[];
for i=1:length(w)
    bin = V>w(i)-0.5 & V<=w(i)+0.5 & Hs>=thresh(i);
    Wvals=[Wvals;V(bin)];
    Svals=[Svals;A.S(bin)];
    Tvals=[Tvals;A.Tp(bin)];
    Hvals=[Hvals;Hs(bin)/max(Hs(bin))];
end


ax3 = nexttile;
hold on
scatter(Wvals,Svals, '.k')
v = [0:1:40];
s = maxSteepnessAtV(v);
plot(v, s, '-', 'color', [0.5 0.5 0.5], 'linewidth', 2);
plot(v(end), s(end), '^', 'markerfacecolor', [0.5 0.5 0.5], 'markeredgecolor', 'k');
%s = highSteepnessAtV(v);
%plot(v, s, '--', 'color', [0.5 0.5 0.5], 'linewidth', 2);
%plot(v(end), s(end), 'v', 'markerfacecolor', [0.5 0.5 0.5], 'markeredgecolor', 'k');
text(1, 0.082, '0.035 + 0.0028 \cdot v', 'fontweight', 'bold', 'color', [0.5 0.5 0.5])
linkaxes([ax1 ax2 ax3], 'x');
linkaxes([ax2 ax3], 'y');
xlabel(layout, 'Wind speed (m s^{-1})');
ylabel('Steepness at highest 1% h_s (-)');

layout.Padding = 'compact';

exportgraphics(layout, 'gfx/SteepnessAt2dContour.jpg') 
exportgraphics(layout, 'gfx/SteepnessAt2dContour.pdf') 


function s = maxSteepnessAtV(v)
   s = (v <= 19) .* (0.035 + (0.088 - 0.035) / 19 * v) + (v > 19) .* 0.088;
end

function s = highSteepnessAtV(v)
   s = (v <= 18) .* (0.015 + (0.058 - 0.015) / 18 * v) + (v > 18) .* 0.058;
end

function s = medianSteepnessAtV(v)
  s = 0.071 - 0.06 * exp(-0.11 * v);
end