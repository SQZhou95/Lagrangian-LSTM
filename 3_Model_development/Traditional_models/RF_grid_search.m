% Grid search for hyperparameters of RF

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


%% Set hyperparameters for Grid_CV of RF
grid_search.NumLearningCycles = [10 20 50 100 200 500];
% grid_search.LearnRate = [0.01 0.1 1]; %%% LearnRate not applicable for Bag
grid_search.MinLeafSize = [1 10 100 1000 10000];

save('RF_grid_search.mat','X','T','time_valid','index','grid_search','-v7.3')

%% Initiate the training results

RF.results = [];
RF.stat_best_mean = [];


% Initialize variables to store the best hyperparameters
bestModel = struct();
bestRMSE_test = Inf;

num_try = 1; % number of training times for each hyperparameter combination
for i = 1:length(grid_search.NumLearningCycles)
    NumLearningCycles = grid_search.NumLearningCycles(i);

    for j = 1:length(grid_search.MinLeafSize)
        MinLeafSize = grid_search.MinLeafSize(j);

        [Mdl,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_RF(X,T,index, NumLearningCycles, MinLeafSize, num_try);
        RF.results = [RF.results; struct( ...
            'NumLearningCycles', NumLearningCycles, ...
            'MinLeafSize', MinLeafSize, ...
            'Y', Y, ...
            'Y_mean', Y_mean, ...
            'Y_best_mean', Y_best_mean, ...
            'Stat', Stat, ...
            'Stat_Y_mean', Stat_Y_mean, ...
            'Stat_best_mean', Stat_best_mean)];

        RF.stat_best_mean = [RF.stat_best_mean; struct( ...
            'NumLearningCycles', NumLearningCycles, ...
            'MinLeafSize', MinLeafSize, ...
            'RMSE_Test', Stat_best_mean.RMSE.Test(1), ...
            'R2_Test', Stat_best_mean.R2.Test(1), ...
            'Slope_Test', Stat_best_mean.Slope.Test(1))];

        if Stat_best_mean.RMSE.Test(1) < bestRMSE_test
            bestRMSE_test = Stat_best_mean.RMSE.Test(1);
            bestModel = struct( ...
                'NumLearningCycles', NumLearningCycles, ...
                'MinLeafSize', MinLeafSize, ...
                'treeEnsemble', Mdl, ...
                'RMSE_Test', Stat_best_mean.RMSE.Test(1), ...
                'R2_Test', Stat_best_mean.R2.Test(1), ...
                'Slope_Test', Stat_best_mean.Slope.Test(1));
        end

        disp(struct2table(RF.stat_best_mean))
        disp('The best hyperparameters and corresponding Stat_best_mean: ')
        disp(struct2table(bestModel))
    end
end

save('RF_grid_search.mat','RF','bestModel','-append')

