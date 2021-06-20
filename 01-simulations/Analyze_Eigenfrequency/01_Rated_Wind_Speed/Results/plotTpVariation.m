r = nan(8,6);
for i = 1 : 6
    fileName = ['simTzHs1S' num2str(i) '.mat'];
    load(fileName);
    r(:, i) = Ovr;
end
Tp = 1.2796 * Tz; % Assuming a JONSWAP spectrum with gamma = 3.3

figOvrTz = figure ('Position', [100 100 500 800]);
t = tiledlayout(3,1);
ax1 = nexttile;
hold on
ms = 50;
for i = 1 : 6
    h = scatter(Tp, r(:,i), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
plot(Tp, mean(r'), '--k', 'Displayname', 'Average')

title('V = 11.4 m s^{-1}, H_s = 1 m')


ax2 = nexttile;
r = nan(7,6);
for i = 1 : 6
    fileName = ['simTzHs5S' num2str(i) '.mat'];
    load(fileName);
    r(:, i) = Ovr;
end
Tp = 1.2796 * Tz; % Assuming a JONSWAP spectrum with gamma = 3.3
hold on
for i = 1 : 6
    h = scatter(Tp, r(:,i), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
plot(Tp, mean(r'), '--k', 'Displayname', 'Average')
title('V = 11.4 m s^{-1}, H_s = 5 m')
lg = legend({'Random realization', 'Average over realizations'}, 'NumColumns', 2);
lg.Layout.Tile = 'North';

ax3 = nexttile;
r = nan(6,6);
for i = 1 : 6
    fileName = ['simTzHs10S' num2str(i) '.mat'];
    load(fileName);
    r(:, i) = Ovr;
end
Tp = 1.2796 * Tz; % Assuming a JONSWAP spectrum with gamma = 3.3
hold on
for i = 1 : 6
    h = scatter(Tp, r(:,i), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
plot(Tp, mean(r'), '--k', 'Displayname', 'Average')
title('V = 35 m s^{-1}, H_s = 10 m')

xlabel(t, 'Spectral peak period (s)');
ylabel(t, '1-hour maximum overturning moment (Nm)');
linkaxes([ax1 ax2 ax3], 'x')
t.Padding = 'compact';
exportgraphics(t, 'EigenfrequencyInfluenceTp.pdf') 

