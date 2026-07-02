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


%% Set hyperparameters for ANN
para.layer_sizes = 10;
para.lambda = 1e-4;
para.validation_patience = 20;

save('ANN_training.mat','T','time_valid','X','index','para','-v7.3')

%% Initiate the training results

ANN.results = [];
ANN.stat_best_mean = [];


% Initialize variables to store the best hyperparameters
bestResults = struct();
bestRMSE_test = Inf;


[netSet,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_ANN(X,T,index, para.layer_sizes, para.lambda, para.validation_patience);
ANN.results = [ANN.results; struct( ...
    'Y', Y, ...
    'Y_mean', Y_mean, ...
    'Y_best_mean', Y_best_mean, ...
    'Stat', Stat, ...
    'Stat_Y_mean', Stat_Y_mean, ...
    'Stat_best_mean', Stat_best_mean)];

if Stat_best_mean.RMSE.Test(10) < bestRMSE_test
    bestRMSE_test = Stat_best_mean.RMSE.Test(10);
    bestResults = struct( ...
        'RMSE_Test', Stat_best_mean.RMSE.Test(10), ...
        'R2_Test', Stat_best_mean.R2.Test(10), ...
        'Slope_Test', Stat_best_mean.Slope.Test(10));
end

disp('The Stat_best_mean: ')
disp(struct2table(bestResults))

ANN.bestResults = bestResults;

save('ANN_training.mat','ANN','-append')

