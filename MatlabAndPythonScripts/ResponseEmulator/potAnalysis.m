load('OverturningMomentWindspeed9.mat')

rs = {M.S1, M.S2, M.S3, M.S4, M.S5, M.S6};
ks = [];
sigmas = [];
thetas = [];
npeaks = [];
maxima = [];
pds = [];
t = M.t;
for j = 1 : 6
    r = rs{j};
    maxima = [maxima; max(r)];
    u = mean(r) + 2*std(r);
    peaks = [];
    peak_ids = [];
    cluster_members = [];
    timestep = t(2) - t(1);
    delta_between_clusters = 60 * 1 / timestep; % in time steps
    for i = 1 : length(t)
        if r(i) > u
           cluster_members = [cluster_members; i];
        else
           if length(cluster_members) > 0
               [p, pid] = max(r(cluster_members));
               peaks = [peaks; p];
               peak_ids = [peak_ids; min(cluster_members) + pid];
               cluster_members = [];
           end
        end

    end
    i = 2;
    while i <= length(peaks)
        if peak_ids(i) - peak_ids(i - 1) < delta_between_clusters || peak_ids(i) - last_peak_id < delta_between_clusters
            if peaks(i) > peaks(i - 1)
                peaks(i - 1) = [];
                peak_ids(i - 1) = [];
            else
                last_peak_id = peak_ids(i);
                peaks(i) = [];
                peak_ids(i) = [];  
            end
            i = i - 1;
        end
        i = i + 1;
    end

    figure()
    subplot(2, 1, 1)
    hold on
    plot(t, r);    
    id = r > u;
    plot(t(id), r(id), '.r');
    plot(t(peak_ids), r(peak_ids), 'xk');
    xlabel('Time (s)');
    ylabel('Overturning moment (Nm)');

    subplot(2, 1, 2)
    pd = fitdist(peaks - u, 'GeneralizedPareto');
    pd.theta = u;
    qqplot(peaks, pd)
    
    pds = [pds; pd];
    pdPeaks{j} = peaks;
    ks = [ks; pd.k];
    sigmas = [sigmas; pd.sigma];
    thetas = [thetas; pd.theta];
    npeaks = [npeaks; length(peaks)];
end


chis = npeaks / length(t);
m = length(t);
x1 = thetas + sigmas ./ ks .* ((m .* chis).^ks - 1);

figure
subplot(1, 6, 1)
bar(1, npeaks)
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'# exceedances per hour'})
subplot(1, 6, 2)
bar(1, ks)
set(gca, 'XTick', [1,])
set(gca, 'XTickLabel', {'k'})
subplot(1, 6, 3:6)
y = [sigmas, thetas, x1, maxima]';
bar(y)
set(gca, 'XTick', [1,2,3,4])
set(gca, 'XTickLabel', {'\sigma', '\theta', 'x_{1hr}', 'realized max'})

fig = figure();

x = [8:0.01:12] * 10^7;

% PDF
for i = 1:6
    subplot(6, 3, i * 3 - 2)
    hold on
    histogram(pdPeaks{i}, 'normalization', 'pdf')
    f = pds(i).pdf(x);
    plot(x, f);
end

% CDF of 1-hr maximum
for i = 1:6
    subplot(6, 3, i * 3 - 1)
    hold on
    p = pds(i).cdf(x);
    plot(x, p);
    p = pds(i).cdf(x).^npeaks(i);
    plot(x, p);
    realizedp(i) = pds(i).cdf(maxima(i)).^npeaks(i);
end

% ICDF of 1-hr maximum
for i = 1:6
    subplot(6, 3, i * 3)
    p = rand(10^4, 1).^(1/npeaks(i));
    x = pds(i).icdf(p);
    histogram(x);
end

