function data_traj =  chla_L4_matchup_with_dispersion(dataPath,TrajData,TrajLength,Traj_time,FieldName)
TrajNum = length(TrajData);
data_traj = cell(TrajNum,1);

Files = dir(fullfile(dataPath,'*.nc'));
FileNum = length(Files);

lat = double(ncread(fullfile(dataPath,Files(1).name),'lat'));
lon = double(ncread(fullfile(dataPath,Files(1).name),'lon'));

% get the maximum equivalent radius needs to be considered with different backward time
% unit of TrajLength: day; unit of Rmax: km
Rmax = get_Rmax(TrajLength);

yyyy_start = str2double(Files(1).name(1:4));
mm_start = str2double(Files(1).name(5:6));
dd_start = str2double(Files(1).name(7:8));

% 
data = NaN(length(lon),length(lat),TrajLength+1); % 10-day raw data for matchup
Date_start = datenum(yyyy_start,mm_start,dd_start);
k = 0; % monitor whether data has been assigned
h = waitbar(0,'Extracting raw data, Please wait...');
for i = 1:FileNum-TrajLength

    if k == 0
        if Date_start < Traj_time(1,7)-(TrajLength+1)
            Date_start = Date_start+1;
            continue
        else
            for f = i:i+TrajLength
                data(:,:,f-i+1) = ncread(fullfile(dataPath,Files(f).name),FieldName);
            end
            k = f;
        end
    else
        Date_start = Date_start+1;
        if Date_start > floor(Traj_time(end,7))-TrajLength
            save(['chla_data_extracted_tmp_',num2str(Traj_time(1,1))],'data_traj','Traj_time')
            break
        else
            data = cat(3,data(:,:,2:end),ncread(fullfile(dataPath,Files(i+TrajLength).name),FieldName));
            k = k+1;
        end
    end

    Date_series_data = [Date_start:Date_start+TrajLength]';
    Date_target = Date_series_data(end);
    id = find(Traj_time(:,7)>=Date_target & Traj_time(:,7)<Date_target+1);
    
    if ~isempty(id)
        for j = 1:length(id)
            Traj_temp = TrajData{id(j)};
            Traj_temp = Traj_temp(1:24*TrajLength+1,:); % 10-day trajectory
%             keyboard
            Tfinal_Traj = Traj_time(id(j),7);
            data_traj{id(j)} = data_matchup_with_dispersion(Traj_temp,Tfinal_Traj,lon,lat,data,Date_series_data,Rmax);
        end
    end
    waitbar(i / (FileNum-TrajLength));
    if mod(i,10) == 0
        save(['chla_data_extracted_tmp_',num2str(Traj_time(1,1))],'data_traj','Traj_time')
    end

end
close(h)
end
