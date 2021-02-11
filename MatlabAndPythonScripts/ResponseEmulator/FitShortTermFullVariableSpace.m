%load('OvrDataEmulator');
maxr = max(Ovr,[],4);
gridSize = size(maxr);
currentNrEntries = sum(sum(sum(maxr>0)))
r = squeeze(Ovr(3,1,1,:));

% GEV parameters
ks = zeros(gridSize) - 0.2;
sigmas = nan(gridSize);
mus = nan(gridSize);


FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)

[vgrid, hgrid] = meshgrid(v, hs);
sigmas = nan([size(vgrid), 4]);
mus = nan([size(vgrid), 4]);

R = ResponseEmulator;
for i = 1 : 4
    sigmas(:, :, i) = R.sigma(vgrid, hgrid, tp(hgrid, i)) .* (1 + normrnd(0, 0.02, size(vgrid)));
    mus(:, :, i) = R.mu(vgrid, hgrid, tp(hgrid, i)) .* (1 + normrnd(0, 0.02, size(vgrid)));
end

figure
for i = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(sigmas(:, :, i)), 10);
    title(['Tp index = ' num2str(i) ]);
    caxis([0.4 2.5] * 10^7)
    if mod(i, 2) == 1
        ylabel('Significant wave height (m)');
    end
    if i >= 3
        xlabel('1-hr wind speed (m/s)');
    end
end
c = colorbar;
c.Label.String = '\sigma (Nm) ';
c.Layout.Tile = 'east';

figure
for i = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(mus(:, :, i)), 10);
    title(['Tp index = ' num2str(i) ]);
    caxis([2 10] * 10^7)
    if mod(i, 2) == 1
        ylabel('Significant wave height (m)');
    end
    if i >= 3
        xlabel('1-hr wind speed (m/s)');
    end
end
c = colorbar;
c.Label.String = '\mu (Nm) ';
c.Layout.Tile = 'east';

for i = 1 : 4
    t2d = squeeze(tgrid(:,:,i));
    temp = [vgrid(:), hgrid(:), t2d(:)];
    sigma2d = squeeze(sigmas(:,:,i));
    mu2d = squeeze(sigmas(:,:,i));
    if i == 1
        X = temp;
        ysigma = sigma2d(:);
        ymu = mu2d(:);
    else
        X = [X; temp];
        ysigma = [ysigma; sigma2d(:)];
        ymu = [ymu; mu2d(:)];
    end
end

% See: https://de.mathworks.com/help/stats/fitnlm.html
% x(:, 1) = v, x(:, 2) = hs, x(:, 3) = tp
modelfunSigma = @(b, x) 0 + (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* (b(1) .* x(:,1).^2 + ...
    (x(:,1) <= 25) .* (b(2) .* x(:,1) - b(3) .* x(:,1).^2) + b(4) .* x(:,2) ./ (1 + 0.05 .* (x(:,3) - 3)));

beta0 = [10^5 10^5 10^5 10^5];
mdlSigma = fitnlm(X, ysigma, modelfunSigma, beta0)

sigmaHat = predict(mdlSigma, X);

figure
nexttile
scatter3(X(:,1), X(:,2), X(:,3), 20, ysigma)
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');
zlabel('Significant wave height');
title('Observed')

nexttile
scatter3(X(:,1), X(:,2), X(:,3), 20, sigmaHat)
xlabel('1-hr wind speed (m/s)');
ylabel('Significant wave height (m)');
zlabel('Significant wave height');
title('Predicted')

c = colorbar;
c.Label.String = '\sigma (Nm) ';
c.Layout.Tile = 'east';

figure
nexttile
contourf(vgrid, hgrid, squeeze(sigmas(:, :, i)))
title('Observed')
nexttile
sigmatp1 = nan(size(vgrid));
for i = 1 : size(vgrid, 1)
    for j = 1 : size(vgrid, 2)
        X = [vgrid(i, j), hgrid(i, j), tp(hgrid(i, j), 1)];
        sigmatp1(i, j) = predict(mdlSigma, X);
    end
end
contourf(vgrid, hgrid, sigmatp1, 10);
title('Predicted');

c = colorbar;
c.Label.String = '\sigma (Nm) ';
c.Layout.Tile = 'east';