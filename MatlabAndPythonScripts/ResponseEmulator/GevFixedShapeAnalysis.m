load('OverturningMomentWindspeed9.mat')
load('OverturningMomentWindspeed15.mat')
load('OverturningMomentWindspeed21.mat')
load('OverturningMomentWindspeed30.mat')
file_dist = {'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', ...
    'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', ...
    'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', ...
    'v = 30 m/s', 'v = 30 m/s', 'v = 30 m/s', 'v = 30 m/s', 'v = 30 m/s', 'v = 30 m/s'}; 
file_dist_with_pooled = file_dist;
file_dist_with_pooled{25} = '';
file_dist_with_pooled{26} = [file_dist{1} ', pooled'];
file_dist_with_pooled{27} = [file_dist{7} ', pooled'];
file_dist_with_pooled{28} = [file_dist{13} ', pooled'];
file_dist_with_pooled{29} = [file_dist{19} ', pooled'];
N_BLOCKS = 60;

% GEV with fixed shape parameter.
SHAPE1 = -0.2;
SHAPE2 = 0;
V_THRESHOLD = 16.5;
shape = @(v1hr) (v1hr <= V_THRESHOLD) .* SHAPE1 + (v1hr > V_THRESHOLD) .* SHAPE2;
%SHAPE1 = @(v1hr) (v1hr <= 13) .* -0.2 + (v1hr > 13 & v1hr < 17) .* (-0.2 + (v1hr - 13) * 0.05) + (v1hr >= 17) .* 0
gev1 = @(x, sigma, mu) gevpdf(x, SHAPE1, sigma, mu); 
gev2 = @(x, sigma, mu) gevpdf(x, SHAPE2, sigma, mu); 


rs = {V9.S1, V9.S2, V9.S3, V9.S4, V9.S5, V9.S6, ...
    V15.S1, V15.S2, V15.S3, V15.S4, V15.S5, V15.S6, ...
    V21.S1, V21.S2, V21.S3, V21.S4, V21.S5, V21.S6, ...
    V30.S1, V30.S2, V30.S3, V30.S4, V30.S5, V30.S6};
rs_6hr = {[V9.S1; V9.S2; V9.S3; V9.S4; V9.S5; V9.S6], ...
    [V15.S1; V15.S2; V15.S3; V15.S4; V15.S5; V15.S6], ...
    [V21.S1; V21.S2; V21.S3; V21.S4; V21.S5; V21.S6], ...
    [V30.S1; V30.S2; V30.S3; V30.S4; V30.S5; V30.S6]};
vs = [zeros(6,1) + 9; zeros(6,1) + 15; zeros(6,1) + 21; zeros(6,1) + 30;];
t = minutes(V9.t/60);
block_length = floor(length(t) / N_BLOCKS);

n_seeds = 6;
ks = [];
sigmas = [];
mus = [];
npeaks = [];

