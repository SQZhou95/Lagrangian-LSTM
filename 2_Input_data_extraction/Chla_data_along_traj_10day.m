% Extract the Chla data along the backward trajectories considering the
% airmass dispersion

dataPath = 'D:\CMEMS\Chla_conc_L4_daily_gap_free'; % Set the path of Chla files
TrajLength = 10; %%% The length of trajectory that will be used to extract the data, unit: day

load('Data_extracted_all_10days','Traj_time','TrajData','data_gdas')
TrajNum = length(TrajData);
data_chla = chla_L4_matchup_with_dispersion(dataPath,TrajData,TrajLength,Traj_time,'CHL');

% Treatment towards NaN values and data assignment: assign 0 for points
% over the continent; for points over small islands in Azores, do
% linear interpolation
num_strategy = size(data_chla{1},2);
for k = 1:TrajNum
    idx_land = (~(data_gdas{k}(:,1)>36 & data_gdas{k}(:,1)<40 & data_gdas{k}(:,2)>-32 & data_gdas{k}(:,2)<-24))...
        & data_gdas{k}(:,14)==1;
    data_chla{k}(idx_land,:) = 0;

    for j = 1:num_strategy
        if isnan(data_chla{k}(1,j))
            data_chla{k}(1,j) = 0;
        end

        if any(isnan(data_chla{k}(:,j)))
            id_NaN = find(isnan(data_chla{k}(:,j)));
            id_valid = [1:24*TrajLength+1]';
            id_valid(id_NaN) = [];
            data_chla{k}(id_NaN,j) = interp1(id_valid,data_chla{k}(id_valid,j),id_NaN);
        else
        end
    end
end

save('chla_data_extracted_all_10days','data_chla','Traj_time')
