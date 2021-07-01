br50_det_cont = [119 276];
br50_det_am = [114 252];
br50_stoc_am = [158 305];
br50_IFORM_median = [114 281];
br50_IFORM_high = [119 292];
br50_2DHD_median = [133 329];
br50_2DHD_high = [137 339];
br50_3DHD = [141 358];
symbols = {'b_{50}', 'r_{50}'};
symbols_fname = {'b50', 'r50'};

contour_names = {'2D IFORM, median steepness', ...
    '2D IFORM, high steepness', ...
    '2D HD contour, median steepness', ...
    '2D HD contour, high steepness', ...
    '3D HD contour'};

contour_const_IFORM_median = br50_IFORM_median - br50_det_cont;
contour_const_IFORM_high= br50_IFORM_high - br50_det_cont;
contour_const_2DHD_median = br50_2DHD_median - br50_det_cont;
contour_const_2DHD_high = br50_2DHD_high - br50_det_cont;
contour_const_3DHD = br50_3DHD - br50_det_cont;
serial_corr = br50_det_cont - br50_det_am;
short_term_var = br50_det_am - br50_stoc_am;
total_IFORM_median = br50_IFORM_median - br50_stoc_am;
total_IFORM_high = br50_IFORM_high - br50_stoc_am;
total_2DHD_median = br50_2DHD_median - br50_stoc_am;
total_2DHD_high = br50_2DHD_high - br50_stoc_am;
total_3DHD = br50_3DHD - br50_stoc_am;

for i = 1 : 2
    figure('Position', [100 100 300 750])
    layout = tiledlayout(3, 1);
    ax1 = nexttile;
    temp = {'contour construction', 'serial correlation', 'short-term variability', 'required compensation'};
    x = categorical(temp);
    x = reordercats(x, temp);
    y = [contour_const_IFORM_median(i), serial_corr(i), short_term_var(i), -1*total_IFORM_median(i)] / br50_stoc_am(i) * 100;
    b = bar(x, y);
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    b.FaceColor = 'flat';
    b.CData(4,:) = [1 0 0];
    box off
    ylabel({'Bias of the 2D IFORM median';['steepness contour for ' symbols{i} ' (%)']})
    for j = 1:length(y)
        if y(j) > 0
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'bottom', 'horiz', 'center'); 
        else
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'top', 'horiz', 'center'); 
        end
    end
    if i == 1
        title('10 m moment');
    else
        title('30 m moment');
    end

    ax2 = nexttile;
    y = [contour_const_2DHD_median(i), serial_corr(i), short_term_var(i), -1*total_2DHD_median(i)] / br50_stoc_am(i) * 100;
    b = bar(x, y);
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
    b.FaceColor = 'flat';
    b.CData(4,:) = [1 0 0];
    box off
    ylabel({'Bias of the 2D HD median';['steepness contour  for ' symbols{i} ' (%)']})
    for j = 1:length(y)
        if y(j) > 0
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'bottom', 'horiz', 'center'); 
        else
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'top', 'horiz', 'center'); 
        end
    end
    
    ax3 = nexttile;
    y = [contour_const_3DHD(i) serial_corr(i), short_term_var(i), -1*total_3DHD(i)] / br50_stoc_am(i) * 100;
    b = bar(x, y);
    b.FaceColor = 'flat';
    b.CData(4,:) = [1 0 0];
    box off
    ylabel({'Bias of the 3D HD';['contour  for ' symbols{i} ' (%)']})
    for j = 1:length(y)
        if y(j) > 0
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'bottom', 'horiz', 'center'); 
        else
            text(j, y(j), num2str(y(j), '%4.0f'), 'vert', 'top', 'horiz', 'center'); 
        end
    end
    
    

    linkaxes([ax1 ax2 ax3], 'xy');
    ylim([-33 33])

    fname = ['gfx/ContourBias_' symbols_fname{i}];
    exportgraphics(layout, [fname '.jpg']) 
    exportgraphics(layout, [fname '.pdf']) 
    
    bar_width = 0.8 / 5;
    colors1 = [0.7 0.7 1; 0.6 0.6 1; 0.5 0.5 1; 0.4 0.4 1; 0.3 0.3 1] ;
    colors2 = [1 0.7 0.7; 1 0.6 0.6; 1 0.5 0.5; 1 0.4 0.4; 1 0.3 0.3] ;
    
    fig = figure('position', [100, 100, 560, 380]);
    hold on
    y_masked = [NaN y(2) y(3) NaN];
    b = bar(x, y_masked, 'facecolor', colors1(3,:));
    xtickangle(0)
    contour_const = [contour_const_IFORM_median(i) contour_const_IFORM_high(i) contour_const_2DHD_median(i) contour_const_2DHD_high(i) contour_const_3DHD(i)];
    required_comp = -1 * [total_IFORM_median(i) total_IFORM_high(i) total_2DHD_median(i) total_2DHD_high(i) total_3DHD(i)];
    for j = 1 : 5
        % Contour construction
        xx = 1 + (j - 3) * bar_width + [-0.5 * bar_width 0.5 * bar_width 0.5 * bar_width -0.5 * bar_width];
        yy = [0 0 contour_const(j) contour_const(j)] / br50_stoc_am(i) * 100;
        patch(xx, yy, colors1(j, :))
        
        % Required compensation
        xx = 4 + (j - 3) * bar_width + [-0.5 * bar_width 0.5 * bar_width 0.5 * bar_width -0.5 * bar_width];
        yy = [0 0 required_comp(j) required_comp(j)] / br50_stoc_am(i) * 100;
        patch(xx, yy, colors2(j, :))
    end
    
    x_cc = 1 + ([1:5] - 3) * bar_width;
    y_cc = [contour_const / br50_stoc_am(i) * 100];
    nr_on_top(y_cc, x_cc)
    add_contour_labels(1, contour_names)
    
    nr_on_top(y_masked)
    
    x_rc = 4 + ([1:5] - 3) * bar_width;
    y_rc = [required_comp / br50_stoc_am(i) * 100];
    nr_on_top(y_rc, x_rc)
    
    ylim([-33 33])
    
    if i == 1
        ylabel('Bias of the contour-based estimate for {\it b_{50}} (%)')
        title('10-m moment');
    else
        title('30-m moment');
        ylabel('Bias of the contour-based estimate for {\it r_{50}} (%)')
    end
    
    fname = ['gfx/ContourBiasGrouped_' symbols_fname{i}];
    exportgraphics(fig, [fname '.jpg']) 
    exportgraphics(fig, [fname '.pdf']) 
end

function nr_on_top(y, x)
    if ~exist('x','var')
        x = 1 : length(y);
    end
    for i = 1 : length(y)
        if y(i) >= 0
            text(x(i), y(i), num2str(y(i), '%4.0f'), 'vert', 'bottom', 'horiz', 'center'); 
        else
            text(x(i), y(i), num2str(y(i), '%4.0f'), 'vert', 'top', 'horiz', 'center'); 
        end
    end
end

function add_contour_labels(x, labels)
    bar_width = 0.8 / 5;
    for i = 1 : length(labels)
        h = text(x + (i - 3) * bar_width, -30, labels{i}, 'fontsize', 6);
        set(h, 'Rotation', 90);
    end
end