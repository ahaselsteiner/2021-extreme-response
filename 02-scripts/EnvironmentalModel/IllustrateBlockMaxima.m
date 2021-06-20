Nstorm = 3;
n=0;
for i = 1 : Nstorm
    n = n + length(STORMSrnd{i}.data);
end

figure('Position', [100 100 400 400])
layout = tiledlayout(3, 1);
axs = gobjects(3, 1);
for i = 1 : 3
  axs(i) = nexttile;
  hold on
end
% Recompile data
data = zeros(n, size(STORMSrnd{1}.data,2));
n = 0;
Ls = zeros(Nstorm, 1);
for i=1:Nstorm
    L=length(STORMSrnd{i}.data);
    Ls(i) = L;
    data(n + 1:n + L,:)=STORMSrnd{i}.data;
    
    if mod(i, 10000) == 0
        disp(['i = ' num2str(i) ' / ' num2str(Nstorm)]);
    end
    t = n/24 + [1:L] / 24;
    
    pmax = [24 5.7 0.085];
    if any([1, 3] == i)
        for j = 1 : 3
            nexttile(j)
            pgon = polyshape([t(1) t(end) t(end) t(1)],[0 0 pmax(j) pmax(j)]);
            plot(pgon, 'facecolor', [0.5 0.5 0.5], 'edgecolor', 'none');
            ylim([0 pmax(j)]);
        end
    end
    ms = 5;
    nexttile(1)
    plot(t, STORMSrnd{i}.data(:,1), '-k')
    [maxv, maxi] = max(STORMSrnd{i}.data(:,1));
    plot(t(maxi), maxv, 'ok', 'markersize', ms);
    text(t(1) + 0.5, 0.9 * pmax(1), ['block ' num2str(i)], 'fontsize', 8);
    ylabel('V (m s^{-1})');
    nexttile(2)
    plot(t, STORMSrnd{i}.data(:,2), '-k')
    [maxv, maxi] = max(STORMSrnd{i}.data(:,2));
    plot(t(maxi), maxv, 'ok', 'markersize', ms);
    ylabel('H_s (m)');
    nexttile(3)
    plot(t, STORMSrnd{i}.data(:,3), '-k')
    [maxv, maxi] = max(STORMSrnd{i}.data(:,3));
    plot(t(maxi), maxv, 'ok', 'markersize', ms);
    ylabel('S (-)');
    
    n = n + L;
end

linkaxes(axs, 'x');
xlim([0 max(t)]);

exportgraphics(layout, 'gfx/StormBlocks.jpg') 
exportgraphics(layout, 'gfx/StormBlocks.pdf') 