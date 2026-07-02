function [Traj,TrajpointNum]=ReadTrajFile(path,x)
fid=fopen(fullfile(path,x));
lines = 0; lines2=0;
while ~feof(fid)
    tempstr=fgetl(fid);
    tempstrlen=length(tempstr);
    if(strcmp(tempstr(tempstrlen-7:tempstrlen),'SUN_FLUX'))
        lines2=lines;
    else
    end
    lines = lines +1;
end
fclose(fid);
Traj=readmatrix(fullfile(path,x),'Range',lines2+2);
TrajpointNum=lines-lines2-1;