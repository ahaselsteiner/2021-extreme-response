function D = importDatasetDFromCSV(dataLines)
%importDatasetDFromCSV imports dataste D from the CSV file
filename = 'DForNREL.txt';

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 1
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["timeYYYYMMDDHH", "hourMeanWindSpeedAtHubHeightms", "SignificantWaveHeightm", "ZeroupcrossingPeriods"];
opts.VariableTypes = ["string", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "timeYYYYMMDDHH", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "timeYYYYMMDDHH", "EmptyFieldRule", "auto");

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
D.t = datetime(tbl.timeYYYYMMDDHH, 'InputFormat','yyyy-MM-dd-HH');
D.V = tbl.hourMeanWindSpeedAtHubHeightms;
D.Hs =  tbl.SignificantWaveHeightm;
D.Tz = tbl.ZeroupcrossingPeriods;
end