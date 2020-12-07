function [eng,pos,data]=read_data_from_float(wmo_dir,wmo)
% this script is used to read all T/S profiles into structures from the directory of a
% certain float.
% usage: [eng,pos,data]=read_data_from_float('.\2902750\','2902750')
% History: 13 April 2019
eng=[];pos=[];data=[];
if ~isdir(wmo_dir)
    disp(['cannot find directory ',wmo_dir]);
    return
end
files=dir(fullfile(wmo_dir,[wmo,'*dat']));
m=length(files);
if m<1
    disp(['cannot find any files from ',wmo_dir]);
end
PRES=nan*ones(100,m);PRES_ADJ=PRES;PRES_QC=PRES;
TEMP=PRES;TEMP_ADJ=PRES;TEMP_QC=PRES;
PSAL=PRES;PSAL_ADJ=PRES;PSAL_QC=PRES;
for i=1:m
    filenm=[wmo_dir,files(i).name];
    fid=fopen(filenm,'r');
    while ~feof(fid)
        l=fgetl(fid);
        mm=length(l);
        if strncmp(l,'     PLATFORM NUMBER',20)
            eng.wmo=sscanf(l(29:mm),'%s');
        elseif strncmp(l,'     CYCLE NUMBER',17)
            eng.cycle(i)=sscanf(l(29:mm),'%d');
        elseif strncmp(l,'     DATE CREATION',18)
            eng.date_creation{i}=sscanf(l(29:mm),'%s');
        elseif strncmp(l,'     DATE UPDATE',16)
            eng.date_update{i}=sscanf(l(29:mm),'%s');
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
            eng.direction(i)=sscanf(l(29:29),'%s');
        elseif strncmp(l,'     DATA MODE',14)
            eng.data_mode(i)=sscanf(l(29:29),'%s');
        elseif strncmp(l,'     JULIAN DAY',15)
            pos.juld(i)=sscanf(l(29:38),'%f');
        elseif strncmp(l,'     QC FLAG FOR DATE',21)
            pos.juld_qc(i)=sscanf(l(29:29),'%d');
        elseif strncmp(l,'     LATITUDE',13)
            pos.lat(i)=sscanf(l(29:mm),'%f');
        elseif strncmp(l,'     LONGITUDE',14)
            pos.lon(i)=sscanf(l(29:mm),'%f');
        elseif strncmp(l,'     QC FLAG FOR LOCATION',25)
            pos.pos_qc(i)=sscanf(l(29:29),'%d');
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
    [im,jm]=size(PRES);
    if k>im
        PRES(im+1:k,:)=nan;PRES_ADJ(im+1:k,:)=nan;PRES_QC(im+1:k,:)=nan;
        TEMP(im+1:k,:)=nan;TEMP_ADJ(im+1:k,:)=nan;TEMP_QC(im+1:k,:)=nan;
        PSAL(im+1:k,:)=nan;PSAL_ADJ(im+1:k,:)=nan;PSAL_QC(im+1:k,:)=nan;
    end
    PRES(1:k,i)=pres(:);PRES_ADJ(1:k,i)=pres_adj(:);PRES_QC(1:k,i)=pres_qc(:);
    TEMP(1:k,i)=temp(:);TEMP_ADJ(1:k,i)=temp_adj(:);TEMP_QC(1:k,i)=temp_qc(:);
    PSAL(1:k,i)=psal(:);PSAL_ADJ(1:k,i)=psal_adj(:);PSAL_QC(1:k,i)=psal_qc(:);
    clear pres pres_* temp temp_* psal psal_* k
end
ind=find(pos.lat<-999);
if ~isempty(ind)
    pos.lat(ind)=nan;
end
ind=find(pos.lon<-999);
if ~isempty(ind)
    pos.lon(ind)=nan;
end
ind=find(PRES<-999);
if ~isempty(ind)
    PRES(ind)=nan;
end
ind=find(PRES_ADJ<-999);
if ~isempty(ind)
    PRES_ADJ(ind)=nan;
end
ind=find(TEMP<-99);
if ~isempty(ind)
    TEMP(ind)=nan;
end
ind=find(TEMP_ADJ<-99);
if ~isempty(ind)
    TEMP_ADJ(ind)=nan;
end
ind=find(PSAL<-99);
if ~isempty(ind)
    PSAL(ind)=nan;
end
ind=find(PSAL_ADJ<-99);
if ~isempty(ind)
    PSAL_ADJ(ind)=nan;
end
data.pres=PRES;data.pres_adj=PRES_ADJ;data.pres_qc=PRES_QC;
data.temp=TEMP;data.temp_adj=TEMP_ADJ;data.temp_qc=TEMP_QC;
data.psal=PSAL;data.psal_adj=PSAL_ADJ;data.psal_qc=PSAL_QC;
return