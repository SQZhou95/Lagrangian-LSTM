function [id_grid, w] = get_grid(lon_point,lat_point,lon_surface,lat_surface,lat_step,lon_step,Rmax,w_cof)
num_Rmax = length(Rmax);
id_grid = cell(num_Rmax,1);
w = cell(num_Rmax,1);

lat_length = length(lat_surface);
lon_length = length(lon_surface);

Y_point = round((lat_point - lat_surface(1))/lat_step)+1;
X_point = round((lon_point - lon_surface(1))/lon_step)+1;
for i = 1:num_Rmax
% for i = 2:2
    Y_diff_max = ceil(Rmax(i)/111.2/abs(lat_step)); % Get the number of lat_step needs to be considered. 111.2 km corresponds to one degree.
    A = (Y_point-Y_diff_max:Y_point+Y_diff_max);
    A(or(A < 1,A > lat_length)) = [];
    
    lat_code_tmp = ones(lon_length,1)*A;
    lon_code_tmp = (1:lon_length)'*ones(1,length(A));
    distance_tmp = 6371*distance([lat_point lon_point],[lat_surface(lat_code_tmp(:)) lon_surface(lon_code_tmp(:))])/180*pi();
    Index = find(distance_tmp <= Rmax(i));

    if isempty(Index)
        lat_code = Y_point;
        lon_code = X_point;
        distance_grid = 0;
    else
        lat_code = lat_code_tmp(Index);
        lon_code = lon_code_tmp(Index);
        distance_grid = distance_tmp(Index);
    end
    id_grid{i} = (lat_code-1)*lon_length+lon_code;

    for j = 1:length(w_cof.a)
%     for j = 2:2
        w{i}(:,j) = w_cof.a(j)./(1 + w_cof.b(j)*distance_grid.^w_cof.c(j));
    end
end



