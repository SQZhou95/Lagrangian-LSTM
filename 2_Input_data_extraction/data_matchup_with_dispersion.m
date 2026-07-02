function data_extract = data_matchup_with_dispersion(Traj_tmp,Tfinal_Traj,lon_surface,lat_surface,surface_data,surface_date_index, Rmax)
surface_data = reshape(surface_data,[],length(surface_date_index));
lat_step=(lat_surface(end)-lat_surface(1))/(length(lat_surface)-1);
lon_step=(lon_surface(end)-lon_surface(1))/(length(lon_surface)-1);

num_point = size(Traj_tmp,1);


% Get the coefficients for dispersion weighting factor calculation
w_cof = get_weighting_cof;
num_cof = length(w_cof.a);
num_Rmax = size(Rmax,2);

% Columns 1-3: lower dispersion, weighting factor from low to high;
% Columns 4-6: middle dispersion, weighting factor from low to high;
% Columns 7-9: upper dispersion, weighting factor from low to high;
data_extract = NaN(num_point,num_Rmax*num_cof);


% The index of date (the 3rd dimension of data_emission) for each
% trajectory point
date_step = surface_date_index(2)-surface_date_index(1);
id_date = floor((Tfinal_Traj - [0:1:num_point-1]'/24 - surface_date_index(1))/date_step) + 1;


% Investigate each trajectory point
for i = 1:num_point
    lon_point = Traj_tmp(i,11);
    lat_point = Traj_tmp(i,10);
    [id_grid, w] = get_grid(lon_point,lat_point,lon_surface,lat_surface,lat_step,lon_step,Rmax(i,:),w_cof);

    for j = 1:num_Rmax
        data_tmp = surface_data(id_grid{j},id_date(i));
        for k = 1:num_cof
            w_tmp = w{j}(:,k);
            data_extract(i,j*3+k-3) = weighted_mean(data_tmp,w_tmp,1);
        end
    end
end

data_extract = flipud(data_extract);
