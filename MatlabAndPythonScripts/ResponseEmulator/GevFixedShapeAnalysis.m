load('OverturningMomentWindspeed9.mat')
file_dist = {'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', 'v = 9 m/s', ...
    'v = 9 m/s', 'v = 9 m/s', 'v = 15 m/s', 'v = 21 m/s'}; 

% GEV with fixed shape parameter.
SHAPE = -0.3;
gev = @(x, sigma, mu) gevpdf(x, SHAPE, sigma, mu); 

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
    % Specific options are required to make MLE work for certain datasets.
    % Thanks to: https://groups.google.com/g/comp.soft-sys.matlab/c/vTkovg1IpMQ?pli=1
    o = statset('mlecustom');
    o.FunValCheck = 'off';
    [parHat,parCI] = mle(block_maxima(j, :), 'pdf', gev, 'start', [std(r) max(r)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
    pd = makedist('GeneralizedExtremeValue','k', SHAPE, 'sigma', parHat(1), 'mu', parHat(2));
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

% Distribution as histogram of 1-hr maximum
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

exportgraphics(gcf, 'gfx/GevFixedShape-PDFs.jpg') 
exportgraphics(gcf, 'gfx/GevFixedShape-PDFs.pdf') 

% Combined figure for paper
figure('Position', [100 100 1200 700])
subplot(4, 6, [1 2 7 8])
bar(1, ks)
box off
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(4, 6, [3 4 5 6 9 10 11 12])
y = [sigmas, mus, x1, maxima]';
hbar = bar(y);
set(hbar, {'DisplayName'}, file_dist')
legend('location', 'northwest', 'box', 'off') 
box off
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'$\sigma$', '$\mu$', '$\hat{x}_{1hr}$', 'realized max'}, 'TickLabelInterpreter', 'latex')

% Distribution as histogram of 1-hr maximum
for i = 1:length(rs)
    subplot(4, 6, 12 + i)
    hold on
    p = rand(10^4, 1).^(1/N_BLOCKS);
    x = pds(i).icdf(p);
    h = histogram(x, 'normalization', 'pdf', 'FaceColor', hbar(i).FaceColor, 'BinWidth', 2E6);
    ylims = get(gca, 'ylim');
    if i <= 6
        plot([min(maxima) min(maxima)], [0 ylims(2)], '-k')
        plot([max(maxima) max(maxima)], [0 ylims(2)], '-k')
        h = text(min(maxima) -0.3 * 10^7, 0.5 * ylims(2), ...
            'min(realized)', 'fontsize', 6', 'color', 'black', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
        h = text(max(maxima) + 0.3 * 10^7, 0.5 * ylims(2), ...
            'max(realized)', 'fontsize', 6', 'color', 'black', ...
            'horizontalalignment', 'center');
        set(h,'Rotation',90);
    end
    %legend(file_dist{i}, 'location', 'northeast', 'box', 'off', 'fontsize', 6) 
    title(file_dist{i})%,  'Units', 'normalized', 'Position', [0.8, 0.8, 0]);
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    xlim([9*10^7, 14*10^7]);
end

exportgraphics(gcf, 'gfx/GevFixedShape.jpg') 
exportgraphics(gcf, 'gfx/GevFixedShape.pdf') 

