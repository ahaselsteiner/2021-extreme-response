%load('OvrDataEmulator');
Ovr(1,:,:,:) = NaN;
Ovr(:,9,4,:) = NaN;
t = minutes(Time/60);
FormatConventionForMomentTimeSeries


plot_hsid = 2;
detail_plot_vids = [3, 6, 10, 15];
detail_plot_tpid = 3;

figtp1 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 1)) ' s']);
figtp2 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 2)) ' s']);
figtp3 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 4)) ' s']);
figtp4 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, Tp = ' num2str(tp(hs(plot_hsid), 4)) ' s']);
fig_time_series = figure('Position', [100 100 1200 900]);
layout = tiledlayout(length(detail_plot_vids), 5);

ks = nan(size(Ovr, 1), size(Ovr, 2), size(Ovr, 3));
for vid = 1 : size(Ovr, 1)
    for hsid = 1 : size(Ovr, 2)
        for tpid = 1 : size(Ovr, 3)
            r = squeeze(Ovr(vid, hsid, tpid, :));
            if ~isnan(r(1))
                [pd, block_maxima, block_max_i] = gevToBlockMaxima(r, 60, 'free');
                ks(vid, hsid, tpid) = pd.k;
                if hsid == plot_hsid
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
                    if any(detail_plot_vids(:) == vid) && tpid == detail_plot_tpid
                        set(0, 'CurrentFigure', fig_time_series)
                        
                        nexttile([1 4]);
                        hold on
                        plot(t, r);    
                        plot(t(block_max_i), r(block_max_i), 'xr');
                        xlabel('Time');
                        ylabel('Overturning moment (Nm)');
                        t_label = ['v = ' num2str(v(vid)) ' m/s, h_s = ' num2str(hs(hsid)) ' m'];
                        if hs(hsid) > 0 
                            t_label = [t_label ', t_p = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s'];
                        end
                        title(t_label)

                        nexttile
                        h = qqplot(block_maxima, pd);
                        set(h(1), 'Marker', 'x')
                        set(h(1), 'MarkerEdgeColor', 'r')
                        set(h(2), 'Color', 'k')
                        set(h(3), 'Color', 'k')
                        xlabel('Quantiles of GEVD (Nm)');
                        ylabel('Quantiles of sample (Nm)');
                        title('')
                        
                        
                    end
                end
            end
        end
    end
end

layout.Padding = 'compact';
exportgraphics(layout, ['gfx/TimeSeries_Hs' num2str(hs(plot_hsid)) '_Tpid' num2str(tp(hs(plot_hsid), detail_plot_tpid), '%4.2f') '.jpg']) 
exportgraphics(layout, ['gfx/TimeSeries_Hs' num2str(hs(plot_hsid)) '_Tpid' num2str(tp(hs(plot_hsid), detail_plot_tpid), '%4.2f') '.pdf']) 


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