pds = [];
maxima = zeros(n_seeds, 1);
x1 = zeros(n_seeds, 1);
blocks = zeros(N_BLOCKS, block_length);
block_maxima = zeros(n_seeds * 3, N_BLOCKS);
block_maxima_pooled = zeros(3, N_BLOCKS * n_seeds);
block_max_i = zeros(N_BLOCKS, 1);
for j = 1 : length(rs)
    r = rs{j};
    maxima(j) = max(r);
    
    for i = 1 : N_BLOCKS
        blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
        [block_maxima(j, i), maxid] = max(blocks(i,:));
        block_max_i(i) = maxid + (i - 1) * block_length;
    end
    
    

    figure('Position', [100 100 1200 250])
    subplot(1, 4, 1:3)
    hold on
    plot(t, r);    
    plot(t(block_max_i), r(block_max_i), 'xr');
    xlabel('Time (s)');
    ylabel('Overturning moment (Nm)');
    ttl = title(['V = ' num2str(vs(j)) ' m/s']);
    ttl.Units = 'Normalize'; 
    ttl.Position(1) = 0; % use negative values (ie, -0.1) to move further left
    ttl.HorizontalAlignment = 'left';
    
    subplot(1, 4, 4)
    % Specific options are required to make MLE work for certain datasets.
    % Thanks to: https://groups.google.com/g/comp.soft-sys.matlab/c/vTkovg1IpMQ?pli=1
    o = statset('mlecustom');
    o.FunValCheck = 'off';
    if vs(j) < V_THRESHOLD
        [parHat,parCI] = mle(block_maxima(j, :), 'pdf', gev1, 'start', [std(r) max(r)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
        pd = makedist('GeneralizedExtremeValue','k', SHAPE1, 'sigma', parHat(1), 'mu', parHat(2));
    else
        [parHat,parCI] = mle(block_maxima(j, :), 'pdf', gev2, 'start', [std(r) max(r)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
        pd = makedist('GeneralizedExtremeValue','k', SHAPE2, 'sigma', parHat(1), 'mu', parHat(2));
    end
    
    h = qqplot(block_maxima(j,:), pd);
    set(h(1), 'Marker', 'x')
    set(h(1), 'MarkerEdgeColor', 'r')
    set(h(2), 'Color', 'k')
    set(h(3), 'Color', 'k')
    
    pds = [pds; pd];
    ks = [ks; pd.k];
    sigmas = [sigmas; pd.sigma];
    mus = [mus; pd.mu];
    x1(j) = pd.icdf(1 - 1/N_BLOCKS);
        
    if j == 1
        exportgraphics(gcf, 'gfx/GevFixedShape-9mps.jpg') 
    elseif j == 7
        exportgraphics(gcf, 'gfx/GevFixedShape-15mps.jpg') 
    elseif j == 13
        exportgraphics(gcf, 'gfx/GevFixedShape-21mps.jpg') 
    elseif j == 19
        exportgraphics(gcf, 'gfx/GevFixedShape-30mps.jpg') 
    end
end

for j = 1 : 4
    r = rs_6hr{j};
    for i = 1 : N_BLOCKS * 6
        blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
        [block_maxima_pooled(j, i), maxid] = max(blocks(i,:));
        block_max_i(i) = maxid + (i - 1) * block_length;
    end
    if j <= 2 % lower wind speeds
        [parHat,parCI] = mle(block_maxima_pooled(j, :), 'pdf', gev1, 'start', [std(r) max(r)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
        pd = makedist('GeneralizedExtremeValue','k', SHAPE1, 'sigma', parHat(1), 'mu', parHat(2));
    else
        [parHat,parCI] = mle(block_maxima_pooled(j, :), 'pdf', gev2, 'start', [std(r) max(r)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
        pd = makedist('GeneralizedExtremeValue','k', SHAPE2, 'sigma', parHat(1), 'mu', parHat(2));
    end
    
    pds_6hr(j) = pd;
end


figure
subplot(1, 5, 1)
bar(1, ks)
box off
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(1, 5, 2:5)
y = [sigmas, mus, x1, maxima]';
h = bar(y);
set(h, {'DisplayName'}, file_dist')
legend('location', 'northwest', 'box', 'off') 
box off
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')
exportgraphics(gcf, 'gfx/GevFixedShape-Parameters.jpg') 
exportgraphics(gcf, 'gfx/GevFixedShape-Parameters.pdf') 

figure('Position', [100 100 900 900])

x = [7:0.01:14] * 10^7;

% PDF
for i = 1:length(rs)
    subplot(length(rs), 3, i * 3 - 2)
    ax = gca;
    title(file_dist{i});
    ax.TitleHorizontalAlignment = 'left'; 
    hold on
    histogram(block_maxima(i,:), 'normalization', 'pdf')
    f = pds(i).pdf(x);
    plot(x, f);
    xlim([7*10^7, 13*10^7]);
end

% CDF of 1-hr maximum
for i = 1:length(rs)
    subplot(length(rs), 3, i * 3 - 1)
    hold on
    p = pds(i).cdf(x);
    plot(x, p);
    p = pds(i).cdf(x).^N_BLOCKS;
    plot(x, p);
    realizedp(i) = pds(i).cdf(maxima(i)).^N_BLOCKS;
    xlim([7*10^7, 13*10^7]);
end

% PDF of 1-hr maximum
maxs9 = maxima(1:6);
for i = 1:length(rs)
    subplot(length(rs), 3, i * 3)
    hold on
    rlower = 9*10^7;
    rupper = 14*10^7;
    r = [rlower : (rupper - rlower) / 1000 : rupper];
    f = 60 .* pds(i).cdf(r).^59 .* pds(i).pdf(r);
    plot(r, f, 'linewidth', 1);
    
    ylims = get(gca, 'ylim');
    if i <= 6
        plot([min(maxs9) min(maxs9)], [0 ylims(2)], '-k')
        plot([max(maxs9) max(maxs9)], [0 ylims(2)], '-k')
        h = text(min(maxs9) -0.3 * 10^7, 0.5 * ylims(2), ...
            'min(realized)', 'fontsize', 6', 'color', 'k', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
        h = text(max(maxs9) + 0.3 * 10^7, 0.5 * ylims(2), ...
            'max(realized)', 'fontsize', 6', 'color', 'k', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
    end
    xlim([rlower rupper]);
end

exportgraphics(gcf, 'gfx/GevFixedShape-PDFs.jpg') 
exportgraphics(gcf, 'gfx/GevFixedShape-PDFs.pdf') 

% Combined figure for paper
figure('Position', [100 100 1200 700])
c1 = [0, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];
c3 = [0.9290, 0.6940, 0.1250];
c4 = [0.4660, 0.6740, 0.1880];
darker = 0.6;
darker_colors = [c1; c2; c3; c4] * darker;
barcolors = [repmat(c1,6,1);
    repmat(c2,6,1);
    repmat(c3,6,1);
    repmat(c4,6,1);
    [0, 0, 0];
    darker_colors];
subplot(6, 6, [1 : 12])
y = [sigmas, mus, x1, maxima]';
hbar2 = bar(y);
for i = 1:length(rs)
    hbar2(i).FaceColor = barcolors(i,:);
end
set(hbar2, {'DisplayName'}, file_dist')
legend(hbar2([1, 7, 13, 19]), 'location', 'northwest', 'box', 'off') 
box off
text(0.64, 8*10^7, ['k1 = ' num2str(SHAPE1) ', k2 = ' num2str(SHAPE2)], 'fontsize', 7);
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')

% PDF of 1-hr maximum
for i = 1:length(rs)
    if i <= 6
        maxsgroup = maxima(1:6);
        subplot(6, 7, 14 + i)
    elseif i > 6 && i <= 12
        maxsgroup = maxima(7:12);
        subplot(6, 7, 21 + i - 6)
    elseif i > 12 && i <= 18
        maxsgroup = maxima(13:18);
        subplot(6, 7, 28 + i - 12)
    else
        maxsgroup = maxima(19:24);
        subplot(6, 7, 35 + i - 18)
    end
    hold on
    rlower = 9*10^7;
    rupper = 14*10^7;
    r = [rlower : (rupper - rlower) / 1000 : rupper];
    f = 60 .* pds(i).cdf(r).^59 .* pds(i).pdf(r);
    plot(r, f, 'color', hbar2(i).FaceColor, 'linewidth', 1);    
    ylims = get(gca, 'ylim');
    plot([min(maxsgroup) min(maxsgroup)], [0 ylims(2)], '-k')
    plot([max(maxsgroup) max(maxsgroup)], [0 ylims(2)], '-k')
    h = text(min(maxsgroup) -0.3 * 10^7, 0.5 * ylims(2), ...
        'min(realized)', 'fontsize', 6', 'color', 'black', ...
        'horizontalalignment', 'center');
    set(h,'Rotation',90);
    h = text(max(maxsgroup) + 0.3 * 10^7, 0.5 * ylims(2), ...
        'max(realized)', 'fontsize', 6', 'color', 'black', ...
        'horizontalalignment', 'center');
    set(h,'Rotation',90);
    %legend(file_dist{i}, 'location', 'northeast', 'box', 'off', 'fontsize', 6) 
    title(file_dist{i})%,  'Units', 'normalized', 'Position', [0.8, 0.8, 0]);
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    xlim([rlower, rupper]);
end

for i = 1 : 4
    if i == 1
        maxsgroup = maxima(1:6);
        subplot(6, 7, 21)
    elseif i == 2
        maxsgroup = maxima(7:12);
        subplot(6, 7, 28)
    elseif i == 3
        maxsgroup = maxima(13:18);
        subplot(6, 7, 35)
    else
        maxsgroup = maxima(19:24);
        subplot(6, 7, 42)
    end
    
    hold on
    rlower = 9*10^7;
    rupper = 14*10^7;
    r = [rlower : (rupper - rlower) / 1000 : rupper];
    f = 60 .* pds_6hr(i).cdf(r).^59 .* pds_6hr(i).pdf(r);
    plot(r, f, 'color', darker_colors(i, :), 'linewidth', 2);
    ylims = get(gca, 'ylim');

    plot([min(maxsgroup) min(maxsgroup)], [0 ylims(2)], '-k')
    plot([max(maxsgroup) max(maxsgroup)], [0 ylims(2)], '-k')
    h = text(min(maxsgroup) -0.3 * 10^7, 0.5 * ylims(2), ...
        'min(realized)', 'fontsize', 6', 'color', 'black', ...
        'horizontalalignment', 'center');
    set(h,'Rotation',90);
    h = text(max(maxsgroup) + 0.3 * 10^7, 0.5 * ylims(2), ...
        'max(realized)', 'fontsize', 6', 'color', 'black', ...
        'horizontalalignment', 'center');
    set(h,'Rotation',90);
    %legend(file_dist{i}, 'location', 'northeast', 'box', 'off', 'fontsize', 6) 
    title(file_dist_with_pooled{19 + i})%,  'Units', 'normalized', 'Position', [0.8, 0.8, 0]);
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    xlim([rlower, rupper]);
end

exportgraphics(gcf, 'gfx/GevFixedShape.jpg') 
exportgraphics(gcf, 'gfx/GevFixedShape.pdf') 

