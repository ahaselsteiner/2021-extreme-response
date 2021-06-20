load('STORMS_RANDOM.mat');

A.t = [];
A.V = [];
A.Hs = [];
A.S = [];
A.Tp = [];

% Check length of dataset
Nstorm = length(STORMSrnd) / 100;
n=0;
for i = 1 : Nstorm
    n = n + length(STORMSrnd{i}.data);
end

% Recompile data
data=zeros(n,size(STORMSrnd{1}.data,2));
n=1;
for i=1:Nstorm
    L=length(STORMSrnd{i}.data);
    data(n:n+L-1,:)=STORMSrnd{i}.data;
    n=n+L;
    if mod(i, 10000) == 0
        disp(['i = ' num2str(i) ' / ' num2str(Nstorm)]);
    end
end

A.V = data(:,1);
A.Hs = data(:,2);
A.S = data(:,3);
A.Tz = sqrt((2 .* pi .* A.Hs) ./ (9.81 .* A.S));
A.Tp = 1.2796 * A.Tz; % Assuming a JONSWAP spectrum with gamma = 3.3
n = length(A.V);
A.t = 0 : years(1/(365.25*24)) : (n - 1) * years(1/(365.25*24));
disp(['Converted ' num2str(year(A.t(end))) ' years']);

figure('Position', [100 100 900 600])
layout = tiledlayout(3, 1);
nexttile
plot(A.t, A.V);
ylabel('Wind speed (m/s)');
nexttile
plot(A.t, A.Hs);
ylabel('Significant wave height (m)');
nexttile
plot(A.t, A.S);
ylabel('Steepness (-)');
xlabel(layout, 'Time');

artificialSerimesToCsv(A, ['artificial_time_series_' num2str(year(A.t(end))) 'years.txt']);
