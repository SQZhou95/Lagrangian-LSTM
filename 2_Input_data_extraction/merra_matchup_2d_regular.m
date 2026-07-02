function data_traj =  merra_matchup_2d_regular_new(dataPath,TrajData,TrajLength,Traj_time,FieldName)
TrajNum = length(TrajData);
data_traj = cell(TrajNum,1);

Files = dir(fullfile(dataPath,'*.nc'));
FileNum = length(Files);

yyyy_start = str2double(Files(1).name(28:31));
mm_start = str2double(Files(1).name(32:33));
dd_start = str2double(Files(1).name(34:35));

% lon = ncread(fullfile(dataPath,Files(1).name),'lon');
% lat = ncread(fullfile(dataPath,Files(1).name),'lat');
% lev = ncread(fullfile(dataPath,Files(1).name),'lev');
% id_lev = find(lev==fixed_pressure);
% if isempty(id_lev)
%     disp('The input pressure level is not found, please check')
%     return
% end

% 
data = []; % 10-day raw data for matchup
Date_start = datenum(yyyy_start,mm_start,dd_start);
h = waitbar(0,'Extracting raw data, Please wait...');
for i = 1:FileNum-TrajLength

    if isempty(data)
        if Date_start < Traj_time(1,7)-(TrajLength+1)
            Date_start = Date_start+1;
            continue
        else
            for f = i:i+TrajLength
                data = cat(3,data,ncread(fullfile(dataPath,Files(f).name),FieldName,[1 1 1],[Inf Inf Inf]));
            end
        end
    else
        Date_start = Date_start+1;
        if Date_start > floor(Traj_time(end,7))-TrajLength
            break
        else
            data = cat(3,data(:,:,25:end),ncread(fullfile(dataPath,Files(i+TrajLength).name),FieldName,[1 1 1],[Inf Inf Inf]));
        end
    end

    Date_target = Date_start+TrajLength;
    id = find(Traj_time(:,7)>=Date_target & Traj_time(:,7)<Date_target+1);
    
    if ~isempty(id)
        for j = 1:length(id)
            Traj_temp = TrajData{id(j)};
            Traj_temp = Traj_temp(1:24*TrajLength+1,:); % 10-day trajectory
%             keyboard
            data_traj{id(j)}(:,1) = flipud(data_matchup(data,Date_start,Traj_temp));
        end
    end
    waitbar(i / (FileNum-TrajLength));
end
close(h)
end

%
function data_point = data_matchup(data,Date_start,Traj)
T0 = datenum(Traj(1,3)+2000,Traj(1,4),Traj(1,5),Traj(1,6),Traj(1,7),0)-Date_start; % date number for the first trajectory point relative to Date_start

Traj_num = size(Traj,1);
data_point = NaN(Traj_num,1);

for k = 1:Traj_num
    X = mod(floor((Traj(k,11)+180.3125)/0.625),576)+1;
    Y = floor((Traj(k,10)+90.25)/0.5)+1;
    T = round(T0*24+2-k);

    data_temp = squeeze(data(X,Y,:));
    data_point(k) = data_temp(T);
end
end
