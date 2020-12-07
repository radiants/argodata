function [eng,pos,data]=read_data_from_single_file(filenm)
% this script is used to read the T/S profile into structures from a given core argo file.
% usage: [eng,pos,data]=read_data_from_single_file('..\argo\2902750_001.dat');
% History: 13 April 2019
eng=[];pos=[];data=[];
if ~exist(filenm)
    disp(['cannot find core argo data file: ',filenm]);
    return
end

fid=fopen(filenm,'r');
while ~feof(fid)
    l=fgetl(fid);
    mm=length(l);
    if strncmp(l,'     PLATFORM NUMBER',20)
        eng.wmo=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     CYCLE NUMBER',17)
        eng.cycle=sscanf(l(29:mm),'%d');
    elseif strncmp(l,'     DATE CREATION',18)
        eng.date_creation=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     DATE UPDATE',16)
        eng.date_update=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     PROJECT NAME',17)
        eng.proj_name=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     PI NAME',12)
        eng.pi_name=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     INSTRUMENT TYPE',20)
        eng.inst_type=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     FLOAT SERIAL NO',20)
        eng.float_sn=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     FIRMWARE VERSION',21)
        eng.firmware=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     WMO INSTRUMENT TYPE',24)
        eng.wmo_inst=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     TRANSMISSION SYSTEM',24)
        eng.trans_sys=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     POSITIONING SYSTEM',23)
        eng.pos_sys=sscanf(l(29:mm),'%s');
    elseif strncmp(l,'     SAMPLE DIRECTION',21)
        eng.direction=sscanf(l(29:29),'%s');
    elseif strncmp(l,'     DATA MODE',14)
        eng.data_mode=sscanf(l(29:29),'%s');
    elseif strncmp(l,'     JULIAN DAY',15)
        pos.juld=sscanf(l(29:38),'%f');
    elseif strncmp(l,'     QC FLAG FOR DATE',21)
        pos.juld_qc=sscanf(l(29:29),'%d');
    elseif strncmp(l,'     LATITUDE',13)
        pos.lat=sscanf(l(29:mm),'%f');
    elseif strncmp(l,'     LONGITUDE',14)
        pos.lon=sscanf(l(29:mm),'%f');
    elseif strncmp(l,'     QC FLAG FOR LOCATION',25)
        pos.pos_qc=sscanf(l(29:29),'%d');
    elseif strncmp(l,'==========================================================================',74)
        l=fgetl(fid);
        k=0;
        while length(l)>55
            k=k+1;
            pres(k)=sscanf(l(1:7),'%f');
            pres_adj(k)=sscanf(l(8:14),'%f');
            pres_qc(k)=sscanf(l(15:17),'%d');
            temp(k)=sscanf(l(18:26),'%f');
            temp_adj(k)=sscanf(l(27:35),'%f');
            temp_qc(k)=sscanf(l(36:38),'%d');
            psal(k)=sscanf(l(39:47),'%f');
            psal_adj(k)=sscanf(l(48:56),'%f');
            psal_qc(k)=sscanf(l(57:59),'%d');
            l=fgetl(fid);
        end
    end
end
fclose(fid);
if pos.lat<-999
    pos.lat=nan;
end
if pos.lon<-999
    pos.lon=nan;
end

ind=find(pres<-999);
if ~isempty(ind)
    pres(ind)=nan;
end
ind=find(pres_adj<-999);
if ~isempty(ind)
    pres_adj(ind)=nan;
end
ind=find(temp<-99);
if ~isempty(ind)
    temp(ind)=nan;
end
ind=find(temp_adj<-99);
if ~isempty(ind)
    temp_adj(ind)=nan;
end
ind=find(psal<-99);
if ~isempty(ind)
    psal(ind)=nan;
end
ind=find(psal_adj<-99);
if ~isempty(ind)
    psal_adj(ind)=nan;
end
data.pres=pres;data.pres_adj=pres_adj;data.pres_qc=pres_qc;
data.temp=temp;data.temp_adj=temp_adj;data.temp_qc=temp_qc;
data.psal=psal;data.psal_adj=psal_adj;data.psal_qc=psal_qc;
return