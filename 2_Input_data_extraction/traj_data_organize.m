% Organize the trajectory data and get the flag_Land: 1-over land; 0-over
% ocean

period = [datenum(2013,10,1) datenum(2023,12,31,23,0,0)];
Variable_GDAS = {'lat'; 'lon';'height'; 'pressure'; 'theta'; 'temp'; 'rainfall'; 'BLH';
'RH'; 'Specific_humidity'; 'H2O_mixing_ratio'; 'TERR_MSL'; 'DSWF'; 'IsLand'};
traj_path = 'C:\Academic\BT_multiyear';
traj_dir = dir(fullfile(traj_path,'*_200m'));
coast = load('coastlines');

TrajLength = 10; %%% The length of trajectory that will be used to extract the data, unit: day

%% Load all trajectory files
Traj_time = [];
TrajData = {};
for j = 1:length(traj_dir)
    traj_time_tmp = load(fullfile(traj_path,traj_dir(j).name,'Traj_data_extracted'),'Traj_time');
    idx = find(traj_time_tmp.Traj_time(:,7)>=period(1) & traj_time_tmp.Traj_time(:,7)<=period(2));
    if ~isempty(idx)
        Traj_time = [Traj_time;traj_time_tmp.Traj_time(idx,:)];
        traj_data_tmp = load(fullfile(traj_path,traj_dir(j).name,'Traj_data_extracted'),'TrajData');
        TrajData = [TrajData;traj_data_tmp.TrajData(idx)];
    else
    end
end

%% Extract the main variables and obtain flag_Land
TrajNum = length(TrajData);
data_gdas = cell(TrajNum,1);
for k = 1:TrajNum
    Traj = TrajData{k}(1:24*TrajLength+1,:);
    data_gdas{k}(:,1:13) = flipud(Traj(:,10:end));
    flag_land = inpolygon(Traj(:,10),Traj(:,11),coast.coastlat,coast.coastlon);
    data_gdas{k}(:,14) = flipud(flag_land);
end

save('Data_extracted_all_10days','Traj_time','data_gdas','TrajData','Variable_GDAS')
