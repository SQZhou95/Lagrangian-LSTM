function [Y_mean,Y_best_mean,Stat_Y_mean,Stat_best_mean] = stat_cal_mean(T_Test,Y,idx_RMSE_Test)

num_try = size(Y.Test,2);

Y_mean.Test = NaN(size(Y.Test));
Stat_Y_mean.RMSE.Test = NaN(num_try,1);
Stat_Y_mean.R2.Test = NaN(num_try,1);
Stat_Y_mean.Slope.Test = NaN(num_try,1);

for i = 1:num_try
    Y_Test_tmp = mean(Y.Test(:,1:i),2);

    Y_mean.Test(:,i) = Y_Test_tmp;
    Stat_Y_mean.RMSE.Test(i) = rmse(T_Test,Y_Test_tmp);
    Stat_Y_mean.R2.Test(i) = corr(T_Test,Y_Test_tmp)^2;

    fit_Test = polyfit(T_Test,Y_Test_tmp,1);
    Stat_Y_mean.Slope.Test(i) = fit_Test(1);
end



Y_best_mean.Test = NaN(size(Y.Test));
Stat_best_mean.RMSE.Test = NaN(num_try,1);
Stat_best_mean.R2.Test = NaN(num_try,1);
Stat_best_mean.Slope.Test = NaN(num_try,1);

for i = 1:num_try
    Y_Test_tmp = mean(Y.Test(:,idx_RMSE_Test(1:i)),2);

    Y_best_mean.Test(:,i) = Y_Test_tmp;
    Stat_best_mean.RMSE.Test(i) = rmse(T_Test,Y_Test_tmp);
    Stat_best_mean.R2.Test(i) = corr(T_Test,Y_Test_tmp)^2;

    fit_Test = polyfit(T_Test,Y_Test_tmp,1);
    Stat_best_mean.Slope.Test(i) = fit_Test(1);
end


