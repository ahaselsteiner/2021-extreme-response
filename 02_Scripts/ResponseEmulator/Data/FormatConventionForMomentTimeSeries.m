% ** Explanation about the file format: **
%
% 1. dimension = wind, 2. dimension = hs, 3. dimension = tp
% M(1,3,4,:) = 'Response time series (as a double vector)';
% v(1), hs(3), tp(hs(3), 4)
% v = 1, hs = 5, tp = 13.4889

v = [1:2:25, 26, 30, 35, 40, 45];
hs = [0 1:2:15];
y = @(x) x.^a;

% S_p = (2 pi H_s) / (g T_p^2)
% --> tp = sqrt(2 * pi * hs / (g * s_p))
tp1 = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
tp2 = @(hs) sqrt(2 * pi * hs / (9.81 * 1/20));
tp3 = @(hs) sqrt(2 * pi * hs / (9.81 * 1/20)) + 1 ./ (1 + sqrt(hs + 2)) * 8;
tp4 = @(hs) sqrt(2 * pi * hs / (9.81 * 1/20)) + 1 ./ (1 + sqrt(hs + 2)) * 20;
tp = @(hs, idx) (idx == 1) .* tp1(hs) + (idx == 2) .* tp2(hs) + (idx ==3) .* tp3(hs) + (idx ==4) .* tp4(hs);

% ** End of explanation. **