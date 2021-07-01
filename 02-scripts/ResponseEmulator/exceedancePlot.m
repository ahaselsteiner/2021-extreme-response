function ax = exceedancePlot(x, conf, ls, ax)
% Written by Ed Mackay and adapted by Andreas Haselsteiner.

if nargin < 2
    conf = 0;
end
if nargin < 3
    ls = 'ko';
end
if nargin < 4
    fig = figure();
    ax = nexttile();
end

% Empirical exceedance probabilities
n = length(x);
x = sort(x);
k = 1 : n;
P = (k - 0.31) / (n + 0.38);


% Plot results
plot(x, 1 - P, ls, 'displayname', 'annual extremes')
set(gca, 'yscale', 'log')
ylabel('Exceedance probability')
% Confidence bounds on exceedance probabilities
if conf == 1
    a = k;
    b = n - k + 1;
    Plow = icdf('beta', 0.025, a, b);
    Phigh = icdf('beta', 0.975, a, b);

    hold on; box off;
    plot(x, 1 - Plow, 'r--', 'displayname', '95% confidence interval')
    plot(x, 1 - Phigh, 'r--', 'handlevisibility', 'off')

    legend('location','northeast', 'box', 'off')
end
