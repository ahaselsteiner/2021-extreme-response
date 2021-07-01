load('OvrDataEmulatorDiffSeed.mat'); % Load dataset in native matlab format.
FormatConventionForMomentTimeSeries; % Loads v, hs, tp

nrows = size(Ovr, 1) * size(Ovr, 2) * size(Ovr, 3);
V = nan(nrows, 1);
Hs = nan(nrows, 1);
Tp = nan(nrows, 1);
R = nan(nrows, size(Ovr, 4));

row = 1;
for vid = 1 : size(Ovr, 1)
    for hsid = 1 : size(Ovr, 2)
        for tpid = 1 : size(Ovr, 3)
            vcell = v(vid);
            hscell = hs(hsid);
            tpcell = tp(hscell, tpid);
            Rcell = squeeze(Ovr(vid, hsid, tpid,:));
            V(row) = vcell;
            Hs(row) = hscell;
            Tp(row) = tpcell;
            R(row, :) = Rcell;
            row = row + 1;
        end
    end
end
t = table(V, Hs, Tp, R);

% Change values to strings to control how the file will be written.
t.Tp = cellfun(@(x)sprintf('%.2f',x), num2cell(t.Tp), 'UniformOutput', false);
t.R = cellfun(@(x)sprintf('%10.3E;',x), num2cell(t.R, 2), 'uni', 0);
t.R = cellfun(@(x)['[' x ']'], t.R, 'UniformOutput', false);

rows_per_file = 36;
for i = 0 : floor((nrows + 1) / rows_per_file)
    rowStart = i * rows_per_file + 1;
    rowEnd = i * rows_per_file + rows_per_file;
    if rowEnd > nrows
        rowEnd = nrows;
    end
    writetable(t(rowStart:rowEnd, :), ['data/overturning-moment-windspeed' num2str(v(i + 1)) '.txt'])
end
 
 