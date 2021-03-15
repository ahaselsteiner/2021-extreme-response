% Load the datasets that were used in the EC-Benchmark, https://github.com/ec-benchmark-organizers/ec-benchmark
load('datasets-complete-DEF-3-variables.mat')


% According to IEC61400-3-1:2019-04, page 18, a logarithmic profile and a 
% power law profile are commonly used. Liu et al.
% (10.1016/j.renene.2019.02.011) use the power law (see their Eq. 1).
hubHeight = 90;
alpha = 0.14; % as for normal wind speed in IEC 61400-3-1 p. 35

% Possible alpha values: 
%   0.1  in 10.1016/j.renene.2019.02.011
%   0.14 for normal wind speed in IEC 61400-3-1 p. 35
%   0.20 for normal wind speed in IEC 61400-1 p. 31
%   0.11 for turbulent extreme wind speed model in 61400-1 p. 33

V10hub = Dc.V .* (hubHeight/10)^alpha;
Dc.V1h_hub = V10hub * 0.95; % 61400-3-1:2019 p. 34

vHsTzStruct2Csv(Dc, 'DForNREL.txt');



function vHsTzStruct2Csv(Data, fileName)
    time = Data.t;
    for iTime = 1:length(time)
       strTime{iTime} = datestr(time(iTime), 'yyyy-mm-dd-HH') ; 
    end
    %%Write CSV file
    fullPath = ['' fileName];
    fid = fopen(fullPath, 'wt') ;
    
    % Print the header
    fprintf(fid, '%s; ', 'time (YYYY-MM-DD-HH)'); % Time
    fprintf(fid, '%s; ', '1-hour mean wind speed at hub height (m/s)'); % Hs
    fprintf(fid, '%s; ', 'Significant wave height (m)'); % Hs
    fprintf(fid, '%s\n', 'Zero-up-crossing period (s)'); % Tz
      
    for iLine = 1:length(time) % Loop through each time/value row
       fprintf(fid, '%s; ', strTime{iLine}); % Print the time string
       fprintf(fid, '%3.4f; ', Data.V1h_hub(iLine)); % Print V
       fprintf(fid, '%3.4f; ', Data.Hs(iLine)); % Print Hs
       fprintf(fid, '%3.4f\n', Data.Tz(iLine)); % Print Tz
    end
    fclose(fid) ;
end
