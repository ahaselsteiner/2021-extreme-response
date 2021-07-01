load('OvrDataEmulatorDiffSeed');
t_min = Time / 60; % in minutes
FormatConventionForMomentTimeSeries

plot_hsid = 2;
detail_plot_vids = [2, 5, 9, 14];
detail_plot_tpid = 3;

figtp1 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 1), '%4.2f') ' s']);
figtp2 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 2), '%4.2f') ' s']);
figtp3 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, T_p = ' num2str(tp(hs(plot_hsid), 4), '%4.2f') ' s']);
figtp4 = figure('Position', [100 100 1200 900]);
sgtitle(['H_s = ' num2str(hs(plot_hsid)) ' m, Tp = ' num2str(tp(hs(plot_hsid), 4), '%4.2f') ' s']);
fig_time_series = figure('Position', [100 100 1200 900]);
layout = tiledlayout(length(detail_plot_vids), 5);

xis = nan(size(Ovr, 1), size(Ovr, 2), size(Ovr, 3));
for vid = 1 : size(Ovr, 1)
    for hsid = 1 : size(Ovr, 2)
        for tpid = 1 : size(Ovr, 3)
            r = squeeze(Ovr(vid, hsid, tpid, :));
            if ~isnan(r(1))
                [pd, block_maxima, block_max_i] = gevToBlockMaxima(r, 60, 'free');
                xis(vid, hsid, tpid) = pd.k;
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
                    title(['{\it v} = ' num2str(v(vid)) ' m s^{-1}, \xi = ' num2str(pd.k, '%4.2f')])
                    if any(detail_plot_vids(:) == vid) && tpid == detail_plot_tpid
                        set(0, 'CurrentFigure', fig_time_series)
                        
                        nexttile([1 4]);
                        hold on
                        plot(t_min, r / 10^6);    
                        plot(t_min(block_max_i), r(block_max_i) / 10^6, 'xr');
                        if vid == detail_plot_vids(end)
                            xlabel('Time (min)');
                        end
                        xlim([0 62]);
                        ylabel('Overturning moment (MNm)');
                        t_label = ['{\it v} = ' num2str(v(vid)) ' m s^{-1}']
                        %t_label = ['{\it v} = ' num2str(v(vid)) ' m s^{-1}, {\it h_s} = ' num2str(hs(hsid)) ' m'];
                        %if hs(hsid) > 0 
                        %    t_label = [t_label ', {\it t_p} = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s'];
                        %end
                        title(t_label)

                        nexttile
                        h = qqplot(block_maxima, pd);
                        for i = 1 : 3
                            h(i).XData = h(i).XData / 10^6;
                            h(i).YData = h(i).YData / 10^6;
                        end
                        set(h(1), 'Marker', 'x')
                        set(h(1), 'MarkerEdgeColor', 'r')
                        set(h(2), 'Color', 'k')
                        set(h(3), 'Color', 'k')
                        xlabel('Quantiles of GEVD (MNm)');
                        ylabel('Quantiles of sample (MNm)');
                        title('')
                        
                        
                    end
                end
            end
        end
    end
end

layout.Padding = 'compact';
fname = ['gfx/TimeSeries_Hs' num2str(hs(plot_hsid)) '_Tpid' num2str(tp(hs(plot_hsid), detail_plot_tpid), '%4.2f')];
fname = strrep(fname, '.', 'p');
exportgraphics(layout, [fname '.jpg']) 
exportgraphics(layout, [fname '.pdf']) 


xis(xis == 0) = nan;
figure('Position', [100 100 1200 600])
t_min = tiledlayout(2, 2);
for tpid = 1 : 4
    nexttile
    hold on
    for hsid = 1 : size(xis, 2)
        if hsid == 1
            h = plot(v, xis(:, hsid, tpid), 'linewidth', 2, ...
                'DisplayName', ['H_s = ' num2str(hs(hsid)) ' m']);
        else
            h = plot(v, xis(:, hsid, tpid), 'linewidth', 2, ...
                'DisplayName', ['H_s = ' num2str(hs(hsid)) ' m, T_p = ' num2str(tp(hs(hsid), tpid), '%4.2f') ' s']);
        end
    end
    h = plot(v, mean(xis(:, :, tpid), 2, 'omitnan'), '--k', 'linewidth', 2, ...
        'DisplayName', 'Mean');

    legend('location', 'eastoutside')
    title(['t_{p' num2str(tpid) '}'])
end
xlabel(t_min, '1-hour wind speed (m s^{-1})');
ylabel(t_min, 'Shape parameter \xi');


