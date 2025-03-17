% Prompt the user to select a folder
folder = uigetdir('Select a folder containing CSV files');

% Prompt the user to enter the summary file name
prompt = {'Enter the name of the summary file (without extension):'};
dlgtitle = 'Summary File Name';
dims = [1 50];
definput = {'summary'}; % Default summary file name
summary_name = inputdlg(prompt, dlgtitle, dims, definput);

% Check if the user canceled the input dialog
if isempty(summary_name)
    disp('User canceled the operation.');
    return;
end

% Get a list of all CSV files in the selected folder
files = dir(fullfile(folder, '*.csv'));
num_files = length(files);

% Initialize a cell array to store data
summary_data = {};

% Loop through each CSV file to extract data
for i = 1:num_files
    file_path = fullfile(folder, files(i).name);
    
    % Extract ID and Session from the file name
    [~, baseFileName, ~] = fileparts(files(i).name);
    c = regexp(baseFileName, '_', 'split');
    
    % Ensure that the file name is correctly split
    if numel(c) < 2
        disp(['Skipping file ', files(i).name, ' because it does not match the expected naming convention.']);
        continue; % Skip to the next file
    end
    
    ID = c{1};
    Session = c{2};
    
    % Read the CSV file
    tbl = readtable(file_path);
    
    % Append ID and Session to the data
    num_rows = height(tbl);
    IDs = repmat({ID}, num_rows, 1);
    Sessions = repmat({Session}, num_rows, 1);
    
    % Extract data from the table
    data = tbl{:, 1:end}; % Include all columns
    
    % Combine ID, Session, and data
    combined_data = [IDs, Sessions, num2cell(data)];
    
    % Append to the summary data
    summary_data = [summary_data; combined_data];
end

