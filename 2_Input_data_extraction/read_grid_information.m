function [lon, lat] = read_grid_information(file_name,variable_name)
lon = double(ncread(file_name,variable_name{1}));
lat = double(ncread(file_name,variable_name{2}));