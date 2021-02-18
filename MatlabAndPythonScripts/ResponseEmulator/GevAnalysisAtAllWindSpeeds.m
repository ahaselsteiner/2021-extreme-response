%load('OvrDataEmulator');
FormatConventionForMomentTimeSeries


figure
t = tiledlayout(4, 5)
ks = nan(size(Ovr, 1), size(Ovr, 2), size(Ovr, 3));
for vid = 1 : size(Ovr, 1)
    for hsid = 1 : size(Ovr, 2)
        for tpid = 1 : size(Ovr, 3)
            r = Ovr(vid, hsid, tpid, :);
            [pd, block_maxima] = gevToBlockMaxima(r, 60, 'free');
            ks(vid, hsid, tpid) = pd.k;
            if hsid == 1 && tpid == 1
                nexttile
                h = qqplot(block_maxima, pd);
                title(['v = ' num2str(v(vid)) ' m/s, k = ' num2str(pd.k)])
            end
        end
    ende
end

ks(ks == 0) = nan;
figure
t = tiledlayout(2, 1);
for tpid = 1 : 2
    nexttile
    hold on
    for hsid = 1 : size(ks, 2)
        h = plot(v, ks(:, hsid, tpid), 'linewidth', 2, ...
            'DisplayName', ['H_s = ' num2str(hs(hsid)) ' m, T_p = ' num2str(tp(hs(hsid), tpid))]);
    end
    h = plot(v, mean(ks(:, :, tpid), 2, 'omitnan'), '--k', 'DisplayName', 'Mean');
    xlabel('1-hour wind speed (m/s)');
    ylabel('Shape parameter k');
    legend('location', 'eastoutside')
    title(['t_{p' num2str(tpid) '}'])
end