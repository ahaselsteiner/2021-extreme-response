%Storage Bending Moment


%Import Bending Moments

filename = 'Tp2\Hs0\11_0_2.out';
startRow = 2406;
endRow = 290406;

formatSpec = '%*407s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%11s%s%[^\n\r]';

fileID = fopen(filename,'r');

textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');

fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]

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

M1N1MMxe = cell2mat(raw(:, 1));
M1N1MMye = cell2mat(raw(:, 2));
M1N2MMxe = cell2mat(raw(:, 3));
M1N2MMye = cell2mat(raw(:, 4));
M1N3MMxe = cell2mat(raw(:, 5));
M1N3MMye = cell2mat(raw(:, 6));
M1N4MMxe = cell2mat(raw(:, 7));
M1N4MMye = cell2mat(raw(:, 8));
M1N5MMxe = cell2mat(raw(:, 9));
M1N5MMye = cell2mat(raw(:, 10));
M1N6MMxe = cell2mat(raw(:, 11));
M1N6MMye = cell2mat(raw(:, 12));
M1N7MMxe = cell2mat(raw(:, 13));
M1N7MMye = cell2mat(raw(:, 14));
M1N8MMxe = cell2mat(raw(:, 15));
M1N8MMye = cell2mat(raw(:, 16));
M1N9MMxe = cell2mat(raw(:, 17));
M1N9MMye = cell2mat(raw(:, 18));

clearvars filename startRow endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;