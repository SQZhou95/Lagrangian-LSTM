function [Y_best_mean, Stat_best_mean] = stat_cal_best_results(T, index, Y, RMSE_Test, T_bin)
% Y_best_mean: after all MCCV experiments have been conducted, choose the
% first N (1~100) experiments with the lowest RMSE_test and calculate the
% averaged Y_test
% Stat_best_mean: Stat corresponding to Y_best_mean

% Get the number of MCCV experiments
num_MCCV = length(index.Train);

% Get the number of Test samples
num_Test = length(index.Test);

% Initiate the output
Y_best_mean.Test = NaN(num_Test,num_MCCV);
Stat_best_mean.RMSE_Test = NaN(num_MCCV,1);
Stat_best_mean.R2_Test = NaN(num_MCCV,1);
Stat_best_mean.Slope_Test = NaN(num_MCCV,1);
bin_length = length(T_bin)-1;
Stat_best_mean.RMSE_Test_bin = NaN(num_MCCV,bin_length);

% Get the rank ID of RMSE.Test
[~,idx] = sort(RMSE_Test);

% Calculate
TTest = T(index.Test);
YTest = Y.Test;
for i = 1:num_MCCV
    Y_tmp = mean(YTest(:,idx(1:i)),2);
    Y_best_mean.Test(:,i) = Y_tmp;

    Stat_best_mean.RMSE_Test(i) = sqrt(sum((TTest-Y_tmp).^2)/length(TTest));
    Stat_best_mean.R2_Test(i) = corr(TTest,Y_tmp,'type','pearson')^2;
    fit_tmp = polyfit(TTest,Y_tmp,1);
    Stat_best_mean.Slope_Test(i) = fit_tmp(1);

    % RMSE at different CCN concentration ranges
    for j = 1:bin_length
        idx_tmp = TTest>=T_bin(j) & TTest<T_bin(j+1);

        Stat_best_mean.RMSE_Test_bin (i,j) = sqrt(sum((TTest(idx_tmp)-Y_tmp(idx_tmp)).^2)/sum(idx_tmp));
    end
end
