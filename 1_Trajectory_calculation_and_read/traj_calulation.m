% This script is to calculate many backward trajectories based on
% HYSPLIT model
%
% The model can be downloaded from NOAA ARL website: https://www.ready.noaa.gov/HYSPLIT_hytrial.php\
%
% Place this script into the same folder as the "hyst_std.exe" of the
% HYSPLIT model or cd to this folder when running.
%
% You should also download the meteorological fields, such as GDAS, before 
% running the job.

%% Define the starting point, starting time, and trajectory length
time_raw = [datenum(2024,1,1):1/24:datenum(2024,1,31,23,0,0)]';
time_raw = datetime(time_raw,'ConvertFrom','datenum');
time_step = [year(time_raw)-2000 month(time_raw) day(time_raw) hour(time_raw)];
point = [39.09 -28.03 200.00]; % Lat, lon, height (m)
traj_length = -240;

%% Write the CONTROL file and run the model
TimeNumber = size(time_step,1);

for iT = 1:TimeNumber
    fid=fopen('CONTROL','w');
    fprintf(fid,'%02d %02d %02d %02d\n',time_step(iT,1:4));
    fprintf(fid,'1\n');
    fprintf(fid,'%7.4f %8.4f %6.2f\n',point);
    fprintf(fid,[num2str(traj_length),'\n0\n10000.0\n']);
    fprintf(fid,'8\n'); % Please change the number, path, and name of following meteorology files. Maximum number of files is 12.
    fprintf(fid,'D:\\GDAS_data\\2023\\\n');
    fprintf(fid,'gdas1.dec23.w4\n');
    fprintf(fid,'D:\\GDAS_data\\2023\\\n');
    fprintf(fid,'gdas1.dec23.w5\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.jan24.w1\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.jan24.w2\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.jan24.w3\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.jan24.w4\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.jan24.w5\n');
    fprintf(fid,'D:\\GDAS_data\\2024\\\n');
    fprintf(fid,'gdas1.feb24.w1\n');
    fprintf(fid,'C:\\Academic\\BT_multiyear\\\n'); % Please define the output path here
    fprintf(fid,'%02d%02d%02d%02d\n',time_step(iT,1:4));
    fclose(fid);
    system('hyts_std.exe');
end