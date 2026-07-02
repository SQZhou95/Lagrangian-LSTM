function data_point = DMS_matchup_daily(Traj,Traj_time,DMSconc_temp,grid)
id_day = floor(Traj_time:-1/24:Traj_time-10)'-floor(Traj_time-10)+1;
Traj_num = size(Traj,1);
data_point = NaN(Traj_num,1);
for k = 1:Traj_num
    T = id_day(k);
    X = find(and(and(Traj(k,10)<=(grid(:,1)+0.5),Traj(k,10)>(grid(:,1)-0.5)),...
                and(Traj(k,11)<=(grid(:,2)+0.5),Traj(k,11)>(grid(:,2)-0.5))));
    if isempty(X)
        data_point(k) = 0;
    else
        data_tmp = DMSconc_temp(X,T);
        if isnan(data_tmp)
            X2 = and(and(Traj(k,10)<=(grid(:,1)+2.5),Traj(k,10)>(grid(:,1)-2.5)),...
                and(Traj(k,11)<=(grid(:,2)+2.5),Traj(k,11)>(grid(:,2)-2.5)));
            data_tmp = nanmean(DMSconc_temp(X2,T));
        end
        data_point(k) = data_tmp;
    end
end
end
