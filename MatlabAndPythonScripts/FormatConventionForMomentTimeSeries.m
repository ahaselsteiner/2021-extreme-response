v = [3:2:25, 26, 30, 35, 40, 45];
hs = [1:2:15];
y = @(x) x.^a;
% S_p = 2 \pi H_s / (g T_p^2)
% --> tp = sqrt(2 * pi * hs / (g * s_p))
tp1 = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
tp2 = @(hs) sqrt(2 * pi * hs / (9.81 * 0.05));
tp3 = @(hs) sqrt(2 * pi * hs / (9.81 * 0.03));
tp4 = @(hs) sqrt(2 * pi * hs / (9.81 * 0.01));
tp = [tp1(hs), tp2(hs), tp3(hs), tp4(hs)];

% 1. dimension = wind, 2. dimension = hs, 3. dimension = tp
M(1,3,4,:) = timeseries;
% v = 1, hs = 5, tp = tp4(5)