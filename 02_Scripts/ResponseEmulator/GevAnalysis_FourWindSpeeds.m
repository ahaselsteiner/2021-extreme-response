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



% Combined figure for paper
figure('Position', [100 100 1200 550])
layout = tiledlayout(2, 5);
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

nexttile([1 1])
hbar1 = bar(1, [ks; 0; pds_6hr(1).k; pds_6hr(2).k; pds_6hr(3).k; pds_6hr(4).k]);
text(1.35, 0.05, 'pooled', 'fontsize', 6, 'horizontalalignment', 'center');
box off
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
set(hbar1, {'DisplayName'}, file_dist_with_pooled')
lh = legend(hbar1([1, 7, 13, 19]), 'location', 'northoutside', 'Orientation','Horizontal');
lh.Layout.Tile = 'North';

nexttile([1 4])
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
%legend(hbar2([1, 7, 13, 19]), 'location', 'northwest', 'box', 'off') 
box off
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')

% PDF of 1-hr maximum
upper_ylim = 1.8E-7;
nexttile
for i = 1:length(rs)
    hold on
    rlower = 9*10^7;
    rupper = 15*10^7;
    r = [rlower : (rupper - rlower) / 1000 : rupper];
    f = 60 .* pds(i).cdf(r).^59 .* pds(i).pdf(r);
    plot(r, f, 'color', hbar2(i).FaceColor, 'linewidth', 1);
    
   
    
     if mod(i, 6) == 0
        groupid = floor(i/6);
        
        % Distribution of the pooled data
        f = 60 .* pds_6hr(groupid).cdf(r).^59 .* pds_6hr(groupid).pdf(r);
        plot(r, f, 'color', darker_colors(groupid, :), 'linewidth', 2);
        
        xlim([rlower, rupper]);
        ylim([0 upper_ylim]);
        ylims = get(gca, 'ylim');
        
        maxsgroup = maxima((groupid - 1)* 6 + 1: groupid * 6);
        x = [min(maxsgroup) max(maxsgroup) max(maxsgroup) min(maxsgroup)];
        y = [0 0 ylims(2) ylims(2)];
        pcolor = [0.9 0.9 0.9];
        ph = patch(x, y, pcolor, 'EdgeColor', 'none');
        uistack(ph, 'bottom')
        set(gca, 'Layer', 'top')
        
        h = text(min(maxsgroup) + (max(maxsgroup) - min(maxsgroup)) / 2, 0.95 * ylims(2), ...
            'realized maxima', 'fontsize', 6', 'color', 'black', ...
            'horizontalalignment', 'center');
        title(file_dist{i})
        
        nexttile
    end
end

hold on
for groupid = 1 : 4
    % Distribution of the pooled data
    f = 60 .* pds_6hr(groupid).cdf(r).^59 .* pds_6hr(groupid).pdf(r);
    plot(r, f, 'color', darker_colors(groupid, :), 'linewidth', 2);
    xlim([rlower, rupper]);
    ylim([0 upper_ylim])
end

layout.Padding = 'compact';
exportgraphics(gcf, 'gfx/GEV.jpg') 
exportgraphics(gcf, 'gfx/GEV.pdf') 

kgrouped = [ks(1:6), ks(7:12), ks(13:18), ks(19:24)];
mean(kgrouped)
std(kgrouped)