% Create variable names
var_names = [{'ID'}, {'Session'}, tbl.Properties.VariableNames(:)'];

% Convert cell array to a table
summary_table = cell2table(summary_data, 'VariableNames', var_names);

% Construct the file path for the summary Excel file
summary_excel_path = fullfile(folder, [summary_name{1}, '.xlsx']);

% Write the table to the first sheet of the Excel file
writetable(summary_table, summary_excel_path, 'Sheet', 'RawData');

% Open the Excel file and read the data
excel_data = readtable(summary_excel_path, 'Sheet', 'RawData');

% Copy ID and Session information to the second sheet
id_session_data = excel_data(:, 1:2);
writetable(id_session_data, summary_excel_path, 'Sheet', 'ZScores', 'Range', 'A1');

% Transform the remaining data using zscore
remaining_data = excel_data(:, 3:end);
zscore_data = array2table(zscore(table2array(remaining_data), 0, 2), 'VariableNames', remaining_data.Properties.VariableNames);
writetable(zscore_data, summary_excel_path, 'Sheet', 'ZScores', 'Range', 'C1');

% Create the variable named as specified by the user for Summary File Name in the MATLAB workspace
var_name = matlab.lang.makeValidName([summary_name{1}, '_zscores']); % Ensure a valid variable name
eval([var_name, ' = table2array(zscore_data);']);

% Prompt the user to enter the start time, increment, and end time for s
prompt = {'Start Time:', 'Increment:', 'End Time:'};
dlgtitle = 'Enter Time Parameters';
dims = [1 50];
definput = {'-10', '0.5', '20'}; % Default values
time_params = inputdlg(prompt, dlgtitle, dims, definput);

% Convert the inputs to numeric values
start_time = str2double(time_params{1});
increment = str2double(time_params{2});
end_time = str2double(time_params{3});

% Create s based on user inputs
s = start_time:increment:end_time;


% % Prompt the user to enter the peak detection parameters
prompt = {'Min Peak Prominence:', 'Min Peak Width (s):', 'Max Peak Width (s):'};
dlgtitle = 'Enter Peak Detection Parameters';
dims = [1 50];
definput = {'1.5', '1', '6'}; % Default values
peak_params = inputdlg(prompt, dlgtitle, dims, definput);
% % Convert the inputs to numeric values
MinProm = str2num(peak_params{1});
MinWidth = str2num(peak_params{2});
MaxWidth = str2num(peak_params{3});

% Execute the provided code with the created variable 'T1'
T1 = eval(var_name); % Replace %%%%%T1 with the variable name

% Initialize cell arrays to store peaks, locations, widths, and prominences
P = cell(size(T1, 1), 1);
L = cell(size(T1, 1), 1);
W = cell(size(T1, 1), 1);
Pr = cell(size(T1, 1), 1);

% Loop over each row of T1 to find peaks and related information
for k1 = 1:size(T1, 1)
    [pk, loc, widths, proms] = findpeaks(T1(k1,:), s, 'MinPeakProminence', 1.5, 'MinPeakWidth', 1, 'MaxPeakWidth', 6, 'Annotate', 'extents', 'WidthReference', 'halfheight');
    P{k1} = pk; % Peaks
    L{k1} = loc; % Locations
    W{k1} = widths; % Widths
    Pr{k1} = proms; % Prominences
end

% Transpose cell arrays
TPk = transpose(P);
TL = transpose(L);
TW = transpose(W);
TPr = transpose(Pr);

function data_no_blanks = remove_blanks_and_shift_left(data)
    % Initialize the modified data matrix
    data_no_blanks = data;

    % Loop through each row
    for i = 1:size(data_no_blanks, 1)
        row = data_no_blanks(i, :); % Extract the current row

        % Find indices of non-NaN elements
        non_nan_indices = ~isnan(row);

        % Remove NaN elements and shift cells left
        row = row(non_nan_indices);
        
        % Update the row in the modified data matrix
        data_no_blanks(i, 1:numel(row)) = row;
    end


n = cellfun(@numel,TPk);
k = cumsum(n);
ii = k-n+1;
v = ones(k(end),1);
%v(ii(2:end)) = v(ii(2:end)) - n(1:end-1);

%Writes excel file containing the Peak within the region for each trial
A = accumarray([repelem((1:numel(n))',n),cumsum(v)],[TPk{:}]',[],[],nan);
A_no_blanks = remove_blanks_and_shift_left(A);
xlswrite(summary_excel_path, A_no_blanks, 'Peaks'); %'HM_Trial_Peaks_Peaks.xlsx',A); %%%CHANGE file name

r = cellfun(@numel,TL);
q = cumsum(r);
iii = q - r + 1;
w = ones(q(end),1);

%Writes excel file containing the Location of the Peak within the region for each trial
B = accumarray([repelem((1:numel(r))',r),cumsum(w)],[TL{:}]',[],[],nan);
B_no_blanks = remove_blanks_and_shift_left(A);
xlswrite(summary_excel_path, B_no_blanks, 'Location');% 'HM_Trial_Peaks_Location.xlsx',B);%%%CHANGE file name

nn = cellfun(@numel,TW);
kk = cumsum(nn);
iit = kk - nn + 1;
vv = ones(kk(end),1);

%Writes excel file containing the Peak Width within the region for each trial
AA = accumarray([repelem((1:numel(nn))',nn),cumsum(vv)],[TW{:}]',[],[],nan);
AA_no_blanks = remove_blanks_and_shift_left(A);
xlswrite(summary_excel_path, AA_no_blanks, 'Width'); %'HM_Trial_Peaks_width.xlsx',AA);%%%CHANGE file name

rr = cellfun(@numel,TPr);
qq = cumsum(rr);
iio = qq - rr + 1;
ww = ones(qq(end),1);

%Writes excel file containing the Prominence (rise above surrounding values) within the region for each trial
BB = accumarray([repelem((1:numel(rr))',rr),cumsum(ww)],[TPr{:}]',[],[],nan);
BB_no_blanks = remove_blanks_and_shift_left(A);
xlswrite(summary_excel_path, BB_no_blanks, 'Prominence'); %'HM_Trial_Peaks_prominence.xlsx',BB);%%%CHANGE file name
end


% Write Peaks, Location, Width, and Prominence data to separate sheets in the summary Excel file
%xlswrite(summary_excel_path, TPk, 'Peaks');
%xlswrite(summary_excel_path, TL, 'Location');
%xlswrite(summary_excel_path, TW, 'Width');
%xlswrite(summary_excel_path, TPr, 'Prominence');
