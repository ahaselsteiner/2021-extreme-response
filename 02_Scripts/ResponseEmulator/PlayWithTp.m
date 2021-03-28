


t0 = 3;
y = @(tp) 1 + 7 * exp(-0.55 * ((tp - t0).^2).^(1/3));
%y = @(tp) 1 + 4 ./ (1 + (0.5 * (tp - t0)).^2);

tp = [2:0.1:20];

figure
t = tiledlayout(1,4);
ax1 = nexttile
hold on
plot(tp, y(tp));
%tpdots = [3.1 3.6 7 8 9.3 10.7];
tpdots = [3.1 3.6 6.5 10.9];
ydots = y(tpdots);
plot(tpdots, ydots, '-k')
plot(tpdots, ydots, 'ok')

ax2 = nexttile;
scatter([1, 1, 1, 1], y(tpdots), 'ok', 'markerfacecolor', 'k', 'MarkerFaceAlpha', 0.5)
title('hs=1');

ax3 = nexttile;
tpdots = [5.37 6.2 8.67 12.38];
scatter([1, 1, 1, 1], y(tpdots), 'ok', 'markerfacecolor', 'k', 'MarkerFaceAlpha', 0.5)
title('hs=3');

ax4 = nexttile;
tpdots = [9.3 10.47 12.59 15.37];
scatter([1, 1, 1, 1], y(tpdots), 'ok', 'markerfacecolor', 'k', 'MarkerFaceAlpha', 0.5)
title('hs=9');

linkaxes([ax1 ax2 ax3 ax4], 'y');
ylim([0 max(y(3))])

% percentdiffs = [(ydots(1) - ydots(2)) / ydots(1), ...
%     (ydots(3) - ydots(4)) / ydots(3), ...
%     (ydots(5) - ydots(6)) / ydots(5)]