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


rs = {V9.S1, V9.S2, V9.S3, V9.S4, V9.S5, V9.S6, ...
    V15.S1, V15.S2, V15.S3, V15.S4, V15.S5, V15.S6, ...
    V21.S1, V21.S2, V21.S3, V21.S4, V21.S5, V21.S6, ...
    V30.S1, V30.S2, V30.S3, V30.S4, V30.S5, V30.S6};
rs_6hr = {[V9.S1; V9.S2; V9.S3; V9.S4; V9.S5; V9.S6], ...
    [V15.S1; V15.S2; V15.S3; V15.S4; V15.S5; V15.S6], ...
    [V21.S1; V21.S2; V21.S3; V21.S4; V21.S5; V21.S6], ...
    [V30.S1; V30.S2; V30.S3; V30.S4; V30.S5; V30.S6]};
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
block_maxima = zeros(n_seeds, N_BLOCKS);
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

    subplot(1, 4, 4)
    pd = fitdist(block_maxima(j,:)', 'GeneralizedExtremeValue');
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
        exportgraphics(gcf, 'gfx/GEV-9mps.jpg') 
    elseif j == 7
        exportgraphics(gcf, 'gfx/GEV-15mps.jpg') 
    elseif j == 13
        exportgraphics(gcf, 'gfx/GEV-21mps.jpg') 
    elseif j == 19
        exportgraphics(gcf, 'gfx/GEV-30mps.jpg') 
    end
end

for j = 1 : 4
    r = rs_6hr{j};
    for i = 1 : N_BLOCKS * 6
        blocks(i,:) = r((i - 1) * block_length + 1 : i * block_length);
        [block_maxima(j, i), maxid] = max(blocks(i,:));
        block_max_i(i) = maxid + (i - 1) * block_length;
    end
    pd = fitdist(block_maxima(j,:)', 'GeneralizedExtremeValue');
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
legend('location', 'eastoutside', 'box', 'off') 
box off
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')
exportgraphics(gcf, 'gfx/GEVParameters.jpg') 
exportgraphics(gcf, 'gfx/GEVParameters.pdf') 

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
    xlim([7*10^7, 12*10^7]);
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

% ICDF of 1-hr maximum
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
        plot([min(maxima) min(maxima)], [0 ylims(2)], '-k')
        plot([max(maxima) max(maxima)], [0 ylims(2)], '-k')
        h = text(min(maxima) -0.3 * 10^7, 0.5 * ylims(2), ...
            'min(realized)', 'fontsize', 6', 'color', 'k', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
        h = text(max(maxima) + 0.3 * 10^7, 0.5 * ylims(2), ...
            'max(realized)', 'fontsize', 6', 'color', 'k', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
    end
    xlim([rlower rupper]);
end

exportgraphics(gcf, 'gfx/GEV-PDFs.jpg') 
exportgraphics(gcf, 'gfx/GEV-PDFs.pdf') 

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
subplot(6, 6, [1 2 7 8])
hbar1 = bar(1, [ks; 0; pds_6hr(1).k; pds_6hr(2).k; pds_6hr(3).k; pds_6hr(4).k]);
text(1.35, 0.05, 'pooled', 'fontsize', 6, 'horizontalalignment', 'center');
box off
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(6, 6, [3 4 5 6 9 10 11 12])
sigmas_wpooled = [sigmas; 0; pds_6hr(1).sigma; pds_6hr(2).sigma; pds_6hr(3).sigma; pds_6hr(4).sigma];
mus_wpooled = [mus; 0; pds_6hr(1).mu; pds_6hr(2).mu; pds_6hr(3).mu; pds_6hr(4).mu];
y = [sigmas_wpooled, mus_wpooled, [x1; nan(5,1)], [maxima; nan(5,1)]]';
hbar2 = bar(y);
text(1.35, 2 * 10^7, 'pooled', 'fontsize', 6, 'horizontalalignment', 'center');
text(2.35, 10 * 10^7, 'pooled', 'fontsize', 6, 'horizontalalignment', 'center');
for i = 1:length(rs) + 5
    hbar1(i).FaceColor = barcolors(i,:);
    hbar2(i).FaceColor = barcolors(i,:);
end
set(hbar2, {'DisplayName'}, file_dist_with_pooled')
legend(hbar2([1, 7, 13, 19]), 'location', 'northwest', 'box', 'off') 
box off
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

exportgraphics(gcf, 'gfx/GEV.jpg') 
exportgraphics(gcf, 'gfx/GEV.pdf') 

kgrouped = [ks(1:6), ks(7:12), ks(13:18), ks(19:24)];
mean(kgrouped)
std(kgrouped)