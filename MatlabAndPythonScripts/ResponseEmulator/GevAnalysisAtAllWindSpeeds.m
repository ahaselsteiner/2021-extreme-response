%load('OvrDataEmulator');
FormatConventionForMomentTimeSeries

hsid = 2;

figtp1 = figure('Position', [100 100 1200 900]);
sgtitle(['Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), 1)) ' s']);
figtp2 = figure('Position', [100 100 1200 900]);
sgtitle(['Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), 2)) ' s']);
figtp3 = figure('Position', [100 100 1200 900]);
sgtitle(['Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), 4)) ' s']);
figtp4 = figure('Position', [100 100 1200 900]);
sgtitle(['Hs = ' num2str(hs(hsid)) ' m, Tp = ' num2str(tp(hs(hsid), 4)) ' s']);
ks = nan(size(Ovr, 1), size(Ovr, 2), size(Ovr, 3));
for vid = 1 : size(Ovr, 1)
    for hsid = 1 : size(Ovr, 2)
        for tpid = 1 : size(Ovr, 3)
            r = Ovr(vid, hsid, tpid, :);
            [pd, block_maxima] = gevToBlockMaxima(r, 60, 'free');
            ks(vid, hsid, tpid) = pd.k;
            if hsid == 2
                if tpid == 1
                    set(0, 'CurrentFigure', figtp1)
                elseif tpid == 2
                    set(0, 'CurrentFigure', figtp2)
                elseif tpid == 3
                    set(0, 'CurrentFigure', figtp3)
                elseif tpid == 4
                    set(0, 'CurrentFigure', figtp4)
                end
                subplot(4, 5, vid);
                h = qqplot(block_maxima, pd);
                title(['v = ' num2str(v(vid)) ' m/s, k = ' num2str(pd.k)])
            end
        end
    end
end

ks(ks == 0) = nan;
figure('Position', [100 100 1200 450])
t = tiledlayout(2, 2);
for tpid = 1 : 4
    nexttile
    hold on
    for hsid = 1 : size(ks, 2)
        if hsid == 1
            h = plot(v, ks(:, hsid, tpid), 'linewidth', 2, ...
                'DisplayName', ['H_s = ' num2str(hs(hsid)) ' m']);
        else
            h = plot(v, ks(:, hsid, tpid), 'linewidth', 2, ...
                'DisplayName', ['H_s = ' num2str(hs(hsid)) ' m, T_p = ' num2str(tp(hs(hsid), tpid))]);
        end
    end
    h = plot(v, mean(ks(:, :, tpid), 2, 'omitnan'), '--k', 'DisplayName', 'Mean');
    xlabel('1-hour wind speed (m/s)');
    ylabel('Shape parameter k');
    legend('location', 'eastoutside')
    title(['t_{p' num2str(tpid) '}'])
end