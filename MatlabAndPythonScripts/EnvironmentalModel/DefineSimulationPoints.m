load('datasets-complete-DEF-3-variables.mat')


% According to IEC61400-3-1:2019-04, page 18, a logarithmic profile and a 
% power law profile are commonly used. Liu et al.
% (10.1016/j.renene.2019.02.011) use the power law (see their Eq. 1).
hubHeight = 90;
alpha = 0.14; % as for normal wind speed in IEC 61400-3-1 p. 35
v10hub = D.V .* (hubHeight/10)^alpha;
v1hhub = v10hub * 0.95;
Hs = D.Hs;
Tz = D.Tz;

fig1 = figure();
subplot(1, 2, 1)
scatter(v10hub, D.Hs, 'ok', 'MarkerFaceColor', [0.5 0.5 0.5], ...
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
xlabel('Wind speed at hub height (m/s)');
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
    %scatter(TzInBin{i}, HsInBin{i}, 'ok', 'MarkerFaceColor', [0.5 0.5 0.5], ...
    %'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5)
end
scatter([2:1:9], zeros(8,1) + 1,  'xr', 'linewidth', 2);
scatter([5:1:11], zeros(7,1) + 5,  'xr', 'linewidth', 2);
scatter([8:1:13], zeros(6,1) + 10,  'xr', 'linewidth', 2);
xlim([0 14]);
ylim([0 12]);
xlabel('Zero-up-crossing period (s)');
ylabel('Significant wave height (m)');

fig2 = figure();
hold on
scatter(v10hub, Hs, 'ok', 'MarkerFaceColor', [0.5 0.5 0.5], ...
'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5)

VSim = [1, 1, 1, 1, 3, 3, 3, 3, 3, 5, 5, 5, 5, 5, 5, 7, 7, 7, 7, 7, 7, 9, 9, 9, 9, 9, 9, 9, 11 11 11 11 11 11 11];
HSim = [0, 1, 2, 3, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 6, 0, 1, 2, 3, 4, 5, 6] + 0.5;

vPoints = [[1:2:25], 26, [30:5:45]];
hsPoints = [1 : 2 : 15];
[VSim, HSim] = meshgrid(vPoints, hsPoints)
scatter(VSim(:), HSim(:),  'xr', 'linewidth', 2);
xlabel('Wind speed at hub height (m/s)');
ylabel('Significant wave height (m)');


