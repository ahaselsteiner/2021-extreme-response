SHAPE = 'free';
N_BLOCKS = 60;

load('OvrDataEmulatorDiffSeed');
maxr = max(Ovr,[],4);
gridSize = size(maxr);
maxr(maxr==0)=NaN;
currentNrEntries = sum(sum(sum(maxr>0)))
FormatConventionForMomentTimeSeries % to get the variables: v, hs, tp(hs, idx)


% Checking whether the results make sense:
c1 = [0, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];
c3 = [0.9290, 0.6940, 0.1250];
c4 = [0.4660, 0.6740, 0.1880];
colorsTp = {c1, c2, c3, c4};
darker = 0.6;
darker_colors = [c1; c2; c3; c4] * darker;
vid = 16;
hsid = 1;

figure('Position', [100 100 900 900])
subplot(6, 1, 1:2);
hold on
ms = 50;

for i = 1 : 4
    h = scatter(v, maxr(:, hsid, i), ms, 'MarkerFaceColor', colorsTp{i}, ...
        'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'k', 'DisplayName', ['Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), i))]);
end
legend('box', 'off', 'location', 'eastoutside')
limsy=get(gca,'YLim');
set(gca,'Ylim',[0 limsy(2)]);
xlabel('1-hour wind speed (m/s)');
ylabel('Max 1-hour overturning moment (Nm)');

