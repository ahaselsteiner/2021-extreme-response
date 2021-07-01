%Storage Bending Moment

v = [11, 17, 35];           %windspeed
hs = [0, 5, 11, 13];        %wave height
tp = [2, 3];                %spectral period index
k = [1:9];                  %node on monipile

% Dyn = zeros(numel(v), numel(hs), numel(tp), numel(k), 288001);
% Stat = zeros(numel(v), numel(hs), numel(tp), numel(k), 288001);
% Ovr= zeros(numel(v), numel(hs), numel(tp), 288001);

windspeed   = 35;
waveheight  = 13;
tpindex     = 3;

a = find(v==windspeed);
b = find(hs==waveheight);
c = find(tp==tpindex);


%Import Bending Moments

filename = 'Tp3\Hs13\35_13_14-5.out';
startRow = 2406;
endRow = 290406;

formatSpec = '%*385s%11s%11s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%s%[^\n\r]';

fileID = fopen(filename,'r');

textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');

fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^[-/+]*\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
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

R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

ReactMXss = cell2mat(raw(:, 1));
ReactMYss = cell2mat(raw(:, 2));
M1N1MKxe = cell2mat(raw(:, 3));
M1N1MKye = cell2mat(raw(:, 4));
M1N2MKxe = cell2mat(raw(:, 5));
M1N2MKye = cell2mat(raw(:, 6));
M1N3MKxe = cell2mat(raw(:, 7));
M1N3MKye = cell2mat(raw(:, 8));
M1N4MKxe = cell2mat(raw(:, 9));
M1N4MKye= cell2mat(raw(:, 10));
M1N5MKxe = cell2mat(raw(:, 11));
M1N5MKye = cell2mat(raw(:, 12));
M1N6MKxe = cell2mat(raw(:, 13));
M1N6MKye = cell2mat(raw(:, 14));
M1N7MKxe = cell2mat(raw(:, 15));
M1N7MKye = cell2mat(raw(:, 16));
M1N8MKxe = cell2mat(raw(:, 17));
M1N8MKye = cell2mat(raw(:, 18));
M1N9MKxe = cell2mat(raw(:, 19));
M1N9MKye = cell2mat(raw(:, 20));

clearvars filename startRow endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;

% A = zeros(9, 288001);
B = zeros(9, 288001);

% A(1,:) = sqrt(M1N1MMxe.^2 + M1N1MMye.^2);
% A(2,:) = sqrt(M1N2MMxe.^2 + M1N2MMye.^2);
% A(3,:) = sqrt(M1N3MMxe.^2 + M1N3MMye.^2);
% A(4,:) = sqrt(M1N4MMxe.^2 + M1N4MMye.^2);
% A(5,:) = sqrt(M1N5MMxe.^2 + M1N5MMye.^2);
% A(6,:) = sqrt(M1N6MMxe.^2 + M1N6MMye.^2);
% A(7,:) = sqrt(M1N7MMxe.^2 + M1N7MMye.^2);
% A(8,:) = sqrt(M1N8MMxe.^2 + M1N8MMye.^2);
% A(9,:) = sqrt(M1N9MMxe.^2 + M1N9MMye.^2);

B(1,:) = sqrt(M1N1MKxe.^2 + M1N1MKye.^2);
B(2,:) = sqrt(M1N2MKxe.^2 + M1N2MKye.^2);
B(3,:) = sqrt(M1N3MKxe.^2 + M1N3MKye.^2);
B(4,:) = sqrt(M1N4MKxe.^2 + M1N4MKye.^2);
B(5,:) = sqrt(M1N5MKxe.^2 + M1N5MKye.^2);
B(6,:) = sqrt(M1N6MKxe.^2 + M1N6MKye.^2);
B(7,:) = sqrt(M1N7MKxe.^2 + M1N7MKye.^2);
B(8,:) = sqrt(M1N8MKxe.^2 + M1N8MKye.^2);
B(9,:) = sqrt(M1N9MKxe.^2 + M1N9MKye.^2);

% for i=1:9
%     Dyn(a,b,c,i,:) = A(i,:);
% end

for i=1:9
    Stat(a,b,c,i,:) = B(i,:);
end

BaseRM = sqrt(ReactMXss.^2 + ReactMYss.^2); %Calculate base reaction moment
Ovr(a,b,c,:) = (BaseRM);


save('BendingMoment.mat','Stat', 'Ovr', 'Time');

msgbox('Ready');


