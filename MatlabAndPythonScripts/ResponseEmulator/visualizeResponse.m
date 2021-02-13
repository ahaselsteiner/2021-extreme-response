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


figure('Position', [100 100 500 500])
vv = [1:2:25 26 30 35 40 45];
n = 6;
r = nan(length(vv), n);
for i = 1 : length(vv)
    r(i, :) = R.randomSample1hr(vv(i), 0, 0, n);
end
plot(vv, r, 'ok')

figure
vslice = [10];   
hslice = [];
tslice = [3 7 15];
slice(tmesh, vmesh, hmesh, rmedian, tslice, vslice, hslice)
c = colorbar;
c.Label.String = 'Median maximum 1-hr oveturning moment (Nm) ';
ylabel('1-hr wind speed (m/s)');
zlabel('Significant wave height (m)');
xlabel('Peak period (s)');
view(3)
%exportgraphics(gca, 'gfx/ResponseField3d.jpg') 
%exportgraphics(gca, 'gfx/ResponseField3d.pdf') 


v = [0:0.2:50];
hs = [0:0.1:9];
[vmesh, hmesh] = meshgrid(v, hs);
tpbreaking = @(hs) sqrt(2 * pi * hs / (9.81 * 1/15));
sigmas = R.sigma(vmesh, hmesh, tpbreaking(hmesh));
mus = R.mu(vmesh, hmesh, tpbreaking(hmesh));
rmedian = R.ICDF1hr(vmesh, hmesh, tpbreaking(hmesh), 0.5);

capacity = 18.77 * 10^7;
figure
contourf(vmesh, hmesh, rmedian)
hold on
c = colorbar;
c.Label.String = 'Median maximum 1-hr oveturning moment (Nm) ';
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');
%exportgraphics(gca, 'gfx/ResponseFieldAtBreakingTp.pdf') 