for i = 1 : 4
    subplot(6, 1, 3 + (i-1));
    plot(minutes(Time/60), squeeze(Ovr(vid, hsid, i, :)), 'color', colorsTp{i})
    ylabel('Overturning moment (Nm)');
    box off
    legend(['V = ' num2str(v(vid)) ' m/s, Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), i))], 'box', 'off', 'location', 'eastoutside');
    box off
end


[vgrid, hgrid] = meshgrid(v, hs);

% GEV parameters
xis = nan([size(vgrid), 4]);
sigmas = nan([size(vgrid), 4]);
mus = nan([size(vgrid), 4]);

R = ResponseEmulator;
for i = 1 : gridSize(1)
    for j = 1 : gridSize(2)
        for k = 1 : gridSize(3)
            if maxr(i, j, k) > 0 
                r = Ovr(i, j, k, :);
                pd = gevToBlockMaxima(r, N_BLOCKS, SHAPE);
                xis(j, i, k) = pd.k;
                sigmas(j, i, k) = pd.sigma;
                mus(j, i, k) = pd.mu;
            else
                xis(j, i, k) = NaN;
                sigmas(j, i, k) = NaN;
                mus(j, i, k) = NaN;
            end
        end
    end
end


for i = 1 : 4
    t2d = squeeze(tp(hgrid, i));
    temp = [vgrid(:), hgrid(:), t2d(:)];
    xi2d = squeeze(xis(:,:,i));
    sigma2d = squeeze(sigmas(:,:,i));
    mu2d = squeeze(mus(:,:,i));
    if i == 1
        X = temp;
        yk = xi2d(:);
        ysigma = sigma2d(:);
        ymu = mu2d(:);
    else
        X = [X; temp];
        yk = [yk; xi2d(:)];
        ysigma = [ysigma; sigma2d(:)];
        ymu = [ymu; mu2d(:)];
    end
end

% See: https://de.mathworks.com/help/stats/fitnlm.html
% x(:, 1) = v, x(:, 2) = hs, x(:, 3) = tp
modelfunXi = @(b, x) (x(:,1) <= 25) .* (-0.1 - 0.5 ./ (1 + 0.15 .* (x(:,1) - 12.5).^2) + 0.23 ./ (1 + 0.05 .* (x(:,1) - 18.5).^2) + ...
    x(:,2).^(1/3) .* ((-0.01 -         (-0.1 - 0.5 ./ (1 + 0.15 .* (x(:,1) - 12.5).^2) + 0.23 ./ (1 + 0.05 .* (x(:,1) - 18.5).^2))) ./ 15^(1/3))) + ...
    (x(:,1) > 25) .* (-0.2 +  x(:,2).^(1/3) .* (-0.01 - -0.2) / 15.^(1/3))
beta0 = [-0.1];
mdlXi = fitnlm(X, yk, modelfunXi, beta0, 'ErrorModel', 'proportional')
xiHat = predict(mdlXi, X);

modelfunMu = @(b, x) (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* ...
    ((((x(:,1) <= 25) .* (3.2586e+06 .* x(:,1) + 7.1014e+07  ./ (1 + 0.040792 * (x(:,1) - 11.6).^2) - 7.0845e+07  ./ (1 + 0.041221 * (0 - 11.6).^2)) + ... % third term is used to force v(0) = 0
    (x(:,1) > 25 ) .* (3.9 * 10^4 .* x(:,1).^2)).^2.0 + ...
    ((1 + (x(:,1) > 25) * 0.3) .* b(4) .* x(:,2) .* (1 + b(5) .* exp(b(6) * abs(x(:,3) - 3))) ).^2.0).^(1/2.0));
beta0 = [10^6 10^6 0.02 10^6 10 -1];
mdlMu = fitnlm(X, ymu, modelfunMu, beta0, 'ErrorModel', 'proportional')
muHat = predict(mdlMu, X);

modelfunSigma = @(b, x) (x(:,3) >= sqrt(2 * pi .* x(:,2) ./ (9.81 .* 1/14.99))) .* ...
    ((((x(:,1) <= 25) .* (b(1) .* x(:,1) + b(2) ./ (1 + 0.064 * (x(:,1) - 11.6).^2) +  b(3) ./ (1 + 0.2 * (x(:,1) - 11.6).^2)) + ... %- b(2) ./ (1 + 0.064 * (0      - 11.6).^2) -  b(3) ./ (1 + 0.2 * (0      - 11.6).^2)) + ... % these terms force v(0) = 0
    (x(:,1) > 25) .* 4700 .* x(:,1).^2).^2.0 + ...
    ((1 + (x(:,1) > 25) * 0.3) .* b(4) .* x(:,2).^(1.5) .* (1 + b(5) .* exp(b(6) * abs(x(:,3) - 3))) ).^2.0).^(1/2.0));
beta0 = [10^5 10^5 10^5 10^5 10 -1];
mdlSigma = fitnlm(X, ysigma, modelfunSigma, beta0, 'ErrorModel', 'proportional')
sigmaHat = predict(mdlSigma, X);



% xi, sigma, mu over wind speed
figure('Position', [100 100 900 900])
t = tiledlayout(4, 4);
axs = gobjects(4, 1);
lw = 2;
for tpid = 1 : 4
    axs(tpid) = nexttile;
    vv = [0 : 0.1 : 45];
    colorsHs = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = [1, 2, 3, 5]
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        labelhs = ['H_s = ' num2str(hs(i)) ' m, from 1-hour simulation'];
        plot(v, xis(i, :, tpid), 'o', 'color', colorsHs{countI}, 'DisplayName', labelhs);
        labelhs = ['H_s = ' num2str(hs(i)) ' m, predicted'];
        plot(vv, predict(mdlXi, X), 'color', colorsHs{countI}, 'linewidth', lw, 'DisplayName', labelhs);
        countI = countI + 1;
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('\xi (-)');
    title(['t_{p' num2str(tpid) '}']);
    if tpid == 1
        lh = legend('box', 'off', 'Location','NorthOutside', ...
            'Orientation', 'Horizontal', 'NumColumns', 2);
        lh.Layout.Tile = 'North';
    end
end
linkaxes(axs,'xy')

for tpid = 1 : 4
    axs(tpid) = nexttile;
    vv = [0 : 0.1 : 45];
    colorsHs = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = [1, 2, 3, 5]
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        labelhs = ['H_s = ' num2str(hs(i)) ' m, from 1-hour simulation'];
        plot(v, sigmas(i, :, tpid), 'o', 'color', colorsHs{countI}, 'DisplayName', labelhs);
        labelhs = ['H_s = ' num2str(hs(i)) ' m, predicted'];
        plot(vv, predict(mdlSigma, X), 'color', colorsHs{countI}, 'linewidth', lw, 'DisplayName', labelhs);
        countI = countI + 1;
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('\sigma (Nm)');
    title(['t_{p' num2str(tpid) '}']);
end
linkaxes(axs,'xy');

for tpid = 1 : 4
    axs(tpid) = nexttile;
    vv = [0 : 0.1 : 45];
    colorsHs = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = [1, 2, 3, 5]
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        plot(v, mus(i, :, tpid), 'o', 'color', colorsHs{countI});
        labelhs = ['H_s = ' num2str(hs(i)) ' m'];
        plot(vv, predict(mdlMu, X), 'color', colorsHs{countI}, 'linewidth', lw, 'DisplayName', labelhs);
        countI = countI + 1;
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('\mu (Nm)');
    title(['t_{p' num2str(tpid) '}']);
end
linkaxes(axs,'xy')

for tpid = 1 : 4
    axs(tpid) = nexttile;
    vv = [0 : 0.1 : 50];
    colors = {'red', 'blue', 'black'};
    for i = 1 : 3
        X = [vv', zeros(length(vv), 1) + hs(i), zeros(length(vv), 1) + tp(hs(i), tpid)];
        hold on
        plot(v, maxr(:, i, tpid), 'o', 'color', colors{i});
        labelhs = ['H_s = ' num2str(hs(i)) ' m'];
        %plot(vv, predict(mdlMu, X), 'color', colors{i}, 'DisplayName', labelhs);
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('1-hour maximum moment (Nm)');
    title(['t_{p' num2str(tpid) '}']);
end
linkaxes(axs,'xy')

% Figure focusing on Tp
for hsid = [2, 3, 4, 6, 9]
    fig = figure('Position', [100 100 560 300]);
    t = tiledlayout(1,2);
    nexttile
    hold on
    for tpid = 1 : 4
        vv = [0 : 0.1 : 45];
        countI = 1;
        X = [vv', zeros(length(vv), 1) + hs(hsid), zeros(length(vv), 1) + tp(hs(hsid), tpid)];
        hold on
        labelhs = ['H_s = ' num2str(hs(hsid)) ' m, T_p = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s, from 1-hour simulation'];
        plot(v, sigmas(hsid, :, tpid), 'o', 'markerfacecolor', colorsTp{tpid}, 'markeredgecolor', 'k', 'DisplayName', labelhs);
        labelhs = ['H_s = ' num2str(hs(hsid)) ' m,  T_p = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s, predicted'];
        plot(vv, predict(mdlSigma, X), 'color', colorsTp{tpid},  'DisplayName', labelhs);
        countI = countI + 1;
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('\sigma (Nm)');
    lh = legend('box', 'off', 'Location','NorthOutside', ...
        'Orientation', 'Horizontal', 'NumColumns', 2);
    lh.Layout.Tile = 'North';

    nexttile
    hold on
    for tpid = 1 : 4
        vv = [0 : 0.1 : 45];
        countI = 1;
        X = [vv', zeros(length(vv), 1) + hs(hsid), zeros(length(vv), 1) + tp(hs(hsid), tpid)];
        hold on
        plot(v, mus(hsid, :, tpid), 'o', 'markerfacecolor', colorsTp{tpid}, 'markeredgecolor', 'k');
        plot(vv, predict(mdlMu, X), 'color', colorsTp{tpid});
        countI = countI + 1;
    end
    xlabel('1-hour wind speed (m/s)');
    ylabel('\mu (Nm)');
end
exportgraphics(gcf, 'gfx/ModelFocusTp.jpg') 
exportgraphics(gcf, 'gfx/ModelFocusTp.pdf') 



figure;
id_highest_pp = 13;
id_lowest_parked = 14;
t = tiledlayout(1, 2);
ax1 = nexttile;
hold on
plot([v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp)], [xis(1, 1:id_highest_pp, 1), xis(1, 1:id_highest_pp, 2), xis(1, 1:id_highest_pp, 3), xis(1, 1:id_highest_pp, 4)], 'o', 'color', 'k');
hold on
plot(v(1:id_highest_pp), mean([xis(1, 1:id_highest_pp, 1); xis(1, 1:id_highest_pp, 2); xis(1, 1:id_highest_pp, 3); xis(1, 1:id_highest_pp, 4)]), '-k');
vv = [0:0.1:25];
%k = -0.1 - 0.65 ./ (1 + 0.3 .* (vv - 12).^2) + 0.3 ./ (1 + 0.1 .* (vv - 18).^2);
%plot(vv, k)
X = [vv', zeros(length(vv), 2)];
plot(vv, predict(mdlXi, X))
ax2 = nexttile;
plot([v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end)], [xis(1, id_lowest_parked:end, 1), xis(1, id_lowest_parked:end, 2), xis(1, id_lowest_parked:end, 3), xis(1, id_lowest_parked:end, 4)], 'o', 'color', 'k');
hold on
plot([26, 45], [-0.22, -0.22]);
linkaxes([ax1 ax2],'y')
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = '\xi (-)';
t.Title.String = 'Hs = 0 m';


figure;
t = tiledlayout(1, 2);
ax1 = nexttile;
hold on
plot([v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp)], [mus(1, 1:id_highest_pp, 1), mus(1, 1:id_highest_pp, 2), mus(1, 1:id_highest_pp, 3), mus(1, 1:id_highest_pp, 4)], 'o', 'color', 'k');
hold on
plot(v(1:id_highest_pp), mean([mus(1, 1:id_highest_pp, 1); mus(1, 1:id_highest_pp, 2); mus(1, 1:id_highest_pp, 3); mus(1, 1:id_highest_pp, 4)]), '-k');
X = [v(1:id_highest_pp)', zeros(id_highest_pp, 2)];
ymuHs0 = mean([mus(1, 1:id_highest_pp, 1); mus(1, 1:id_highest_pp, 2); mus(1, 1:id_highest_pp, 3); mus(1, 1:id_highest_pp, 4)], 'omitnan');
modelfunMuHs0 = @(b, x) b(1) .* x(:,1) + b(2) ./ (1 + b(3) * (x(:,1) - 11.6).^2) - b(2) ./ (1 + b(3) * (0 - 11.6).^2)
beta0 = [10^6 10^6 0.02];
mdlMuHs0 = fitnlm(X, ymuHs0, modelfunMuHs0, beta0)
vv = [0:0.1:25]';
X = [vv, zeros(length(vv), 2)];
plot(vv, predict(mdlMuHs0, X))
ax2 = nexttile;
plot([v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end)], [mus(1, id_lowest_parked:end, 1), mus(1, id_lowest_parked:end, 2), mus(1, id_lowest_parked:end, 3), mus(1, id_lowest_parked:end, 4)], 'o', 'color', 'k');
hold on
plot(v(id_lowest_parked:end)', predict(mdlMu, [v(id_lowest_parked:end)', zeros((length(v) - id_lowest_parked + 1), 2)]))
linkaxes([ax1 ax2],'y')
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = '\mu (Nm)';
t.Title.String = 'Hs = 0 m';

figure;
t = tiledlayout(1, 2);
ax1 = nexttile;
hold on
plot([v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp), v(1:id_highest_pp)], [sigmas(1, 1:id_highest_pp, 1), sigmas(1, 1:id_highest_pp, 2), sigmas(1, 1:id_highest_pp, 3), sigmas(1, 1:id_highest_pp, 4)], 'o', 'color', 'k');
plot(v(1:id_highest_pp), mean([sigmas(1, 1:id_highest_pp, 1); sigmas(1, 1:id_highest_pp, 2); sigmas(1, 1:id_highest_pp, 3); sigmas(1, 1:id_highest_pp, 4)]), '-k');
plot(vv, predict(mdlSigma, X))
ax2 = nexttile;
plot([v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end), v(id_lowest_parked:end)], [sigmas(1, id_lowest_parked:end, 1), sigmas(1, id_lowest_parked:end, 2), sigmas(1, id_lowest_parked:end, 3), sigmas(1, id_lowest_parked:end, 4)], 'o', 'color', 'k');
hold on
plot(v(id_lowest_parked:end)', predict(mdlSigma, [v(id_lowest_parked:end)', zeros(5, 2)]))
linkaxes([ax1 ax2],'y')
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = '\sigma (Nm)';
t.Title.String = 'Hs = 0 m';

