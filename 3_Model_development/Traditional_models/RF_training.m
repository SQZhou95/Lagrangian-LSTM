%% Load data for training
load('data_for_traditional_ML.mat','X','T','time_valid')

% T is the target variable, i.e., log(NCCN).
% X is the input dataset. It can be the last time step on the trajectory or
% trajectory average (weighted or non-weighted).


%% Data split
index.Test = find(time_valid(:,1)==2022 & ismember(time_valid(:,2),[1 3 5 7 9 11]));

para_split.block_size = 'daily'; % 'hourly','daily','weekly','monthly'; Block size for train-validation data split
para_split.f_validation = 0.15; % Validation fraction
para_split.num_MCCV = 10; % Number of MCCV (training times)
para_split.w_method = 'none'; % distribution for weighted bootstrap; 'Burr','normal','none'
para_split.w_adj = 0; % the adjusting factor for pdf from w_method to derive the weighting factor

[index.Train,index.Validation] = train_validation_split(time_valid,index.Test,para_split,T);


%% Set hyperparameters for RF
para.NumLearningCycles = 20;
para.MinLeafSize = 10;

save('RF_training.mat','X','T','time_valid','index','para')

%% Training

[Mdl,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_RF(X,T,index, para.NumLearningCycles, para.MinLeafSize, num_try);
RF.results = struct( ...
    'Y', Y, ...
    'Y_mean', Y_mean, ...
    'Y_best_mean', Y_best_mean, ...
    'Stat', Stat, ...
    'Stat_Y_mean', Stat_Y_mean, ...
    'Stat_best_mean', Stat_best_mean);

[~,idx_sort] = sort(Stat.RMSE.Test);
RF.bestResults = struct( ...
    'Mdl',{Mdl.tree(idx_sort(1:10))}, ...
    'RMSE_Test', Stat_best_mean.RMSE.Test(10), ...
    'R2_Test', Stat_best_mean.R2.Test(10), ...
    'Slope_Test', Stat_best_mean.Slope.Test(10));

disp('The Stat_best_mean is: ')
disp(RF.bestResults)


save('RF_training.mat','RF','-append')

