function [idx_Train,idx_Validation] = train_validation_split(time,idx_Test,para_split,T)
% para_split.block_size = 'daily';   % 'hourly','daily','weekly','monthly'; Block size for train-validation data split
% para_split.f_validation = 0.15;       % Validation fraction
% para_split.num_MCCV = 10;             % Number of MCCV (training times)
% para_split.w_method = 'Burr';         % distribution for weighted bootstrap; 'Burr','normal','none'
% para_split.w_adj = 1.3;               % the adjusting factor for pdf from w_method to derive the weighting factor
% para_split.num_resampling = 20000;    % Number of samples in bootstrapping 
%
% In time: Column 1-7: year, month, day, hour, minute, second, datenum
% idx_Test: idx of Test set in raw data series
% T: Target values

idx_nonTest = setdiff([1:size(time,1)]',idx_Test); % idx of non-Test data in raw data series

% Remove Test set
time(idx_Test,:) = [];
num_data = size(time,1);


% Get the idx series for split corresponding to different block sizes
switch para_split.block_size
    case 'hourly'
        id_block_raw = round((time(:,7)-time(1,7))*24)+1; % raw idx series
    case 'daily'
        id_block_raw = datenum(time(:,1:3))-datenum(time(1,1:3))+1;
    case 'weekly'
        id_block_raw = floor((datenum(time(:,1:3))-datenum(time(1,1:3))+1.1)/7)+1;
    case 'monthly'
        id_block_raw = 12*(time(:,1)-time(1,1))+time(:,2);
    otherwise
        error('Check para_split.block_size! It must be one of the following: hourly, daily, weekly, monthly.')
end
id_block_unique = unique(id_block_raw); % unique values in idx_block_raw


% Get weighting factor if para_split.alpha>0
if strcmp(para_split.w_method,'Burr')
    W_tmp = get_w_Burr(T,para_split.w_adj);
    W = W_tmp(idx_nonTest);
elseif strcmp(para_split.w_method,'normal')
    pd = fitdist(T,'Normal');
    W_tmp = 1./normpdf(T, pd.mu, para_split.w_adj*pd.sigma); % weighting factor for weighted bootstrap
    W = W_tmp(idx_nonTest);
end

% Data split
idx_Train = cell(para_split.num_MCCV,1);
idx_Validation = cell(para_split.num_MCCV,1);

for i = 1:para_split.num_MCCV
    % Creat the new idx corresponding to raw time resolution if resampling
    % and id_block (both corresponding to the series after removing Test)
    if ~strcmp(para_split.w_method,'none')
        idx_series_raw_or_resample = randsample([1:num_data]', para_split.num_resampling, true, W);
        id_block_raw_or_resample = id_block_raw(idx_series_raw_or_resample);
    else
        idx_series_raw_or_resample = [1:num_data]';
        id_block_raw_or_resample = id_block_raw;
    end

    % Number of Validation blocks
    num_block_validation = round(para_split.f_validation*length(id_block_unique));

    % id of Validation blocks
    id_block_validation = randsample(id_block_unique,num_block_validation);

    % Get the id_series of Validation and Train samples in id_block_raw_or_resample
    idx_series_validation = idx_series_raw_or_resample(ismember(id_block_raw_or_resample, id_block_validation));
    idx_series_train = idx_series_raw_or_resample(~ismember(id_block_raw_or_resample, id_block_validation));

    % Assign the final idx for Validation and Train samples
    idx_Validation{i} = idx_nonTest(idx_series_validation);
    idx_Train{i} = idx_nonTest(idx_series_train);
end