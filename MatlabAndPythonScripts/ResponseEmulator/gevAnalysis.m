load('OverturningMomentWindspeed9.mat')
file_dist = {'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', ...
    'v = 9 m/s', 'v = 9 m/s', 'v = 15 m/s', 'v = 21 m/s'}; 

N_BLOCKS = 60;


rs = {M.S1, M.S2, M.S3, M.S4, M.S5, M.S6, M.V15, M.V21};
t = M.t;
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