% 1-hour extreme
figure;
hold on
plot([v, v, v, v], [maxr(:, 1, 1)', maxr(:, 1, 2)', maxr(:, 1, 3)', maxr(:, 1, 4)'], 'o', 'color', 'k');
vv = [0:0.2:45]';
X = [vv zeros(length(vv), 2)];
muHs0 = predict(mdlMu, X);
sigmaHs0 = predict(mdlSigma, X);
kHs0 =  predict(mdlXi, X);
maxrPredicted = nan(length(vv), 1);
maxrPredictedL = nan(length(vv), 1);
maxrPredictedU = nan(length(vv), 1);
for i = 1 : length(vv)
    pd = makedist('GeneralizedExtremeValue','k', kHs0(i), 'sigma', sigmaHs0(i), 'mu', muHs0(i));
    maxrPredicted(i) = pd.icdf(0.5.^(1/60));
    maxrPredictedL(i) = pd.icdf(0.025.^(1/60));
    maxrPredictedU(i) = pd.icdf(0.975.^(1/60));
end
plot(vv, maxrPredicted, '-b');
plot(vv, maxrPredictedL, '--b');
plot(vv, maxrPredictedU, '--b');
xlabel('1-hour wind speed (m s^{-1})');
ylabel('1-hour overturning moment (Nm)');
title('Hs = 0 m');

