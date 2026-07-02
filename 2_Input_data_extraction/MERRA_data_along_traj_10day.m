% Extract the MERRA-2 data along the trajectories. Following are a few examples for differernt variable types.
% You can add more variables you want.

load('Data_extracted_all_10days','Traj_time','TrajData') % Load the organized trajectory data
TrajLength = 10; %%% The length of trajectory that will be used to extract the data, unit: day

%% tavg1_2d_slv_Nx: PS, TQL, TS
dataPath = 'E:\MERRA_2\tavg1_2d_slv_Nx'; % Set your MERRA-2 data path
 
data_2d_slv_Nx.PS = merra_matchup_2d_regular(dataPath,TrajData,TrajLength,Traj_time,'PS');
data_2d_slv_Nx.TQL = merra_matchup_2d_regular(dataPath,TrajData,TrajLength,Traj_time,'TQL');
data_2d_slv_Nx.TS = merra_matchup_2d_regular(dataPath,TrajData,TrajLength,Traj_time,'TS');

save('MERRA_extracted_all_10days','data_2d_slv_Nx')
clear data_2d_slv_Nx


%% inst3_3d_aer_Nv: DU001
dataPath = 'E:\MERRA_2\inst3_3d_aer_Nv';
Start_time = 0; % 0 for 3-hourly instantaneous 3-D fields; 1.5 for 3-hourly average 3-D fields

data_3d_aer_Nv.DU001 = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'DU001',Start_time);

for j = 1:size(Traj_time,1)
    data_3d_aer_Nv.DU001{j}(data_3d_aer_Nv.DU001{j}<0) = 0;
end

save('MERRA_extracted_all_10days','data_3d_aer_Nv','-append')
clear data_3d_aer_Nv

%% tavg3_3d_asm_Nv: OMEGA, QL, QV, RH, T
dataPath = 'E:\MERRA_2\tavg3_3d_asm_Nv';
Start_time = 1.5;

data_3d_asm_Nv.OMEGA = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'OMEGA',Start_time);
data_3d_asm_Nv.QL = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'QL',Start_time);
data_3d_asm_Nv.QV = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'QV',Start_time);
data_3d_asm_Nv.RH = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'RH',Start_time);
data_3d_asm_Nv.T = merra_matchup_3d_Nv(dataPath,TrajData,TrajLength,Traj_time,'T',Start_time);

for j = 1:size(Traj_time,1)
    data_3d_asm_Nv.QL{j}(data_3d_asm_Nv.QL{j}<0) = 0;
    data_3d_asm_Nv.QV{j}(data_3d_asm_Nv.QV{j}<0) = 0;
    data_3d_asm_Nv.RH{j}(data_3d_asm_Nv.RH{j}<0) = 0;
    data_3d_asm_Nv.RH{j}(data_3d_asm_Nv.RH{j}>1) = 1;
end

save('MERRA_extracted_all_10days','data_3d_asm_Nv','-append')
clear data_3d_asm_Nv

%% tavg3_3d_asm_Nv-fixed_level: T_700hPa
dataPath = 'E:\MERRA_2\tavg3_3d_asm_Nv';
Start_time = 1.5;

% Temperature at a single fixed level: 700 hPa
FieldName = 'T';
fixed_pressure = 700;
data_3d_asm_Nv.T700 = merra_matchup_3d_Nv_fixed_level(dataPath,TrajData,TrajLength,Traj_time,FieldName,Start_time,fixed_pressure);
% Attention: there are some NaNs in T700_traj. Complement by interpolation
for j = 1:size(Traj_time,1)
    if any(isnan(data_3d_asm_Nv.T700{j}))
        id_NaN = find(isnan(data_3d_asm_Nv.T700{j}));
        id_valid = [1:24*TrajLength+1]';
        id_valid(id_NaN) = [];
        data_3d_asm_Nv.T700{j}(id_NaN) = interp1(id_valid,data_3d_asm_Nv.T700{j}(id_valid),id_NaN);
    else
    end
end

save('MERRA_extracted_all_10days','data_3d_asm_Nv','-append')
clear data_3d_asm_Nv


