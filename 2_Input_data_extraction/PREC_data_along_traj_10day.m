%% Extract the lat & lon info along the traj
clear;
clc;

% Define the time range
time_valid = [datenum(2013,10,1):1/24:datenum(2023,12,31,23,0,0)]';
time_valid = [year(time_valid) month(time_valid) day(time_valid) hour(time_valid) minute(time_valid) second(time_valid) time_valid];
num_traj = length(time_valid);

% Organize the trajecctory position data
load('Data_extracted_all_10days','Traj_time','TrajData');
idx_valid = round((time_valid(:,7)-Traj_time(1,7))*24)+1;

lat = NaN(num_traj, 241);
lon = NaN(num_traj, 241);

for i = 1:num_traj
    lat(i,:) = data_gdas{idx_valid(i)}(:,1);
    lat(i,:) = data_gdas{idx_valid(i)}(:,2);
end

% Predefine the output
data_preci = NaN(num_traj, 241);
datetime_valid = datetime(time_valid(:,1:6));

save('preci_extracted_blank.mat', 'lat', 'lon', 'data_preci', 'datetime_valid');
save('file_io_info.mat', 'time_valid');


%% Preallocate storage for coordinates
load('file_io_info.mat');
num_traj = size(time_valid,1);
time_valid_tmp = datetime(time_valid(:,1:6));

all_time_points = NaT(num_traj,241);
for i = 1:241
    all_time_points(:,242-i) = time_valid_tmp-(i-1)*hours(1);
end

unique_time_points = unique(all_time_points);


% Preallocate storage for coordinates
coordinates_per_date = cell(length(unique_time_points), 1);
for i = 1:length(unique_time_points)
    row_col_tmp = [[i-240:i]' [241:-1:1]'];
    idx_remove = row_col_tmp<1 | row_col_tmp>num_traj;
    row_col_tmp(idx_remove,:) = [];
    coordinates_per_date{i} = row_col_tmp;
end


save('file_io_info.mat', 'unique_time_points', ...
    'coordinates_per_date', 'all_time_points', '-append');

%% check if coordinates are correct
clear;
clc;

load('file_io_info.mat');

% Preallocate an array to store the row counts
row_counts = NaN(length(unique_time_points), 1);

% Loop through each element in the cell array
for i = 1:length(unique_time_points)
    % Get the size of the current cell's content
    [rows, ~] = size(coordinates_per_date{i});
    
    % Store the row count
    row_counts(i) = rows;
end

% Calculate the sum of all row counts
total_rows = sum(row_counts);

% Display the result
disp('Total sum of rows:');
disp(total_rows/241);

%% Get the file list needed for I/O
clear;
clc;

% Load the required data
load('file_io_info.mat');

for y = 2013:2023
    % Folder containing the files
    folder_path = fullfile('E:\GPM_raw_data',num2str(y));

    % Get the list of all files in the folder
    file_list = dir(fullfile(folder_path, '*.HDF5'));

    % Extract the full paths of the files
    file_paths = fullfile({file_list.folder}, {file_list.name});

    % Datetime vector (from loaded data)
    datetime_vector = unique_time_points;

    % Initialize a cell array to store the matched file paths
    matched_files = {};

    % Initialize a waitbar
    h = waitbar(0, 'Processing files...');

    % Loop through each file and check if it matches a datetime in the vector
    for i = 1:length(file_paths)
        % Update the waitbar based on the progress
        waitbar(i / length(file_paths), h, sprintf('Processing file %d of %d', i, length(file_paths)));

        % Extract the datetime string from the filename
        name_parts = split(file_list(i).name, '.'); % Split the filename by '.'
        datetime_str = [name_parts{5}(1:8), name_parts{5}(11:14)];

        % Parse the date and time from the filename
        file_datetime = datetime(datetime_str, 'InputFormat','yyyyMMddHHmm');

        % Check if the file datetime is in the datetime vector
        if ismember(file_datetime, datetime_vector)
            matched_files{end+1} = file_paths{i}; % Add the full path of the matched file to the list
            matched_files{end+1} = file_paths{i+1}; %%% Add the companion second-half hour
        end
    end

    % Close the waitbar
    close(h);

    % % Display the matched file paths
    % disp('Matched files:');
    % disp(matched_files);

    % Convert the matched file paths to a string array
    matched_files_str = string(matched_files);

    % Save to a text file with one file path per row
    writelines(matched_files_str, ['matched_files_',num2str(y),'.txt']);
