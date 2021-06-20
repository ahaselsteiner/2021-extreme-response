% Combine Workspaces

x = load ('CalmSeaLowWind');
y = load ('CalmSeaHighWind');

vrs = fieldnames(x);
if ~isequal(vrs,fieldnames(y))
    error('Different variables in these MAT-files')
end

for k = 1:length(vrs)
    x.(vrs{k}) = [x.(vrs{k}) y.(vrs{k})];
end

save ('CalmSeaComplete', '-struct', 'x')

clear all