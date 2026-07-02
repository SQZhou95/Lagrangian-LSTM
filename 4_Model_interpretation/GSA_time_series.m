% This script is to investigate the feature importance of each specific
% time step along the trajectory for each variable 

%% Data preparation
load('X_converted.mat')
load('Train_resampled.mat','netSet') % netSet the obtained LSTM ensemble

numData = length(X);
numVar = length(var_name.new);
TM_length = size(X{1},2);

%% Get initial output time series
y_X = mymodel_LSTM(X,netSet); % Initial output CCN time series
idx_rand = randperm(numData);
Z = X(idx_rand);
y_Z = mymodel_LSTM(Z,netSet);

%% Do treatment and get the metrics for the impact on output
y_treatment = cell(1,numVar);
v_treatment = cell(1,numVar); % Mean squared deviation between initial and new outputs
R2drop_treatment = cell(1,numVar); % 1 minus the R2 between initial and new outputs

id_var_OL = [20:22]; % Three surface parameters of which the value ranges depend on whether the point is over land or over ocean: Chla, DMS, SO2EM
var_limit = {[-Inf 0; Inf 0], [-Inf 0; Inf 0], [-Inf -Inf; 0.011 Inf]};

%
for i = 1:numVar
    y_treatment{i} = NaN(numData,TM_length);
    v_treatment{i} = NaN(1,TM_length);
    R2drop_treatment{i} = NaN(1,TM_length);
    for t = 1:TM_length
        X_treatment = X;

        if ismember(i,id_var_OL)
            % For those three special surface parameters, if an unrealistic
            % combination with flag_Land occurs after treatment, use the
            % original untreated value

            [~,idx_OL] = ismember(i,id_var_OL);
            for j = 1:numData
                isLand_Z = Z{j}(2,t);
                isLand_X = X{j}(2,t);
                data_Z = Z{j}(i,t);
                data_X = X{j}(i,t);

                X_treatment{j}(i,t) = Z{j}(i,t);

                for k = 1:2
                    if isLand_X == k-1 && isLand_Z ~= k-1 && data_Z<=var_limit{idx_OL}(1,k)
                        X_treatment{j}(i,t) = data_X;
                    elseif isLand_X == k-1 && isLand_Z ~= k-1 && data_Z>=var_limit{idx_OL}(2,k)
                        X_treatment{j}(i,t) = data_X;
                    end
                end
            end
        else

            for j = 1:numData
                X_treatment{j}(i,t) = Z{j}(i,t);
            end
        end

        % Calculate the outputs corresponding to treated input data
        y_treatment{i}(:,t) = mymodel_LSTM(X_treatment,netSet);
        v_treatment{i}(t) = mean((y_X - y_treatment{i}(:,t)).^2);
        R2drop_treatment{i}(t) = 1-corr(y_X,y_treatment{i}(:,t))^2;

        disp(['Variable ',num2str(i),', Treatment ',num2str(t),' is finished. ',datestr(now)])
        disp(['v_treatment is ',num2str(v_treatment{i}(t)),'.'])

        if mod(t,20) == 0 || t == TM_length
            save('GSA_time_series_shuffle_tmp','y_treatment','v_treatment','R2drop_treatment','y_X','y_Z')
        end
    end
end

save('GSA_time_series_shuffle.mat','y_treatment','v_treatment','R2drop_treatment','y_X','y_Z','idx_rand','Traj_time','var_name')
