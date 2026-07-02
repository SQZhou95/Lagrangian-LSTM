function [Mdl,Y,Y_mean,Y_best_mean,Stat,Stat_Y_mean,Stat_best_mean] = train_RF(X,T,index, NumLearningCycles, MinLeafSize, num_try)
num_Test = length(index.Test);

% Initiate the outputs
Mdl.tree = cell(num_try,1);
Y.Test = NaN(num_Test,num_try);

Stat.RMSE.Train_Validation = NaN(num_try,1);
Stat.RMSE.Test = NaN(num_try,1);
Stat.R2.Train_Validation = NaN(num_try,1);
Stat.R2.Test = NaN(num_try,1);
Stat.Slope.Train_Validation = NaN(num_try,1);
Stat.Slope.Test = NaN(num_try,1);

X_Test = X(index.Test,:);
T_Test = T(index.Test);
X_Train_Validation = X(index.Train_validation,:);
T_Train_Validation = T(index.Train_validation);

for i = 1:num_try  
    % Train the bagged tree model
    tree = fitrensemble(X_Train_Validation,T_Train_Validation,"Method",'Bag',...
        "NumLearningCycles",NumLearningCycles,"Learners",templateTree("MinLeafSize",MinLeafSize,"NumVariablesToSample","all"));

    % Get Y
    Y_Train_Validation = predict(tree,X_Train_Validation);
    Y_Test = predict(tree,X_Test);

    % Assign outputs
    % Mdl.tree{i} = tree; % Here do not save the model becuase it is too large
    Y.Test(:,i) = Y_Test;

    % Calculate statistics
    Stat.RMSE.Train_Validation(i) = rmse(T_Train_Validation,Y_Train_Validation);
    Stat.RMSE.Test(i) = rmse(T_Test,Y_Test);
    Stat.R2.Train_Validation(i) = corr(T_Train_Validation,Y_Train_Validation)^2;
    Stat.R2.Test(i) = corr(T_Test,Y_Test)^2;
    
    fit_Train_Validation = polyfit(T_Train_Validation,Y_Train_Validation,1);
    Stat.Slope.Train_Validation(i) = fit_Train_Validation(1);
    fit_Test = polyfit(T_Test,Y_Test,1);
    Stat.Slope.Test(i) = fit_Test(1);

    disp(['NumLearningCycles: ',num2str(NumLearningCycles),', MinLeafSize: ',num2str(MinLeafSize)])
    disp(['training_',num2str(i),' has been completed. ',datestr(now)])
    disp(['RMSE_Test = ', num2str(Stat.RMSE.Test(i)),', R2_Test = ',num2str(Stat.R2.Test(i)),', Slope_Test = ',num2str(Stat.Slope.Test(i))])

end

% Derive Y_mean, Y_best_mean, and corresponding statistics for Test and BB
[~,idx_tmp] = sort(Stat.RMSE.Test);
[Y_mean,Y_best_mean,Stat_Y_mean,Stat_best_mean] = stat_cal_mean(T_Test,Y,idx_tmp);


