D = importDatasetDFromCSV();
V = D.V; % 1-hour mean value at hub height (90 m)
Hs = D.Hs;
Tz = D.Tz;

fig1 = figure('Position', [100 100 800 400]);
subplot(1, 2, 1)
scatter(V, Hs, 'ok', 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5)
hold on
intervalCenterV = [11.4, 11.4, 35];
intervalWidthV = [1, 1, 5];
intervalLowerV = intervalCenterV - intervalWidthV / 2;
intervalUpperV = intervalCenterV + intervalWidthV / 2;
assumedHs = [1, 5, 10];
for i = 1 : length(intervalCenterV)
    %rectangle('Position', [intervalLowerV(i) 0 intervalWidthV(i) 12])
    scatter(intervalCenterV(i), assumedHs(i), 'xr', 'linewidth', 2);
end
xlabel('1-hour wind speed at hub height (m s^{-1})');
ylabel('Significant wave height (m)');

intervalWidthHs = [0.5, 0.5, 2];
intervalLowerHs = assumedHs - intervalWidthHs / 2;
intervalUpperHs = assumedHs + intervalWidthHs / 2;
HsInBin = cell(3, 1);
TzInBin = cell(3, 1);

subplot(1, 2, 2);
hold on
scatter(Tz, Hs, 'ok', 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5)
for i = 1 : length(intervalWidthHs)
    idx = (Hs > intervalLowerHs(i)) & (Hs < intervalUpperHs(i));
    HsInBin{i} = Hs(idx);
    TzInBin{i} = Tz(idx);
end
scatter([2:1:9], zeros(8,1) + 1,  'xr', 'linewidth', 2);
scatter([5:1:11], zeros(7,1) + 5,  'xr', 'linewidth', 2);
scatter([8:1:13], zeros(6,1) + 10,  'xr', 'linewidth', 2);
xlim([0 14]);
ylim([0 12]);
xlabel('Zero-up-crossing period (s)');
ylabel('Significant wave height (m)');
