load('OverturningMomentWindspeed9.mat')

% GEV with fixed shape parameter.
SHAPE = -0.2;
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
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(1, 5, 2:5)
y = [sigmas, mus, x1, maxima]';
bar(y)
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'\sigma', '\mu', 'x_{1hr}', 'realized max'})

fig = figure();

x = [8:0.01:14] * 10^7;

% PDF
for i = 1:6
    subplot(6, 3, i * 3 - 2)
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
    p = rand(10^4, 1).^(1/N_BLOCKS);
    x = pds(i).icdf(p);
    histogram(x);
    xlim([10*10^7, 13*10^7]);
end

