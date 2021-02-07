R = ResponseEmulator;

v = [0:1:45];
hs = [0:0.5:9];
tp = [3:1:20];

[vmesh, hmesh, tmesh] = meshgrid(v, hs, tp);
sigmas = R.sigma(vmesh, hmesh, tmesh);
mus = R.mu(vmesh, hmesh, tmesh);

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
tslice = [3 10 15];
slice(vmesh, hmesh, tmesh, mus, vslice, hslice, tslice)
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');
zlabel('Peak period (s)');