end

%% check the total file number
% Get list of files matching the pattern
file_list = dir('matched_files*.txt');

% Initialize counter for 'HDF5'
HDF5_count = 0;

% Loop through each file and count occurrences of 'HDF5'
for i = 1:length(file_list)
    % Get the full path of the current file
    file_name = file_list(i).name;
    
    % Read the file content
    file_content = fileread(file_name);
    
    % Count occurrences of 'HDF5' in the file
    count_in_file = count(file_content, 'HDF5');
    
    % Add to the total count
    HDF5_count = HDF5_count + count_in_file;
    
    % Display progress (optional)
    fprintf('File: %s contains %d files.\n', file_list(i).name, count_in_file);
end

% Display the total count
disp(['Total number of all files: ', num2str(HDF5_count)]);


%% main function
clear;
clc;
load('file_io_info.mat');
load('preci_extracted_blank.mat');

for Y = 2013:2024
    % Path to the text file
    file_list_txt = ['matched_files_',num2str(Y),'.txt'];

    % Read all lines from the file
    lines = readlines(file_list_txt);

    % Remove empty or whitespace-only lines
    file_paths = lines(strtrim(lines) ~= ""); % Keep only non-blank lines

    % Initialize a waitbar for progress
    h = waitbar(0, ['Processing files for year ',num2str(Y),'...']);

    % Loop through each file in the list
    for i = 1:length(file_paths)/2
        % Update the waitbar
        waitbar(2*i / length(file_paths), h, sprintf('Processing file %d of %d', i, length(file_paths)));

        % Get the current file path
        filename_h5_1 = file_paths(2*i-1);
        filename_h5_2 = file_paths(2*i);

        precipitation_data_1 = h5read(filename_h5_1, '/Grid/precipitation');
        precipitation_data_1(precipitation_data_1<0) = NaN;
        precipitation_data_2 = h5read(filename_h5_2, '/Grid/precipitation');
        precipitation_data_2(precipitation_data_2<0) = NaN;
        precipitation_data = mean(cat(3,precipitation_data_1,precipitation_data_2),3,'omitnan');
        lat_data = h5read(filename_h5_1, '/Grid/lat');
        lon_data = h5read(filename_h5_1, '/Grid/lon');
        time_data = h5read(filename_h5_1, '/Grid/time');

        base_time = datetime(1980, 1, 6, 0, 0, 0);
        time_standard = base_time + seconds(time_data);

        % Earth's radius in kilometers
        radius_earth = 6371;

        % Create meshgrid of latitudes and longitudes
        [lon_mesh, lat_mesh] = meshgrid(lon_data, lat_data);

        % Find the index of the target datetime
        index = find(unique_time_points == time_standard);
        coordinates = coordinates_per_date{index};
        for j = 1:size(coordinates, 1)
            % Extract the coordinates of the current row
            x = coordinates(j, 1); % row num
            y = coordinates(j, 2); % column num

            target_lon = lon(x,y);
            target_lat = lat(x,y);

            % Convert degrees to radians
            lat_mesh_rad = deg2rad(lat_mesh);
            lon_mesh_rad = deg2rad(lon_mesh);
            target_lat_rad = deg2rad(target_lat);
            target_lon_rad = deg2rad(target_lon);

            % Calculate differences in latitude and longitude
            dlat = lat_mesh_rad - target_lat_rad;
            dlon = lon_mesh_rad - target_lon_rad;

            % Apply Haversine formula
            a = sin(dlat / 2).^2 + cos(target_lat_rad) .* cos(lat_mesh_rad) .* sin(dlon / 2).^2;
            a = max(min(a,1), 0);
            c = 2 * atan2(sqrt(a), sqrt(1 - a));

            % Distance in kilometers
            distance = radius_earth * c;

            % traj_step
            traj_step = 241 - y;

            weighted_avg_precip = weighted_avg_precipitation(precipitation_data, ...
                distance, traj_step);
            data_preci(x,y) = weighted_avg_precip;
        end

    end

    % Close the waitbar
    close(h);
end

save('preci_data_extracted_all_10days.mat','data_preci', ...
    'lat','lon','datetime_valid');

disp('Processing complete!');


