b50_det_cont = 119;
b50_det_am = 114;
b50_stoc_am = 158;
b50_IFORM_median = 114;
b50_2DHD_median = 133;
b50_3DHD = 141;

contour_const_IFORM = b50_IFORM_median - b50_det_cont;
contour_const_2DHD = b50_2DHD_median - b50_det_cont;
contour_const_3DHD = b50_3DHD - b50_det_cont;
serial_corr = b50_det_cont - b50_det_am;
short_term_var = b50_det_am - b50_stoc_am;
IFORM_total = b50_IFORM_median - b50_stoc_am;
HD_2D_total = b50_2DHD_median - b50_stoc_am;
HD_3D_total = b50_3DHD - b50_stoc_am;

figure('Position', [100 100 500 750])
layout = tiledlayout(3, 1);
ax1 = nexttile;
temp = {'contour construction', 'serial correlation', 'short-term variability', 'required compensation'};
x = categorical(temp);
x = reordercats(x, temp);
y = [contour_const_IFORM, serial_corr, short_term_var, -1*IFORM_total];
b = bar(x, y);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
b.FaceColor = 'flat';
b.CData(4,:) = [1 0 0];
box off
ylabel({'Bias of the 2D IFORM median';'steepness contour for b_{50} (MNm)'})

ax2 = nexttile;
y = [contour_const_2DHD, serial_corr, short_term_var, -1*HD_2D_total];
b = bar(x, y);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
b.FaceColor = 'flat';
b.CData(4,:) = [1 0 0];
box off
ylabel({'Bias of the 2D HD median';'steepness contour  for b_{50} (MNm)'})
ylim([-50 50])

ax3 = nexttile;
y = [contour_const_3DHD serial_corr, short_term_var, -1*HD_3D_total];
b = bar(x, y);
b.FaceColor = 'flat';
b.CData(4,:) = [1 0 0];
box off
ylabel({'Bias of the 3D HD';'contour  for b_{50} (MNm)'})
ylim([-50 50])

linkaxes([ax1 ax2 ax3], 'xy');

exportgraphics(layout, ['gfx/ContourBias.jpg']) 
exportgraphics(layout, ['gfx/ContourBias.pdf']) 
