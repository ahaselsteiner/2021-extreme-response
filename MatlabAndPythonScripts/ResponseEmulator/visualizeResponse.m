R = ResponseEmulator;

tp = [3:1:20];
v = [0:1:50];
hs = [0:0.5:9];


[tmesh, vmesh, hmesh] = meshgrid(tp, v, hs);
sigmas = R.sigma(vmesh, hmesh, tmesh);
mus = R.mu(vmesh, hmesh, tmesh);
rmedian = R.ICDF1hr(vmesh, hmesh, tmesh, 0.5);

figure
subplot(2, 1, 1);
plot(v, R.mu(v, 3, 10));
ylabel('mu');
subplot(2, 1, 2);
plot(v, R.sigma(v, 3, 10));
ylabel('sigma');
xlabel('v_{1hr} (m/s)');

figure

vslice = [10];   
hslice = [];
tslice = [3 7 15];
slice(tmesh, vmesh, hmesh, rmedian, tslice, vslice, hslice)
colorbar
ylabel('1-hr wind speed (m/s)');
zlabel('Significant wave height (m)');
xlabel('Peak period (s)');
view(3)
%camup([0 0 1])


v = [0:0.2:50];
hs = [0:0.1:9];
[vmesh, hmesh] = meshgrid(v, hs);
tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
sigmas = R.sigma(vmesh, hmesh, tpbreaking(hmesh));
mus = R.mu(vmesh, hmesh, tpbreaking(hmesh));
rmedian = R.ICDF1hr(vmesh, hmesh, tpbreaking(hmesh), 0.5);

capacity = 13 * 10^7;
figure
contour(vmesh, hmesh, rmedian)
hold on
contour(vmesh, hmesh, rmedian, [capacity capacity], 'linewidth', 2)
colorbar
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');

