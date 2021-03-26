% Because we do not have enough dataponts per cell to compute a 
% 50-year HD contour with the given resolution, let's pool the data.
combineN = 9;
coarseSize = floor(size(count) / combineN);
mid = combineN / 2 + 0.5;
wC = w(mid:combineN:end);
hC = h(mid:combineN:end);
sC = s(mid:combineN:end);

wC = wC(1 : coarseSize(1));
hC = hC(1 : coarseSize(2));
sC = sC(1 : coarseSize(3));


countI = nan(coarseSize(1), size(count,2), size(count,3));
for i = 1 : coarseSize(1)
   countI(i, :, :) = count((i - 1) * combineN + 1, :, :);
   for cid = 2 : combineN
        countI(i, :, :) =  countI(i, :, :) + count((i - 1) * combineN + cid, :, :);
   end
end
countJ = nan(coarseSize(1), coarseSize(2), size(count,3));
for j = 1 : coarseSize(2)
    countJ(:, j, :) = countI(:, (j - 1) * combineN + 1, :);
    for cid = 2 : combineN
        countJ(:, j, :) = countJ(:, j, :) + countI(:, (j - 1) * combineN + cid, :);
    end
end
countC = nan(coarseSize);
for k = 1 : coarseSize(3)
    countC(:, :, k) = countJ(:, :, (k - 1) * combineN + 1);
    for cid = 2 : combineN
        countC(:, :, k) = countC(:, :, k) + countJ(:, :, (k - 1) * combineN + cid);
    end
end

alpha = 1 / (50 * 365.25 * 24);
threshold = findThreshold(countC, alpha)

[S, H] = meshgrid(sC, hC);
Tz = sqrt((2 * pi * H ) ./ (9.81 * S));
Tp = 1.2796 * Tz;

figure('Position', [100 100 1200 600])
layout = tiledlayout(2,4);
windI = round([20 40 60 80 100 120 140 160] / combineN);
for i = windI
    ax = nexttile;
    hold on
    slice = squeeze(countC(i,:,:)); 
    nanSlice = slice;
    nanSlice(slice==0) = nan;
    handle = pcolor(Tp, H, nanSlice);
    handle.EdgeColor = 'none';
    contour(Tp, H, slice, [threshold, threshold], 'r', 'linewidth', 2);
    title([num2str(wC(i)) ' m s^{-1}']);
    xlim([0 50])
    caxis([0 10000000]);
end
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel(layout, 'Spectral peak period (s)');
ylabel(layout, 'Significant wave height (m)')
sgtitle(['3D contour, \alpha = ' num2str(alpha, '%2.2e')]);
exportgraphics(layout, 'gfx/3DcontourTp.jpg') 
exportgraphics(layout, 'gfx/3DcontourTp.pdf') 

figure('Position', [100 100 1200 600])
layout = tiledlayout(2,4);
windI = round([20 40 60 80 100 120 140 160] / combineN);
for i = windI
    ax = nexttile;
    hold on
    slice = squeeze(countC(i,:,:)); 
    nanSlice = slice;
    nanSlice(slice==0) = nan;
    %handle = pcolor(S, H, nanSlice);
    %handle.EdgeColor = 'none';
    nanimage(S(1,:), H(:,1), nanSlice);
    set(gca, 'YDir', 'normal')
    contour(S, H, slice, [threshold, threshold], 'r', 'linewidth', 2);
    title([num2str(wC(i)) ' m s^{-1}']);
    caxis([0 10000000]);
end
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel(layout, 'Steepness (-)');
ylabel(layout, 'Significant wave height (m)')
sgtitle(['3D contour, \alpha = ' num2str(alpha, '%2.2e')]);
exportgraphics(layout, 'gfx/3DcontourSteepness.jpg') 
exportgraphics(layout, 'gfx/3DcontourSteepness.pdf') 

% 2D projection
VHsProjection = sum(countC,3);
threshold2D = findThreshold(VHsProjection, alpha)
[W, H] = meshgrid(wC, hC);

figure('Position', [100 100 500 400])
layout = tiledlayout(1,1);
nexttile
hold on
nanSlice = VHsProjection;
nanSlice(VHsProjection==0) = nan;
handle = pcolor(W, H, nanSlice');
handle.EdgeColor = 'none';
contour(W, H, VHsProjection', [threshold2D, threshold2D], 'r', 'linewidth', 2);

title(['2D projection, \alpha = ' num2str(alpha,'%2.2e')]);
caxis([0 10000000]);
cb = colorbar();
cb.Layout.Tile = 'east';
cb.Label.String = 'Count (-)';
xlabel('1-hour wind speed (m s^{-1})');
ylabel('Significant wave height (m)')
exportgraphics(layout, 'gfx/2Dcontours.jpg') 
exportgraphics(layout, 'gfx/2Dcontours.pdf') 



function threshold =  findThreshold(count, alpha)
    totCount =  sum(sum(sum(count)));
    threshold = 0;
    inHdrProb = 1;
    while inHdrProb > (1 - alpha)
        threshold = threshold + 1;
        inHdrProb = sum(count(count > threshold)) / totCount;
    end
end