% Sigma, mu over hs
vids = [8 15 16 17];
figure('Position', [100 100 900 500]);
t = tiledlayout(3, 4);
for tpid = 1 : 4
    nexttile
    hss = [0 : 0.1 : 15]';
    colors = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = vids
        X = [zeros(length(hss), 1) + v(i), hss, tp(hss, tpid)];
        hold on
        labelv = ['V = ' num2str(v(i)) ' m s^{-1}, from 1-hour simulation'];
        plot(hs, sigmas(:, i, tpid), 'o', 'color', colors{countI}, 'DisplayName', labelv);
        labelv = ['V = ' num2str(v(i)) ' m s^{-1}, predicted'];
        plot(hss, predict(mdlSigma, X), 'color', colors{countI}, 'DisplayName', labelv);
        countI = countI + 1;
    end
    xlabel('Significant wave height (m)');
    ylabel('\sigma (Nm)');
    title(['t_{p' num2str(tpid) '}']);
    if tpid == 1
        lh = legend('box', 'off', 'Location','NorthOutside', ...
            'Orientation', 'Horizontal', 'NumColumns', 2);
        lh.Layout.Tile = 'North'; % <----- relative to tiledlayout
    end
end

for tpid = 1 : 4
    nexttile
    hss = [0 : 0.1 : 15]';
    colors = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = vids
        X = [zeros(length(hss), 1) + v(i), hss, tp(hss, tpid)];
        hold on
        labelv = ['V = ' num2str(v(i)) ' m/s, from 1-hour simulation'];
        plot(hs, mus(:, i, tpid), 'o', 'color', colors{countI}, 'DisplayName', labelv);
        labelv = ['V = ' num2str(v(i)) ' m/s, predicted'];
        plot(hss, predict(mdlMu, X), 'color', colors{countI}, 'DisplayName', labelv);
        countI = countI + 1;
    end
    xlabel('Significant wave height (m)');
    ylabel('\mu (Nm)');
    title(['t_{p' num2str(tpid) '}']);
