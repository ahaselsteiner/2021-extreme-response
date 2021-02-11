load('OverturningMomentWindspeed9.mat')
load('OverturningMomentWindspeed15.mat')
load('OverturningMomentWindspeed21.mat')
file_dist = {'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', ...
    'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', 'v = 15 m/s', ...
    'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s', 'v = 21 m/s'}; 

N_BLOCKS = 60;


rs = {V9.S1, V9.S2, V9.S3, V9.S4, V9.S5, V9.S6, ...
    V15.S1, V15.S2, V15.S3, V15.S4, V15.S5, V15.S6, ...
    V21.S1, V21.S2, V21.S3, V21.S4, V21.S5, V21.S6};
t = V9.t;
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
    
    

    figure()
    subplot(2, 1, 1)
    hold on
    plot(t, r);    
    plot(t(block_max_i), r(block_max_i), 'xr');
    xlabel('Time (s)');
    ylabel('Overturning moment (Nm)');

    subplot(2, 1, 2)
    pd = fitdist(block_maxima(j,:)', 'GeneralizedExtremeValue');
    qqplot(block_maxima(j,:), pd)
    
    pds = [pds; pd];
    ks = [ks; pd.k];
    sigmas = [sigmas; pd.sigma];
    mus = [mus; pd.mu];
    x1(j) = pd.icdf(1 - 1/N_BLOCKS);
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
    p = rand(10^4, 1).^(1/N_BLOCKS);
    x = pds(i).icdf(p);
    histogram(x, 'normalization', 'pdf');
    ylims = get(gca, 'ylim');
    if i <= 6
        plot([min(maxima) min(maxima)], [0 ylims(2)], '-r')
        plot([max(maxima) max(maxima)], [0 ylims(2)], '-r')
        h = text(min(maxima) -0.3 * 10^7, 0.5 * ylims(2), ...
            'min(realized)', 'fontsize', 6', 'color', 'red', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
        h = text(max(maxima) + 0.3 * 10^7, 0.5 * ylims(2), ...
            'max(realized)', 'fontsize', 6', 'color', 'red', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
    end
    xlim([9*10^7, 14*10^7]);
end

exportgraphics(gcf, 'gfx/GEV-PDFs.jpg') 
exportgraphics(gcf, 'gfx/GEV-PDFs.pdf') 

% Combined figure for paper
figure('Position', [100 100 1200 700])
c1 = [0, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];
c3 = [0.9290, 0.6940, 0.1250];
barcolors = [repmat(c1,6,1);
    repmat(c2,6,1);
    repmat(c3,6,1)];
subplot(5, 6, [1 2 7 8])
hbar1 = bar(1, ks)
box off
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(5, 6, [3 4 5 6 9 10 11 12])
y = [sigmas, mus, x1, maxima]';
hbar2 = bar(y);
for i = 1:length(rs)
    hbar1(i).FaceColor = barcolors(i,:);
    hbar2(i).FaceColor = barcolors(i,:);
end
set(hbar2, {'DisplayName'}, file_dist')
legend(hbar2([1, 7, 13]), 'location', 'northwest', 'box', 'off') 
box off
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')

% Distribution as histogram of 1-hr maximum
for i = 1:length(rs)
    subplot(5, 6, 12 + i)
    hold on
    p = rand(10^4, 1).^(1/N_BLOCKS);
    x = pds(i).icdf(p);
    h = histogram(x, 'normalization', 'pdf', 'FaceColor', hbar2(i).FaceColor, 'BinWidth', 2E6);
    ylims = get(gca, 'ylim');
    if i <= 6
        maxsgroup = maxima(1:6);
    elseif i > 6 && i <= 12
        maxsgroup = maxima(7:12);
    else
        maxsgroup = maxima(13:18);
    end
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
    xlim([9*10^7, 14*10^7]);
end

exportgraphics(gcf, 'gfx/GEV.jpg') 
exportgraphics(gcf, 'gfx/GEV.pdf') 