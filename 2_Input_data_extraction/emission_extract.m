function data_extract = emission_extract(EmissionPath,TrajLength,TrajData,Traj_time)
num_Traj = length(TrajData);
data_extract = cell(num_Traj,1);


% get the grid information of emission data. Attention: the grid should be
% lon*lat
[lon, lat] = read_grid_information(fullfile(EmissionPath,'CAMS-GLOB-ANT_Glb_0.1x0.1_anthro_so2_v5.3_monthly_2014.nc'),{'lon','lat'});


% get the maximum equivalent radius needs to be considered with different backward time
% unit of TrajLength: day; unit of Rmax: km
Rmax = get_Rmax(TrajLength);



year_all = [min(Traj_time(:,1)):max(Traj_time(:,1))]';
num_year = length(year_all);

for j = 1:num_year
    year_id_previous = num2str(year_all(j)-1);
    year_id = num2str(year_all(j));
    if j == 1 && Traj_time(1,7)-datenum(year_all(j),1,1)>=TrajLength
        tmp = load(fullfile(EmissionPath,['GLOB-SO2_daily_',year_id,'.mat']),'date_index','sum_daily');
        data_emission = tmp.sum_daily;
        date_index = tmp.date_index; % Columns 1-6: Year, Month, Day, Weekday ID, daynum, day ID in a year
    elseif j == 1 && Traj_time(1,7)-datenum(year_all(j),1,1)<TrajLength
        tmp = load(fullfile(EmissionPath,['GLOB-SO2_daily_',year_id_previous,'.mat']),'date_index','sum_daily');
        data_emission = tmp.sum_daily(:,:,end-TrajLength:end);
        date_index = tmp.date_index(end-TrajLength:end,:);

        tmp = load(fullfile(EmissionPath,['GLOB-SO2_daily_',year_id,'.mat']),'date_index','sum_daily');
        data_emission = cat(3,data_emission,tmp.sum_daily);
        date_index = cat(1,date_index,tmp.date_index);

    else
        tmp = load(fullfile(EmissionPath,['GLOB-SO2_daily_',year_id,'.mat']),'date_index','sum_daily');
        data_emission = cat(3,data_emission(:,:,end-TrajLength:end),tmp.sum_daily);
        date_index = cat(1,date_index(end-TrajLength:end,:),tmp.date_index);
    end


    idx_this_year = find(Traj_time(:,1)==year_all(j));
    h = waitbar(0,['Year ',year_id,' is processing. Please wait ...']);
    for k = 1:length(idx_this_year)
        id_Traj = idx_this_year(k);
        Tfinal_Traj = Traj_time(id_Traj,7);
        Traj_tmp = TrajData{id_Traj}(1:24*TrajLength+1,:);
        data_extract{id_Traj} = data_matchup_with_dispersion(Traj_tmp,Tfinal_Traj,lon,lat,data_emission,date_index(:,5), Rmax);
    
        waitbar(k/length(idx_this_year))

        if mod(k,1000) == 0 || k == length(idx_this_year)
            save(['data_extract_tmp_when_processing_',year_id,'.mat'],'data_extract','Traj_time')
        end
    end
    close(h)
end

