% Grid search for hyperparameters of single-layer ANN

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


%% Set hyperparameters for Grid_CV of ANN
grid_search.layer_sizes = [10 15 20 30];
grid_search.lambda = [1e-4 2e-4 5e-4 1e-3 2e-3];
grid_search.validation_patience = [20 50];

save('ANN_grid_search.mat','X','T','time_valid','index','grid_search','-v7.3')

%% Initiate the training results
ANN.results = [];
ANN.stat_best_mean = [];


% Initialize variables to store the best hyperparameters
bestModel = struct();
bestRMSE_test = Inf;


for i = 1:length(grid_search.layer_sizes)
    layer_sizes = grid_search.layer_sizes(i);

    for j = 1:length(grid_search.lambda)
        lambda = grid_search.lambda(j);

        for k = 1:length(grid_search.validation_patience)
            validation_patience = grid_search.validation_patience(k);

            [netSet,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_ANN(X,T,index, layer_sizes, lambda, validation_patience);
            ANN.results = [ANN.results; struct( ...
                'LayerSize', layer_sizes, ...
                'Lambda', lambda, ...
                'ValidationPatience', validation_patience, ... % 'netSet', netSet, ...
                'Y', Y, ...
                'Y_mean', Y_mean, ...
                'Y_best_mean', Y_best_mean, ...
                'Stat', Stat, ...
                'Stat_Y_mean', Stat_Y_mean, ...
                'Stat_best_mean', Stat_best_mean)];

            ANN.stat_best_mean = [ANN.stat_best_mean; struct( ...
                'LayerSize', layer_sizes, ...
                'Lambda', lambda, ...
                'ValidationPatience', validation_patience, ...
                'RMSE_Test', Stat_best_mean.RMSE.Test(5), ...
                'R2_Test', Stat_best_mean.R2.Test(5), ...
                'Slope_Test', Stat_best_mean.Slope.Test(5))];

            if Stat_best_mean.RMSE.Test(5) < bestRMSE_test
                bestRMSE_test = Stat_best_mean.RMSE.Test(5);
                bestModel = struct( ...
                    'LayerSize', layer_sizes, ...
                    'Lambda', lambda, ...
                    'ValidationPatience', validation_patience, ...
                    'netSet', netSet, ...
                    'RMSE_Test', Stat_best_mean.RMSE.Test(5), ...
                    'R2_Test', Stat_best_mean.R2.Test(5), ...
                    'Slope_Test', Stat_best_mean.Slope.Test(5));
            end

            disp(struct2table(ANN.stat_best_mean))
            disp('The best hyperparameters and corresponding Stat_best_mean: ')
            disp(struct2table(bestModel))
        end
    end
end

save('ANN_grid_search.mat','ANN','bestModel','-append')

