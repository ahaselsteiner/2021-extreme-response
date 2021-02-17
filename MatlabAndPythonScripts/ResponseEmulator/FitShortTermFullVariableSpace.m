SHAPE = -0.2;
N_BLOCKS = 60;

%load('OvrDataEmulator');
maxr = max(Ovr,[],4);
gridSize = size(maxr);
currentNrEntries = sum(sum(sum(maxr>0)))

% Checking whether the results make sense:
figure('Position', [100 100 900 600])
subplot(3, 1, 1:2);
addpath('03_Calm_Sea_Complete_Wind')
load 'CalmSeaComplete.mat';
OvrAllSeeds = [Ovr_S1; Ovr_S2; Ovr_S3; Ovr_S4; Ovr_S5; Ovr_S6];
OvrAllSeeds = OvrAllSeeds(:, 1:18);
hold on
ms = 50;
vv = [3:2:25 26 30 35 40 45 50];
for i = 1 : 6
    h = scatter(vv, OvrAllSeeds(i,:), ms, 'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k', 'DisplayName', 'Hs = 0 m');
    if i > 1 
        set(h, 'HandleVisibility', 'off')
    end
end
hold on
FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)
h = scatter(v, maxr(:, 1, 1), ms, 'MarkerFaceColor', 'red', ...
    'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k', 'DisplayName', 'Hs = 1 m');
legend('box', 'off', 'location', 'eastoutside')
xlabel('1-hr wind speed (m/s)');
ylabel('Max 1-hr overturning moment (Nm)');

subplot(3, 1, 3);
plot(squeeze(Ovr(14, 1, 1, :)))
xlabel('Time step (-)');
ylabel('Max 1-hr overturning moment (Nm)');
box off
legend('V = 26 m/s, Hs = 1 m', 'box', 'off', 'location', 'eastoutside');

exportgraphics(gcf, 'gfx/ValidtyCheckHs1.jpg') 

% GEV parameters
ks = zeros(gridSize) - 0.2;
sigmas = nan(gridSize);
mus = nan(gridSize);





[vgrid, hgrid] = meshgrid(v, hs);
sigmas = nan([size(vgrid), 4]);
mus = nan([size(vgrid), 4]);

R = ResponseEmulator;
for i = 1 : gridSize(1)
    for j = 1 : gridSize(2)
        for k = 1 : gridSize(3)
            if maxr(i, j, k) > 0 
                r = Ovr(i, j, k, :);
                pd = gevToBlockMaxima(r, SHAPE, N_BLOCKS);
                sigmas(j, i, k) = pd.sigma;
                mus(j, i, k) = pd.mu;
            else
                %sigmas(j, i, k) = R.sigma(vgrid(j, i), hgrid(j, i), tp(hgrid(j, i), k)) .* (1 + normrnd(0, 0.02));
                %mus(j, i, k) = R.mu(vgrid(j, i), hgrid(j, i), tp(hgrid(j, i), k)) .* (1 + normrnd(0, 0.02));
                sigmas(j, i, k) = NaN;
                mus(j, i, k) = NaN;
            end
        end
    end
end

% figure
% for i = 1 : 4
%     nexttile
%     contourf(vgrid, hgrid, squeeze(sigmas(:, :, i)), 10);
%     title(['Tp index = ' num2str(i) ]);
%     caxis([0.4 2.5] * 10^7)
%     if mod(i, 2) == 1
%         ylabel('Significant wave height (m)');
%     end
%     if i >= 3
%         xlabel('1-hr wind speed (m/s)');
%     end
% end
% c = colorbar;
% c.Label.String = '\sigma (Nm) ';
% c.Layout.Tile = 'east';
% 
% figure
% for i = 1 : 4
%     nexttile
%     contourf(vgrid, hgrid, squeeze(mus(:, :, i)), 10);
%     title(['Tp index = ' num2str(i) ]);
%     caxis([2 10] * 10^7)
%     if mod(i, 2) == 1
%         ylabel('Significant wave height (m)');
%     end
%     if i >= 3
%         xlabel('1-hr wind speed (m/s)');
%     end
% end
% c = colorbar;
% c.Label.String = '\mu (Nm) ';
% c.Layout.Tile = 'east';

