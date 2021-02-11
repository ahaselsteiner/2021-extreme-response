load('OvrDataEmulator');
maxr = max(Ovr,[],4);
gridSize = size(maxr);
currentNrEntries = sum(sum(sum(maxr>0)))
r = squeeze(Ovr(3,1,1,:));

% GEV parameters
ks = nan(gridSize);
sigmas = nan(gridSize);
mus = nan(gridSize);