end

for tpid = 1 : 4
    nexttile
    hss = [0 : 0.1 : 15]';
    colors = {'red', 'blue', 'black', 'green'};
    countI = 1;
    for i = vids
        X = [zeros(length(hss), 1) + v(i), hss, tp(hss, tpid)];
        hold on
        labelv = ['V = ' num2str(v(i)) ' m/s, from 1-hour simulation'];
        plot(hs, maxr(i, :, tpid), 'o', 'color', colors{countI}, 'DisplayName', labelv);
        %labelv = ['V = ' num2str(v(i)) ' m/s, predicted'];
        %plot(hss, predict(mdlMu, X), 'color', colors{countI}, 'DisplayName', labelv);
        countI = countI + 1;
    end
    xlabel('Significant wave height (m)');
    ylabel('1-hour maximum moment (Nm)');
    title(['t_{p' num2str(tpid) '}']);
end


% Xi contour plot
figure('Position', [100 100 500 800]);
t = tiledlayout(4, 2);
clower = -0.5;
cupper = 0.2;
for ii = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(xis(:, :, ii)), 10)
    title(['multiphysics, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper])
    nexttile
    ktp1 = nan(size(vgrid));
    for i = 1 : size(vgrid, 1)
        for j = 1 : size(vgrid, 2)
            Xtemp = [vgrid(i, j), hgrid(i, j), tp(hgrid(i, j), ii)];
            ktp1(i, j) = predict(mdlXi, Xtemp);
        end
    end
    contourf(vgrid, hgrid, ktp1, 10);
    title(['predicted, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper])
end

c = colorbar;
c.Label.String = '\xi (-) ';
c.Layout.Tile = 'east';
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = 'Significant wave height (m)';
exportgraphics(gcf, 'gfx/EmulatorFitKFree_k.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFitKFree_k.pdf') 

% Sigma contour plot
figure('Position', [100 100 500 800]);
t = tiledlayout(4, 2);
clower = min(sigmas(:));
cupper = max(sigmas(:)) * 0.95;
for ii = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(sigmas(:, :, ii)), 10)
    title(['multiphysics, t_{tp' num2str(ii) '} surface'])
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
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = 'Significant wave height (m)';
exportgraphics(gcf, 'gfx/EmulatorFitKFree_Sigma.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFitKFree_Sigma.pdf') 


% Mu contour plot
figure('Position', [100 100 500 800]);
t = tiledlayout(4, 2);
clower = min(mus(:));
cupper = 2 * 10^8;
for ii = 1 : 4
    nexttile
    contourf(vgrid, hgrid, squeeze(mus(:, :, ii)), [clower : (cupper - clower) / 10 : cupper])
    title(['multiphysics, t_{tp' num2str(ii) '} surface'])
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
    caxis([clower cupper])
end

c = colorbar;
c.Label.String = '\mu (Nm) ';
c.Layout.Tile = 'east';
t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = 'Significant wave height (m)';
exportgraphics(gcf, 'gfx/EmulatorFitKFree_Mu.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFitKFree_Mu.pdf') 


% 1-hr max contour plot
fig = figure('Position', [100 100 1500 800]);
t = tiledlayout(4, 6);
clower = min(maxr(:));
cupper = 3.6 * 10^8;
rGlobalGEV = nan([size(vgrid), 4]);
rLocalGEV = nan([size(vgrid), 4]);
for ii = 1 : 4
    nexttile
    robserved = squeeze(maxr(:, :, ii)');
    contourf(vgrid, hgrid, robserved, [clower : (cupper - clower) / 10 : cupper])
    title(['multiphysics realization, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper]);
    
    for i = 1 : size(vgrid, 1)
        for j = 1 : size(vgrid, 2)
            Xtemp = [vgrid(i, j), hgrid(i, j), tp(hgrid(i, j), ii)];
            if ~isnan(xis(i, j, ii))
                pd = makedist('GeneralizedExtremeValue','k', xis(i, j, ii), ...
                    'sigma', sigmas(i, j, ii), 'mu', mus(i, j, ii));
                rLocalGEV(i, j, ii) = pd.icdf(0.5.^(1/60));
            end
            muTemp = predict(mdlMu, Xtemp);
            sigmaTemp = predict(mdlSigma, Xtemp);
            xiTemp = predict(mdlXi, Xtemp);
            pd = makedist('GeneralizedExtremeValue','k', xiTemp, 'sigma', sigmaTemp, 'mu', muTemp);
            rGlobalGEV(i, j, ii) = pd.icdf(0.5.^(1/60));
        end
    end
    nexttile
    contourf(vgrid, hgrid, rLocalGEV(:,:,ii), 10);
    title(['local GEV, t_{tp' num2str(ii) '} surface'])
    nexttile
    contourf(vgrid, hgrid, rGlobalGEV(:,:,ii), 10);
    title(['response emulator, t_{tp' num2str(ii) '} surface'])
    caxis([clower cupper])
    if ii == 4
        c1 = colorbar;
        c1.Label.String = '1-hour maximum oveturning moment (Nm) ';
        c1.Layout.Tile = 'south';
    end
   
    ax4 = nexttile;
    imagesc(vgrid(:,1), hgrid(1,:), (rLocalGEV(:,:,ii) - robserved) ./ robserved * 100, 'AlphaData',~isnan(robserved));
    set(gca, 'YDir', 'normal')
    colormap(ax4, redblue)
    caxis([-30, 30]);
    if ii == 1
        title('local GEV - multiphysics realization');
    end
    
    ax5 = nexttile;
    imagesc(vgrid(:,1), hgrid(1,:), (rGlobalGEV(:,:,ii) - rLocalGEV(:,:,ii)) ./ rLocalGEV(:,:,ii) * 100, 'AlphaData',~isnan(robserved));
    set(gca, 'YDir', 'normal')
    colormap(ax5, redblue)
    caxis([-30, 30]);
    if ii == 1
        title('emulator - local GEV');
    end

    
    ax5 = nexttile;
    imagesc(vgrid(:,1), hgrid(1,:), (rGlobalGEV(:,:,ii) - robserved) ./ robserved * 100, 'AlphaData',~isnan(robserved));
    set(gca, 'YDir', 'normal')
    colormap(ax5, redblue)
    caxis([-30, 30]);
    if ii == 1
        title('emulator - multiphysics realization');
    end
    if ii == 4
        c3 = colorbar;
        c3.Label.String = 'Difference (%) ';
        c3.Layout.Tile = 'south';
    end
end

t.XLabel.String = '1-hour wind speed (m s^{-1})';
t.YLabel.String = 'Significant wave height (m)';
exportgraphics(gcf, 'gfx/EmulatorFitKFree_response_all_panels.jpg') 
exportgraphics(gcf, 'gfx/EmulatorFitKFree_response_all_panels.pdf') 

% Plot response comparision as scatter
fig = figure('position', [100, 100, 1400, 700]);
tOut = tiledlayout(fig,2,1, 'TileSpacing','compact','Padding','compact');
hAx = nexttile(tOut, 1); hAx.Visible = 'off';
hP = uipanel(fig, 'Position', hAx.OuterPosition, 'BorderWidth', 0);
tupper = tiledlayout(hP, 1, 5, 'TileSpacing','compact','Padding','compact');
robserved_all = [];
ms = 5;
axs = gobjects(2, 5);
for tpid = 1 : 4
    robserved  = squeeze(max(Ovr(:, :, tpid, :), [], 4))';
    robserved(robserved == 0) = NaN;
    robserved_all = [robserved_all; robserved(:)];
    rGlobalGEVSlice = rGlobalGEV(:,:,tpid);
    axs(1, tpid + 1) = nexttile(tupper, tpid + 1);
    hold on
    scatter(robserved(:) / 10^6, rGlobalGEVSlice(:) / 10^6, ms, 'ok');
    plot([0, max(rGlobalGEVSlice(:)) / 10^6], [0, max(rGlobalGEVSlice(:)) / 10^6], '--r'); 
    title(['{\it t_{p' num2str(tpid) '}}']);
end
axs(1, 1) = nexttile(tupper, 1);
scatter(robserved_all / 10^6, rGlobalGEV(:) / 10^6, ms, 'ok');
hold on
plot([0, max(rGlobalGEV(:)) / 10^6], [0, max(rGlobalGEV(:)) / 10^6], '--r');
xlabel(tupper, '1-hour maximum in multiphysics simulation (MNm)');
ylabel(tupper, 'Emulator median 1-hour max (MNm)');
title('All simulated conditions');
linkaxes(axs, 'xy');
exportgraphics(tupper, 'gfx/CompareResponseScatter_Realization.jpg') 
exportgraphics(tupper, 'gfx/CompareResponseScatter_Realization.pdf')

hAx = nexttile(tOut);
hP = uipanel(fig, 'Position', hAx.OuterPosition, 'BorderWidth', 0);
tlower = tiledlayout(hP, 1, 5, 'TileSpacing','compact','Padding','compact');
for tpid = 1 : 4
    axs(2, tpid + 1) = nexttile(tlower, tpid + 1);
    rLocalGEVSlice = rLocalGEV(:,:,tpid);
    rGlobalGEVSlice = rGlobalGEV(:,:,tpid);
    hold on
    scatter(rLocalGEVSlice(:) / 10^6, rGlobalGEVSlice(:) / 10^6, ms, 'ok');
    plot([0, max(rGlobalGEVSlice(:)) / 10^6], [0, max(rGlobalGEVSlice(:)) / 10^6], '--r'); 
    title(['{\it t_{p' num2str(tpid) '}}']);
end
axs(2, 1) = nexttile(tlower, 1);
scatter(rLocalGEV(:) / 10^6, rGlobalGEV(:) / 10^6, ms, 'ok');
hold on
plot([0, max(rGlobalGEV(:)) / 10^6], [0, max(rGlobalGEV(:)) / 10^6], '--r'); 
xlabel(tlower, 'Local GEV median 1-hour maximum (MNm)');
ylabel(tlower, 'Emulator median 1-hour max (MNm)');
title('All simulated conditions');
linkaxes(axs, 'xy');

exportgraphics(tlower, 'gfx/CompareResponseScatter_LocalGEV.jpg') 
exportgraphics(tlower, 'gfx/CompareResponseScatter_LocalGEV.pdf')
