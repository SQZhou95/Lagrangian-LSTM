% Extract the sea-surface DMS concentration data along the trajectories

load('Data_extracted_all_10days','Traj_time','TrajData') % Load the organized trajectory data
TrajLength = 10; %%% The length of trajectory that will be used to extract the data, unit: day

%% Read DMS data across all years
dataPath = 'E:\Sea_surface_DMS';
DMSconc_daily = []; % sea-surface DMS concentration
SI_daily = []; % sea-ice fraction
Date_daily = [];

for y = 2013:2023
    load(fullfile(dataPath,['DMS_pred_',num2str(y),'.mat']),'DMS_pred','SI','Date','grid')
    DMSconc_daily = [DMSconc_daily DMS_pred];
    SI_daily = [SI_daily SI];
    Date_daily = [Date_daily; Date];
end

% Assign DMSconc as 0 for NaN values with SI>0.5
DMSconc_daily(isnan(DMSconc_daily) & SI_daily>0.5) = 0;


%% Data matchup and extraction
Trajnum = length(TrajData);
idx_Traj = floor(Traj_time(:,7)-Date_daily(1))+1; % Traj's idx in Date_daily column
data_DMS_conc = cell(Trajnum,1);
h = waitbar(0,'Data extraction in process. Please wait ...');
for j = 1:Trajnum
    Traj = TrajData{j};
    Traj = Traj(1:24*TrajLength+1,:);

    DMSconc_temp = DMSconc_daily(:,idx_Traj(j)-TrajLength:idx_Traj(j)); % data matchup and extraction

    data_DMS_conc{j} = flipud(DMS_matchup_daily(Traj,Traj_time(j,7),DMSconc_temp,grid));
    data_DMS_conc{j}(data_gdas{j}(:,14)==1) = 0;

    % Treatment towards NaN values. You may need to adjust it according to
    % your location.
    if isnan(data_DMS_conc{j}(1)) 
        data_DMS_conc{j}(1) = 0;
    end
    if any(isnan(data_DMS_conc{j}))
        id_NaN = find(isnan(data_DMS_conc{j}));
        id_valid = [1:24*TrajLength+1]';
        id_valid(id_NaN) = [];
        data_DMS_conc{j}(id_NaN) = interp1(id_valid,data_DMS_conc{j}(id_valid),id_NaN,'linear','extrap');
    else
    end

    % Treatment towards zero values near the ENA site
    id_zero = find(data_DMS_conc{j}==0 & data_gdas{j}(:,1)>36 & data_gdas{j}(:,1)<40 ...
        & data_gdas{j}(:,2)>-32 & data_gdas{j}(:,2)<-24);
    if ~isempty(id_zero)
        id_valid = [1:24*TrajLength+1]';
        id_valid(id_zero) = [];
        data_DMS_conc{j}(id_zero) = interp1(id_valid,data_DMS_conc{j}(id_valid),id_zero,'linear','extrap');
    else
    end

    waitbar(j/Trajnum)
end
close(h)

save('DMS_extracted_all_10days','data_DMS_conc')
clear DMSconc_daily SI_daily

