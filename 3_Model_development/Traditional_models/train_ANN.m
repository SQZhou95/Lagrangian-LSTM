function [netSet,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_ANN(X,T,index, layer_sizes, lambda, validation_patience)
num_try = length(index.Train);
num_Test = length(index.Test);

% Initiate the outputs
netSet.net = cell(num_try,1);
Y.Test = NaN(num_Test,num_try);

Stat.RMSE.Train = NaN(num_try,1);
Stat.RMSE.Validation = NaN(num_try,1);
Stat.RMSE.Test = NaN(num_try,1);
Stat.R2.Train = NaN(num_try,1);
Stat.R2.Validation = NaN(num_try,1);
Stat.R2.Test = NaN(num_try,1);
Stat.Slope.Train = NaN(num_try,1);
Stat.Slope.Validation = NaN(num_try,1);
Stat.Slope.Test = NaN(num_try,1);

idx_Test = index.Test;
X_Test = X(idx_Test,:);
T_Test = T(idx_Test);
for i = 1:num_try
    % Get idx
    idx_Train = index.Train{i};
    idx_Validation = index.Validation{i};

    % Prepare the data for training
    X_Train = X(idx_Train,:);
    X_Validation = X(idx_Validation,:);

    T_Train = T(idx_Train);
    T_Validation = T(idx_Validation);
    

    % Train the ANN model
    net = fitrnet(X_Train,T_Train,'LayerSizes',layer_sizes,"ValidationData",{X_Validation, T_Validation},...
        "ValidationFrequency",1,"Lambda",lambda,"Verbose",0, "Standardize",1,...
        "LossTolerance",1e-8,"StepTolerance",1e-8,"ValidationPatience",validation_patience);

    % Get Y
    Y_Train = predict(net,X_Train);
    Y_Validation = predict(net,X_Validation);
    Y_Test = predict(net,X_Test);

    % Assign outputs
    netSet.net{i} = net;
    Y.Test(:,i) = Y_Test;

    % Calculate statistics
    Stat.RMSE.Train(i) = rmse(T_Train,Y_Train);
    Stat.RMSE.Validation(i) = rmse(T_Validation,Y_Validation);
    Stat.RMSE.Test(i) = rmse(T_Test,Y_Test);
    Stat.R2.Train(i) = corr(T_Train,Y_Train)^2;
    Stat.R2.Validation(i) = corr(T_Validation,Y_Validation)^2;
    Stat.R2.Test(i) = corr(T_Test,Y_Test)^2;
    
    fit_Train = polyfit(T_Train,Y_Train,1);
    Stat.Slope.Train(i) = fit_Train(1);
    fit_Validation = polyfit(T_Validation,Y_Validation,1);
    Stat.Slope.Validation(i) = fit_Validation(1);
    fit_Test = polyfit(T_Test,Y_Test,1);
    Stat.Slope.Test(i) = fit_Test(1);

    disp(['layer size: ',num2str(layer_sizes),', lambda: ',num2str(lambda),', validation patience: ',num2str(validation_patience)])
    disp(['training_',num2str(i),' has been completed. ',datestr(now)])
    disp(['RMSE_Test = ', num2str(Stat.RMSE.Test(i)),', R2_Test = ',num2str(Stat.R2.Test(i)),', Slope_Test = ',num2str(Stat.Slope.Test(i))])

end

% Derive Y_mean, Y_best_mean, and corresponding statistics for Test and BB
[~,idx_tmp] = sort(Stat.RMSE.Test);
[Y_mean,Y_best_mean,Stat_Y_mean,Stat_best_mean] = stat_cal_mean(T_Test,Y,idx_tmp);


