% This script is to read the data from all trajectory files of each year to
% a single matlab matrix

path1 = '..\BT_multiyear'; % The parent directory of trajectory files
for y = 2013:2023
    path2 = fullfile(path1,num2str(y)); % The children directory for each year. Do not place any files other than trajectory files here before executing this script.
    TrajFiles = dir(fullfile(path2,'*'));
    TrajFiles(1:2) = [];
    TrajNum = length(TrajFiles);
    TrajData = cell(TrajNum,1);
    Traj_time = NaN(TrajNum,7); % Year Month Day Hour Minute Second datenum

    h = waitbar(0,'Reading Traj files, please wait...');
    for i = 1:TrajNum
        [temp,~] = ReadTrajFile(path2,TrajFiles(i).name);
        TrajData{i} = temp;

        temp = TrajFiles(i).name;
        Traj_time(i,1:6) = [str2double({temp(1:2) temp(3:4) temp(5:6) temp(7:8)}) 0 0];
        waitbar(i/TrajNum)
    end
    close(h)

    Traj_time(:,1) = Traj_time(:,1)+2000;
    Traj_time(:,7) = datenum([Traj_time(:,1:6)]);


    Variable = {'Start_height_code';'?';'Year';'Month';'Day';'Hour_UTC';'?';...
        '?';'tracking_hour';'lat';'lon';'height';'pressure';'theta';'temp';...
        'rainfall';'BLH';'RH';'Specific_humidity';'H2O_mixing ratio';'TERR_MSL';'DSWF'};

    save(fullfile(path2,'Traj_data_extracted'),'TrajFiles','TrajData','Variable','Traj_time')
end
