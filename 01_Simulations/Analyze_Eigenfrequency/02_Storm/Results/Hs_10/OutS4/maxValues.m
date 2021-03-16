%% Initialize variables.
filename = '4_35_10_13.out';
startRow = 2406;
endRow = 290406;

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%11s%*11*s%*11*s%*11s%11s%11s%11s%11s%10s%12s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*10*s%*12*s%*11*s%*11*s%*10*s%*12*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11*s%*11s%11s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9]
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


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
Time = cell2mat(raw(:, 1));
RootMFlp1 = cell2mat(raw(:, 2));
RootMFlp2 = cell2mat(raw(:, 3));
RootMFlp3 = cell2mat(raw(:, 4));
RootMEdg1 = cell2mat(raw(:, 5));
RootMEdg2 = cell2mat(raw(:, 6));
RootMEdg3 = cell2mat(raw(:, 7));
ReactMXss = cell2mat(raw(:, 8));
ReactMYss = cell2mat(raw(:, 9));

%% Clear temporary variables
clearvars filename startRow endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;

%Flapwise-Moment Blade 1 ==> RootMFlp1
figure ('Position', [25 25 1500 750]),
subplot (3,1,1), plot (Time, RootMFlp1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Flapwise-Moment','FontSize',10);
grid on

%Edgewise-Moment Blade 1 ==> RootMEdg1
subplot (3,1,2), plot (Time, RootMEdg1, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Edgewise-Moment','FontSize',10);
grid on

%Overturning Moment
QReactMX = ReactMXss.*ReactMXss;            
QReactMY = ReactMYss.*ReactMYss;           
OvrTrngM =sqrt(QReactMX+QReactMY);
subplot (3,1,3), plot (Time, OvrTrngM, 'Linewidth', 1);
xlabel('Time [s]','FontSize',10);
ylabel('Overturning Moment','FontSize',10);
grid on

Bld1 = [];
Bld2 = [];
Bld3 = [];

Flp1 = [];
Flp2 = [];
Flp3 = [];

Edg1 = [];
Edg2 = [];
Edg3 = [];

Ovr = [];

load 'simTzHs10S4';

% v = [3 :2 :25];         %[3 :2 :25]; [26 30:5:80];
Tz = [8 :1 :13];

max_Flp1 = max(RootMFlp1); %Max flapwise moment blade 1
max_Flp2 = max(RootMFlp2); %Max flapwise moment blade 2
max_Flp3 = max(RootMFlp3); %Max flapwise moment blade 3
 
min_Flp1 = min(RootMFlp1); %Min flapwise moment blade 1
min_Flp2 = min(RootMFlp2); %Min flapwise moment blade 2
min_Flp3 = min(RootMFlp3); %Min flapwise moment blade 3

max_Edg1 = max(RootMEdg1); %Max edgewise moment blade 1
max_Edg2 = max(RootMEdg2); %Max edgewise moment blade 2
max_Edg3 = max(RootMEdg3); %Max edgewise moment blade 3

min_Edg1 = min(RootMEdg1); %Min edgewise moment blade 1
min_Edg2 = min(RootMEdg2); %Min edgewise moment blade 2
min_Edg3 = min(RootMEdg3); %Min edgewise moment blade 3
 
if abs(max_Flp1) > abs(min_Flp1)
    a = abs(max_Flp1);
else
    a = abs(min_Flp1);
end

if abs(max_Flp2) > abs(min_Flp2)
    b = abs(max_Flp2);
else
    b = abs(min_Flp2);
end

if abs(max_Flp3) > abs(min_Flp3)
    c = abs(max_Flp3);
else
    c = abs(min_Flp3);
end

Flp1 = [Flp1 a]; % Flp1
Flp2 = [Flp2 b]; % Flp2
Flp3 = [Flp3 c]; % Flp3


if abs(max_Edg1) > abs(min_Edg1)
    d = abs(max_Edg1);
else
    d = abs(min_Edg1);
end

if abs(max_Edg2) > abs(min_Edg2)
    e = abs(max_Edg2);
else
    e = abs(min_Edg2);
end

if abs(max_Edg3) > abs(min_Edg3)
    f = abs(max_Edg3);
else
    f = abs(min_Edg3);
end

Edg1 = [Edg1 d]; % Edg1
Edg2 = [Edg2 e]; % Edg2
Edg3 = [Edg3 f]; % Edg3

OvrM = sqrt(ReactMXss.^2 + ReactMYss.^2);
Ovr = [Ovr max(OvrM)]; %Ovr 

g = sqrt(RootMFlp1.^2 + RootMEdg1.^2);
h = sqrt(RootMFlp2.^2 + RootMEdg2.^2);
k = sqrt(RootMFlp3.^2 + RootMEdg3.^2);

Bld1 = [Bld1 max(g)]; 
Bld2 = [Bld2 max(h)];
Bld3 = [Bld3 max(k)];

save('simTzHs10S4.mat','Flp1','Flp2','Flp3','Edg1','Edg2','Edg3', 'Bld1','Bld2','Bld3','Ovr', 'Tz');