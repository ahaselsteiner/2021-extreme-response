% Load file
filename = 'SimNaturalFrequency.out'; %File path
startRow = 6;
endRow = 290406;

formatSpec = '%11s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11s%10s%12s%11s%[^\n\r]';

fileID = fopen(filename,'r');

textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');

fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4]
    
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
           
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end

R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw);
raw(R) = {NaN};

Time = cell2mat(raw(:, 1));
YawBrTDxp = cell2mat(raw(:, 2));
YawBrTDyp = cell2mat(raw(:, 3));
YawBrTDzp = cell2mat(raw(:, 4));

clearvars filename startRow endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;

% FFT
Fs = 80; %Frequency of the recorded data points in Hz 
L = length(YawBrTDxp); %Number of data points

%FFT for tranlational deflection in x direction
Yx = fft(YawBrTDxp); % Fourier transform of the deflection in x direction
P2x = abs (Yx/L);% Two seided spectrum
P1x = P2x (1: L / 2 + 1);% One sided spectrum
P1x(2:end-1) = 2*P1x(2:end-1);
fx = Fs*(0:(L/2))/L;% Domain frequency for the deflection in x direktion

%FFT for tranlational deflection in y direction
Yy = fft(YawBrTDyp); % Fourier transform of the deflection in y direction
P2y = abs (Yy/L);% Two seided spectrum
P1y = P2y (1: L / 2 + 1);% One sided spectrum
P1y(2:end-1) = 2*P1y(2:end-1);
fy = Fs*(0:(L/2))/L;% Domain frequency for the deflection in y direktion

%FFT for tranlational deflection in z direction
Yz = fft(YawBrTDzp); % Fourier transform of the deflection in z direction
P2z = abs (Yz/L);% Two seided spectrum
P1z = P2z (1: L / 2 + 1);% One sided spectrum
P1z(2:end-1) = 2*P1z(2:end-1);
fz = Fs*(0:(L/2))/L;% Domain frequency for the deflection in z direktion

%Plot results
% Deflection of the tower tip in x direction in m 
subplot(2,1,1);
plot(Time,YawBrTDxp);
title('Deflection of the tower tip in x direction in m');
xlabel('Time in s');
ylabel('Defelction in m');
xlim ([0 25]);

% Domain frequencies in x direction
subplot(2,1,2);
plot(fx,P1x);
mx = find(P1x==max(P1x));
hold on;
plot(fx(mx),P1x(mx),'or');
natFeqx = fx(mx);
Tx = 1/fx(mx);
labelx = {strcat('   Natural frequency =  ', num2str(natFeqx)); strcat('   Period =  ', num2str(Tx))};
text(fx(mx),P1x(mx),labelx,'HorizontalAlignment','left');
title('Domain frequencies - translational deflection in x direction');
xlabel('Frequency in Hz');
ylabel('Amplitude');
xlim ([0 3]);
ylim ([0 1.5]);

% % Domain frequencies in y direction
% subplot(3,1,3);
% plot(fy,P1y);
% my = find(P1y==max(P1y));
% hold on
% plot(fy(my),P1y(my),'or');
% natFeqy = fy(my);
% Ty = 1/fy(my);
% labely = {strcat('   Natural frequency = ', num2str(natFeqy)); strcat('   Period = ', num2str(Ty))};
% text(fy(my),P1y(my),labely,'HorizontalAlignment','left');
% title('Domain frequencies - translational deflection in y direction');
% xlabel('Frequency in Hz');
% ylabel('Normalized Amplitude');
% xlim ([0 3]);
% ylim ([0 1.5]);



