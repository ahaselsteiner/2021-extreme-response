%load('STORMS_RANDOM.mat');

A.t = [];
A.V = [];
A.Hs = [];
A.S = [];
A.Tp = [];

% Check length of dataset
Nstorm = length(STORMSrnd);
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
Tz = sqrt((2 .* pi .* A.Hs) ./ (9.81 .* A.S));
A.Tp = 1.2796 * Tz; % Assuming a JONSWAP spectrum with gamma = 3.3
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

vHsSStruct2Csv(A, ['artificial_time_series_' num2str(year(A.t(end))) 'years.txt']);

function vHsSStruct2Csv(Data, fileName)
    time = Data.t;
    %%Write CSV file
    fullPath = ['' fileName];
    fid = fopen(fullPath, 'wt') ;
    
    % Print the header
    fprintf(fid, '%s; ', 'time (YYYY-MM-DD-HH)'); % Time
    fprintf(fid, '%s; ', '1-hour mean wind speed at 90 m (m/s)'); % Hs
    fprintf(fid, '%s; ', 'Significant wave height (m)'); % Hs
    fprintf(fid, '%s\n', 'Steepness (-)'); % S
      
    for iLine = 1:length(time) % Loop through each time/value row
       if mod(iLine, 1000) == 0
           disp(['writing file, line = ' num2str(iLine) ' / ' num2str(length(time))]);
       end
       strTime = datestr(time(iLine), 'yyyy-mm-dd-HH') ;
       fprintf(fid, '%s; ', strTime); % Print the time string
       fprintf(fid, '%3.4f; ', Data.V(iLine)); % Print V
       fprintf(fid, '%3.4f; ', Data.Hs(iLine)); % Print Hs
       fprintf(fid, '%3.4f\n', Data.S(iLine)); % Print Tz
    end
    fclose(fid) ;
end
