% Combine Workspaces

x = load ('calmSeaLowWind');
y = load ('calmSeaHighWind');

vrs = fieldnames(x);
if ~isequal(vrs,fieldnames(y))
    error('Different variables in these MAT-files')
end

for k = 1:length(vrs)
    x.(vrs{k}) = [x.(vrs{k}) y.(vrs{k})];
end

save ('calmSeaComplete', '-struct', 'x')

clear all