% load the data
load('X_converted.mat')
load('Train_resampled.mat','netSet') % netSet the obtained LSTM ensemble

Input = X;
numVar = length(var_name.new);


%% Processing with Month_ID
month_ID = (Traj_time(:,1)-2013)*12+Traj_time(:,2);
stat_month_ID = tabulate(month_ID);
stat_month_ID(stat_month_ID(:,2)<672,:) = [];

num_month = size(stat_month_ID,1);
length_month = 28*24;
num_sample = length_month*num_month;

num_try = 20; % how many times the treatment and evaluation are
idx.X = NaN(num_sample,num_try);
idx.Z = NaN(num_sample,num_try);
idx.X_shuffle = NaN(num_sample,num_try);
idx.Z_shuffle = NaN(num_sample,num_try);

for t = 1:num_try
    month_ID_series = stat_month_ID(randperm(num_month),1);
    [idx.X(:,t),idx.X_shuffle(:,t)] = get_sequence(month_ID,month_ID_series,length_month);

    month_ID_series = stat_month_ID(randperm(num_month),1);
    [idx.Z(:,t),idx.Z_shuffle(:,t)] = get_sequence(month_ID,month_ID_series,length_month);
end

save('GSA_for_monthly_variation_results.mat','var_name','Traj_time','month_ID','idx','stat_month_ID','num_try','-v7.3')


%% Run the model with perturbed input and calculate the Sobol indices for monthly variations
% FO_Sobol_month is the Sobol indice (i.e., feature importance) for monthly variations
% y and y_month are the hourly outputs and their corresponding monthly
% averages, respectively

tmp_name = 'GSA_for_monthly_variation_results_tmp';
[y, y_month, FO_Sobol_month] = FO_Sobol_month_cal(Input, idx.X, idx.Z, length_month, var_name.new, netSet,tmp_name);

save('GSA_for_monthly_variation_results.mat','y','y_month','FO_Sobol_month','-append')



function [idx, idx_shuffle] = get_sequence(month_ID,month_ID_series,length_month)
idx = NaN(length(month_ID_series)*length_month,1);
idx_shuffle = idx;

for i = 1:length(month_ID_series)
    idx_tmp = find(month_ID==month_ID_series(i));
    num_remove = length(idx_tmp)-length_month;
    id_remove = randperm(length(idx_tmp),num_remove);

    idx_select = idx_tmp;
    idx_select(id_remove) = [];

    idx_select_shuffle = idx_select(randperm(length_month));

    idx((i-1)*length_month+1:i*length_month) = idx_select;
    idx_shuffle((i-1)*length_month+1:i*length_month) = idx_select_shuffle;
end
end


function [y, y_month, FO_Sobol_month] = FO_Sobol_month_cal(Input, idx_X, idx_Z, length_month, Variables, netSet,tmp_name)
numData = size(idx_X,1);
numVar = length(Variables);
numTry = size(idx_X,2);
numMonth = numData/length_month;

y.X = NaN(numData,numTry);
y.Z = NaN(numData,numTry);
y.XZ1 = NaN(numData,numVar,numTry);
y.XZ2 = NaN(numData,numVar,numTry);

y_month.X = NaN(numMonth,numTry);
y_month.Z = NaN(numMonth,numTry);
y_month.XZ1 = NaN(numMonth,numVar,numTry);
y_month.XZ2 = NaN(numMonth,numVar,numTry);


FO_Sobol_month = NaN(2,numVar,numTry);

for t = 18:numTry
    X = Input(idx_X(:,t));
    Z = Input(idx_Z(:,t));

    y.X(:,t) = mymodel_LSTM(X,netSet);
    y.Z(:,t) = mymodel_LSTM(Z,netSet);

    y_month.X(:,t) = mean(reshape(y.X(:,t),length_month,[]),1);
    y_month.Z(:,t) = mean(reshape(y.Z(:,t),length_month,[]),1);

    Vy = var([y_month.X(:,t);y_month.Z(:,t)]);
    c = mean([y_month.X(:,t);y_month.Z(:,t)]);

    for i = 1:numVar
        XZ1 = Z;
        XZ2 = X;
        for j = 1:numData
            XZ1{j}(i,:) = X{j}(i,:);
            XZ2{j}(i,:) = Z{j}(i,:);
        end

        y.XZ1(:,i,t) = mymodel_LSTM(XZ1,netSet);
        y.XZ2(:,i,t) = mymodel_LSTM(XZ2,netSet);

        y_month.XZ1(:,i,t) = mean(reshape(y.XZ1(:,i,t),length_month,[]),1);
        y_month.XZ2(:,i,t) = mean(reshape(y.XZ2(:,i,t),length_month,[]),1);


        V_i1 = mean((y_month.X(:,t) - c).*(y_month.XZ1(:,i,t) - y_month.Z(:,t)));
        V_i2 = mean((y_month.Z(:,t) - c).*(y_month.XZ2(:,i,t) - y_month.X(:,t)));
        FO_Sobol_month(:,i,t) = [V_i1;V_i2]/ Vy;

        display([num2str(t), ' out of Try ', num2str(numTry), ', ', num2str(i), ' out of Variables ', num2str(numVar), ' indices finished - ',Variables{i},': ', num2str(FO_Sobol_month(:,i,t)')]);
    end
    save(tmp_name,'y', 'y_month', 'FO_Sobol_month')
end
end
