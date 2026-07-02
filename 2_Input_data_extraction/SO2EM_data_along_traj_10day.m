% Extract the SO2 emission data along backward trajectories considering
% airmass dispersion

load('Data_extracted_all_10days','Traj_time','TrajData','data_gdas') % Load the organized trajectory data
TrajLength = 10; %%% The length of trajectory that will be used to extract the data, unit: day


%% New SO2 emission and using new data matching methods
EmissionPath = 'E:\Emission_Inventory\ECCAD';

data_SO2EM = emission_extract(EmissionPath,TrajLength,TrajData,Traj_time);

save('SO2EM_data_extracted_all_10days','data_SO2EM','Traj_time')

