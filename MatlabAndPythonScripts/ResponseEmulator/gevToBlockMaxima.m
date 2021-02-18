function [pd block_maxima] = gevToBlockMaxima(x, nBlocks, fixedK)
%gevToBlockmaxima Fits a GEV to blockmaxima
%   x = time series
%   nBLocks = number of block the time series shall be divided into
%   fixedK = value of fixed shape parameter, set to 'free' if it shall not
%           be fixed

if isa(x,'single')
    x = double(x);
end
block_length = floor(length(x) / nBlocks);

for i = 1 : nBlocks
    blocks(i,:) = x((i - 1) * block_length + 1 : i * block_length);
    [block_maxima(i), maxid] = max(blocks(i,:));
    block_max_i(i) = maxid + (i - 1) * block_length;
end

if strcmp(fixedK, 'free')
    pd = fitdist(block_maxima', 'GeneralizedExtremeValue');
else
    % Generalized extreme value distributio with fixed shape parameter.
    gev = @(x, sigma, mu) gevpdf(x, fixedK, sigma, mu); 

    o = statset('mlecustom');
    o.FunValCheck = 'off';
    [parHat,parCI] = mle(block_maxima, 'pdf', gev, 'start', [std(x) max(x)], 'lower', [1, 1], 'upper', [10E12, 10E12], 'options', o);
    pd = makedist('GeneralizedExtremeValue','k', fixedK, 'sigma', parHat(1), 'mu', parHat(2));
end

end

