%% Overall feature importance
%%% Data preparation
load('X_converted.mat')
load('Train_resampled.mat','netSet') % netSet the obtained LSTM ensemble

%%% Global sensitivity analysis (GSA) --> first-order Sobol' Indice
[FO_Sobol, idx_rand, y_X, y_Z, y_XZ1, y_XZ2] = FO_Sobol_cal(X,netSet,var_name.new);

save('Sobol_indice_overall.mat','FO_Sobol','y_X','y_Z','idx_rand','y_XZ1','y_XZ2','Traj_time','var_name')

%% Feature importance for each month
id_month = Traj_time(:,2);

FO_Sobol_monthly = cell(12,1);

idx_rand_monthly = cell(12,1); % col-1: idx of the entire sample for X; col-2: idx for Z
y_X_monthly = cell(12,1);
y_Z_monthly = cell(12,1);
y_XZ1_monthly = cell(12,1);
y_XZ2_monthly = cell(12,1);

for m = 1:12
    idx_tmp_X = find(id_month==m); % the index of month==m in X
    X_tmp = X(idx_tmp_X);
    [FO_Sobol_monthly{m}, idx_rand_tmp, y_X_monthly{m}, y_Z_monthly{m}, y_XZ1_monthly{m}, y_XZ2_monthly{m}] = FO_Sobol_cal(X_tmp,netSet,var_name.new,m);
    idx_rand_monthly{m} = [idx_tmp_X idx_tmp_X(idx_rand_tmp)];
end

save('Sobol_indice_each_month.mat','id_month','*_monthly','Traj_time','var_name')

