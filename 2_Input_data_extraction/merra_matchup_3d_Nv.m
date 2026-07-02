function data_traj = merra_matchup_3d_Nv_new(dataPath,TrajData,TrajLength,Traj_time,FieldName,Start_time)
% Start_time: the start time (hour) in each file. It's 0 for instantaneous,
% but 1.5 for time-averaged files

TrajNum = length(TrajData);
data_traj = cell(TrajNum,1);

Files = dir(fullfile(dataPath,'*.nc*'));
FileNum = length(Files);
yyyy_start = str2double(Files(1).name(28:31));
mm_start = str2double(Files(1).name(32:33));
dd_start = str2double(Files(1).name(34:35));

% lon = ncread(fullfile(dataPath,Files(1).name),'lon');
% lat = ncread(fullfile(dataPath,Files(1).name),'lat');
lev = [192.541000000000	226.513500000000	266.479000000000	312.791500000000...
    356.250000000000	393.750000000000	431.250000000000	468.750000000000...
    506.250000000000	543.750000000000	581.250000000000	618.750000000000...
    656.250000000000	687.500000000000	712.500000000000	737.500000000000...
    762.500000000000	787.500000000000	810	827.500000000000	842.500000000000...
    857.500000000000	872.500000000000	887.500000000000	902.500000000000...
    917.500000000000	932.500000000000	947.500000000000	962.500000000000...
    977.500000000000	992.500000000000]';

% 
data = []; % 13-day raw data for matchup (not 11-day because we should use interpolation for the first or last several hours
Date_start = datenum(yyyy_start,mm_start,dd_start);
h = waitbar(0,'Extracting raw data, Please wait...');
for i = 1:FileNum-(TrajLength+2)

    if isempty(data)
        if Date_start < Traj_time(1,7)-(TrajLength+1)
            Date_start = Date_start+1;
            continue
        else
            for f = i:i+(TrajLength+2)
%                 data = cat(4,data,ncread(fullfile(dataPath,Files(f).name),FieldName));
                data = cat(4,data,ncread(fullfile(dataPath,Files(f).name),FieldName,[1 181 1 1],[Inf Inf Inf Inf]));
            end
        end
    else
        Date_start = Date_start+1;
        if Date_start > floor(Traj_time(end,7))-(TrajLength+1)
            break
        else
%             data = cat(4,data(:,:,:,9:end),ncread(fullfile(dataPath,Files(i+(TrajLength+2)).name),FieldName));
            data = cat(4,data(:,:,:,9:end),ncread(fullfile(dataPath,Files(i+(TrajLength+2)).name),FieldName,[1 181 1 1],[Inf Inf Inf Inf]));
        end
    end

    Date_target = Date_start+(TrajLength+1);
    id = find(Traj_time(:,7)>=Date_target & Traj_time(:,7)<Date_target+1);

    for j = 1:length(id)
        Traj_temp = TrajData{id(j)};
        Traj_temp = Traj_temp(1:24*TrajLength+1,:); % 10-day trajectory
        data_traj{id(j)}(:,1) = flipud(data_matchup(data,lev,TrajLength,Date_start,Traj_temp,Start_time));
    end
    waitbar(i / (FileNum-(TrajLength+2)));
end
close(h)
end

%
function data_point = data_matchup(data,lev,TrajLength,Date_start,Traj,Start_time)
Date_series = (Start_time/24:1/8:(TrajLength+3)+Start_time/24-1/8)'; % date number for original MERRA-2 data relative to Date_start
T0 = datenum(Traj(1,3)+2000,Traj(1,4),Traj(1,5),Traj(1,6),Traj(1,7),0)-Date_start; % date number for the first trajectory point relative to Date_start

Traj_num = size(Traj,1);
data_point = NaN(Traj_num,1);

for k = 1:Traj_num
    X = mod(floor((Traj(k,11)+180.3125)/0.625),576)+1;
%     Y = floor((Traj(k,10)+90.25)/0.5)+1;
    Y = floor((Traj(k,10)+0.25)/0.5)+1;
    P = Traj(k,13);
    T = T0+(1-k)/24;

    data_temp = squeeze(data(X,Y,:,:));
    for j = 1:size(data_temp,2)
        tmp = data_temp(:,j);
        idx_NaN = find(isnan(tmp));
        if ~isempty(idx_NaN)
            idx_valid = find(~isnan(tmp));
            tmp(idx_NaN) = interp1(lev(idx_valid),tmp(idx_valid),lev(idx_NaN),'linear','extrap');
        end
        data_temp(:,j) = tmp;
    end

    data_point(k) = interp1(lev,interp1(Date_series,data_temp',T,'linear'),P,'linear','extrap');
end
end
