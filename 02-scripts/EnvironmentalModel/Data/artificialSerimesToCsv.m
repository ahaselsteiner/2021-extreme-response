function artificialSerimesToCsv(Data, fileName)
    time = Data.t;
    %%Write CSV file
    fullPath = ['' fileName];
    fid = fopen(fullPath, 'wt') ;
    
    % Print the header
    fprintf(fid, '%s; ', 'time (YYYY-MM-DD-HH)'); % Time
    fprintf(fid, '%s; ', '1-hour mean wind speed at 90 m (m/s)'); % V
    fprintf(fid, '%s; ', 'Significant wave height (m)'); % Hs
    fprintf(fid, '%s; ', 'Zero-up-crossing period (s)'); % Tz
    fprintf(fid, '%s; ', 'Spectral peak period (s)'); % Tz
    fprintf(fid, '%s\n', 'Steepness (-)'); % S
      
    for iLine = 1:length(time) % Loop through each time/value row
       if mod(iLine, 1000) == 0
           disp(['writing file, line = ' num2str(iLine) ' / ' num2str(length(time))]);
       end
       strTime = datestr(time(iLine), 'yyyy-mm-dd-HH') ;
       fprintf(fid, '%s; ', strTime); % Print the time string
       fprintf(fid, '%3.4f; ', Data.V(iLine)); % Print V
       fprintf(fid, '%3.4f; ', Data.Hs(iLine)); % Print Hs
       fprintf(fid, '%3.4f; ', Data.Tz(iLine)); % Print Tz
       fprintf(fid, '%3.4f; ', Data.Tp(iLine)); % Print Tp
       fprintf(fid, '%3.4f\n', Data.S(iLine)); % Print S
    end
    fclose(fid) ;
end
