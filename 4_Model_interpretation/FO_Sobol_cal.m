function [FO_Sobol, idx_rand, y_X, y_Z, y_XZ1, y_XZ2] = FO_Sobol_cal(X,netSet,Variables,varargin)
id_var_OL = [20:22]; % Three surface parameters of which the value ranges depend on whether the point is over land or over ocean: Chla, DMS, SO2EM
var_limit = {[-Inf 0; Inf 0], [-Inf 0; Inf 0], [-Inf -Inf; 0.011 Inf]};

numData = length(X);
numVar = length(Variables);
FO_Sobol = NaN(2,numVar);

idx_rand = randperm(numData);
Z = X(idx_rand);
y_X = mymodel_LSTM(X,netSet);
y_Z = mymodel_LSTM(Z,netSet);
Vy = var([y_X; y_Z]);
c = mean([y_X; y_Z]);

y_XZ1 = NaN(numData,numVar);
y_XZ2 = NaN(numData,numVar);
for i = 1:numVar
    XZ1 = Z;
    XZ2 = X;
    if ismember(i,id_var_OL)
        % For those three special surface parameters, if an unrealistic
        % combination with flag_Land occurs after treatment, use the
        % original untreated value

        [~,idx_OL] = ismember(i,id_var_OL);
        for j = 1:numData
            isLand_Z = Z{j}(2,:);
            isLand_X = X{j}(2,:);
            data_Z = Z{j}(i,:);
            data_X = X{j}(i,:);

            XZ1{j}(i,:) = X{j}(i,:);
            XZ2{j}(i,:) = Z{j}(i,:);

            for k = 1:2
                idx_kZ_low = find(isLand_Z == k-1 & isLand_X ~= k-1 & data_X<=var_limit{idx_OL}(1,k));
                XZ1{j}(i,idx_kZ_low) = data_Z(idx_kZ_low); % use the initial value
%                 XZ1{j}(i,idx_kZ_low) = var_limit{idx_OL}(1,k); % use the limit bound

                idx_kZ_high = find(isLand_Z == k-1 & isLand_X ~= k-1 & data_X>=var_limit{idx_OL}(2,k));
                XZ1{j}(i,idx_kZ_high) = data_Z(idx_kZ_high); % use the initial value
%                 XZ1{j}(i,idx_kZ_high) = var_limit{idx_OL}(2,k); % use the limit bound

                idx_kX_low = find(isLand_X == k-1 & isLand_Z ~= k-1 & data_Z<=var_limit{idx_OL}(1,k));
                XZ2{j}(i,idx_kX_low) = data_X(idx_kX_low); % use the initial value
%                 XZ2{j}(i,idx_kX_low) = var_limit{idx_OL}(1,k); % use the limit bound

                idx_kX_high = find(isLand_X == k-1 & isLand_Z ~= k-1 & data_Z>=var_limit{idx_OL}(2,k));
                XZ2{j}(i,idx_kX_high) = data_X(idx_kX_high); % use the initial value
%                 XZ2{j}(i,idx_kX_high) = var_limit{idx_OL}(2,k); % use the limit bound
            end
        end
    else

        for j = 1:numData
            XZ1{j}(i,:) = X{j}(i,:);
            XZ2{j}(i,:) = Z{j}(i,:);
        end
    end

    y_XZ1(:,i) = mymodel_LSTM(XZ1,netSet);
    y_XZ2(:,i) = mymodel_LSTM(XZ2,netSet);

    V_i1 = mean((y_X - c).*(y_XZ1(:,i) - y_Z));
    V_i2 = mean((y_Z - c).*(y_XZ2(:,i) - y_X));
    FO_Sobol(:,i) = [V_i1;V_i2]/ Vy;
    if isempty(varargin)
        display([num2str(i), ' out of ', num2str(numVar), ' indices finished - ',Variables{i},': ', num2str(FO_Sobol(:,i)')]);
    else
        display(['Month ', num2str(varargin{1}),', ',num2str(i), ' out of ', num2str(numVar), ' indices finished - ',Variables{i},': ', num2str(FO_Sobol(:,i)')]);
    end
end