for i = 1 : 4
    t2d = squeeze(tp(hgrid, i));
    temp = [vgrid(:), hgrid(:), t2d(:)];
    sigma2d = squeeze(sigmas(:,:,i));
    mu2d = squeeze(mus(:,:,i));
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
modelfunSigma = @(b, x) (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* ...
    (b(1) .* x(:,1).^2 + ...
    (x(:,1) <= 25) .* (b(2) .* x(:,1) + b(3) .* x(:,1).^2) + ...
    b(4) .* x(:,2).^2 ./ (1 + 0.005 .* (x(:,3) - 3).^2));
beta0 = [10^5 10^5 10^5 10^5];
mdlSigma = fitnlm(X, ysigma, modelfunSigma, beta0, 'ErrorModel', 'proportional')
sigmaHat = predict(mdlSigma, X);

modelfunMu = @(b, x) (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* ...
    (b(1) .* x(:,1).^2 + ...
    (x(:,1) <= 25) .* (b(2) .* x(:,1) + b(3) .* x(:,1).^2) + ...
    b(4) .* x(:,2).^1.3 ./ (1 + 0.005 .* (x(:,3) - 3).^2));
% modelfunMu = @(b, x) (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* ...
%     ((x(:,1) <= 11) .* b(1) .* x(:,1) + ...
%     (x(:,1) > 11 & x(:,1) <= 13) .* b(1) .* 11 + ...
%     (x(:,1) > 13 & x(:,1) <= 25) .* (b(1) .* 11 + b(2) .* (x(:,1) - 13) + b(3) .* (x(:,1) - 13).^2) + ...
%     (x(:,1) > 25) .* b(4) .* x(:,1).^2 + ...
%     b(5) .* x(:,2).^1.25 ./ (1 + 0.005 .* (x(:,3) - 3).^2));
beta0 = [10^5 10^5 10^5 10^5];
mdlMu = fitnlm(X, ymu, modelfunMu, beta0, 'ErrorModel', 'proportional')
muHat = predict(mdlMu, X);

figure('Position', [100 100 900 500])
t = tiledlayout(3, 4);
for tpid = 1 : 4
    nexttile
    vv = [0 : 0.1 : 45];
    colors = {'red', 'blue', 'black'};
    for i = 1 : 3
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        plot(v, sigmas(i, :, tpid), 'o', 'color', colors{i});
        labelhs = ['H_s = ' num2str(hs(i)) ' m'];
        plot(vv, predict(mdlSigma, X), 'color', colors{i}, 'DisplayName', labelhs);
    end
    xlabel('1-hr wind speed (m/s)');
    ylabel('\sigma (Nm)');
    title(['t_{p' num2str(tpid) '}']);
    if tpid == 1
        legend('box', 'off');
    end
end

for tpid = 1 : 4
    nexttile
    vv = [0 : 0.1 : 45];
    colors = {'red', 'blue', 'black'};
    for i = 1 : 3
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        plot(v, mus(i, :, tpid), 'o', 'color', colors{i});
        labelhs = ['H_s = ' num2str(hs(i)) ' m'];
        plot(vv, predict(mdlMu, X), 'color', colors{i}, 'DisplayName', labelhs);
    end
    xlabel('1-hr wind speed (m/s)');
    ylabel('\mu (Nm)');
    title(['t_{p' num2str(tpid) '}']);
    if tpid == 1
        legend('box', 'off');
    end
end

for tpid = 1 : 4
    nexttile
    vv = [0 : 0.1 : 50];
    colors = {'red', 'blue', 'black'};
    for i = 1 : 3
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        plot(v, maxr(:, i, tpid), 'o', 'color', colors{i});
        labelhs = ['H_s = ' num2str(hs(i)) ' m'];
        %plot(vv, predict(mdlMu, X), 'color', colors{i}, 'DisplayName', labelhs);
    end
    xlabel('1-hr wind speed (m/s)');
    ylabel('1-hr maximum moment (Nm)');
    title(['t_{p' num2str(tpid) '}']);
    if tpid == 1
        legend('box', 'off');
    end
end

% figure
% nexttile
% scatter3(X(:,1), X(:,2), X(:,3), 20, ysigma)
% xlabel('1-hr wind speed (m/s)');
% ylabel('Significant wave height (m)');
% zlabel('Significant wave height');
% title('Observed')
% 
% nexttile
% scatter3(X(:,1), X(:,2), X(:,3), 20, sigmaHat)
% xlabel('1-hr wind speed (m/s)');
% ylabel('Significant wave height (m)');
% zlabel('Significant wave height');
% title('Predicted')
% c = colorbar;
% c.Label.String = '\sigma (Nm) ';
% c.Layout.Tile = 'east';
% sgtitle('sigma')


figure('Position', [100 100 500 800])
t = tiledlayout(4, 2);
clower = min(sigmas(:));
cupper = max(sigmas(:)) * 0.95;
for ii = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(sigmas(:, :, ii)), 10)
    title(['from 1-hr simulation, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper])
    nexttile
    sigmatp1 = nan(size(vgrid));
    for i = 1 : size(vgrid, 1)
        for j = 1 : size(vgrid, 2)
            Xtemp = [vgrid(i, j), hgrid(i, j), tp(hgrid(i, j), ii)];
            sigmatp1(i, j) = predict(mdlSigma, Xtemp);
        end
    end
    contourf(vgrid, hgrid, sigmatp1, 10);
    title(['predicted, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper])
end

c = colorbar;
c.Label.String = '\sigma (Nm) ';
c.Layout.Tile = 'east';
t.XLabel.String = '1-hr wind speed (m/s)';
t.YLabel.String = 'Significant wave height (m)';
%sgtitle('sigma')
exportgraphics(gcf, 'gfx/EmulatorFit_Sigma.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFit_Sigma.pdf') 

% mu
% figure
% nexttile
% scatter3(X(:,1), X(:,2), X(:,3), 20, ymu)
% xlabel('1-hr wind speed (m/s)');
% ylabel('Significant wave height (m)');
% zlabel('Significant wave height');
% title('Observed')
% 
% nexttile
% scatter3(X(:,1), X(:,2), X(:,3), 20, muHat)
% xlabel('1-hr wind speed (m/s)');
% ylabel('Significant wave height (m)');
% zlabel('Significant wave height');
% title('Predicted')
% c = colorbar;
% c.Label.String = '\sigma (Nm) ';
% c.Layout.Tile = 'east';
% sgtitle('mu')


figure('Position', [100 100 500 800])
t = tiledlayout(4, 2);
clower = min(mus(:));
cupper = max(mus(:)) * 0.95;
for ii = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(mus(:, :, ii)), 10)
    title(['from 1-hr simulation, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper]);
    nexttile
    mutp1 = nan(size(vgrid));
    for i = 1 : size(vgrid, 1)
        for j = 1 : size(vgrid, 2)
            Xtemp = [vgrid(i, j), hgrid(i, j), tp(hgrid(i, j), ii)];
            mutp1(i, j) = predict(mdlMu, Xtemp);
        end
    end
    contourf(vgrid, hgrid, mutp1, 10);
    title(['predicted, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper]);
end

c = colorbar;
c.Label.String = '\mu (Nm) ';
c.Layout.Tile = 'east';
t.XLabel.String = '1-hr wind speed (m/s)';
t.YLabel.String = 'Significant wave height (m)';
exportgraphics(gcf, 'gfx/EmulatorFit_Mu.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFit_Mu.pdf') 

%sgtitle('mu')