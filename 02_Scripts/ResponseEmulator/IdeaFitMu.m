figure
hold on
plot(v(1:13), mus(2, 1:13, 2), 'ok')
vv = [0:0.1:25];
ypeak = 7 * 10^7 ./ (1 + 0.03 * (vv - 11.4).^2);
ylin = 3 * 10^6 .* vv;
y = ypeak + ylin;
plot(vv, y)