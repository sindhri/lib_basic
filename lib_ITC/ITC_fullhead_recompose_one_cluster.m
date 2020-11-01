%20201031, input: result files from fullhead oscillation
% input coi.chanel = [11, 12, 5, 6], coi.name = 'MFN'
%export: coi, cluster of interest, only 1 cluster information, keep freqs and times
%purpose: time frequency plot without loading the raw data files

%20200421, changed isNAN to isnan
%20200420, added group_name in the code, if oscillation.group_name is empty
%and group_name is not empty
%20160211, renamed foi_type to oscillation_type
%20170619, grab only the foi from each file, such as [4,8];
%instead of loading the whole dataset

%result foi_struct.data, ntimes x ncond x nchan x nsubj
%calculate for both ERSP and ITC

%20190129

function coi_struct = ITC_fullhead_recompose_one_cluster(coi,id_type, pathname,group_name)

if nargin==1
    id_type = 1;
    pathname = uigetdir(pwd,'select oscillation result folder');
    group_name = '';
    
end

name_for_plot = coi.name;
fprintf('cluster of interest is:\n');
    for j = 1:length(coi.channel)
        fprintf('%d ', coi.channel(j));    
    end
fprintf('\n');

file_list = dir(pathname);

id_lsit = cell(1);

   m = 0; 
for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')~=1 && strcmp(temp(length(temp)-3:length(temp)),'.mat')
        
        m = m+1;
        filename = temp;
            
        id = find_id(id_type, filename);
        id_list{m} = id;
            
        load([pathname '/' filename]);
        fprintf('loading %s\n',filename);
        
        if m == 1   
            coi_struct.coi = coi;
            coi_struct.name_for_plot = name_for_plot;
            coi_struct.category_names = oscillation.category_names;

        end
        
        coi_data_ERSP = get_one_cluster(oscillation,coi,'ERSP');
        coi_data_ITC = get_one_cluster(oscillation,coi,'ITC');
        
        if m == 1
            coi_data_all_ERSP = coi_data_ERSP;
            coi_data_all_ITC = coi_data_ITC;
        else
            coi_data_all_ERSP(:,:,:,m) = coi_data_ERSP;
            coi_data_all_ITC(:,:,:,m) = coi_data_ITC;
        end
        
    end
end

coi_struct.ERSP = coi_data_all_ERSP;
coi_struct.ITC = coi_data_all_ITC;

if isempty(group_name)
   coi_struct.group_name = oscillation.group_name;
else
    coi_struct.group_name = group_name;
end

coi_struct.freqs = oscillation.freqs;
coi_struct.times = oscillation.times;
coi_struct.ntimes = oscillation.ntimes;
%coi_struct.channames = oscillation.channames;
%coi_struct.nbchan = oscillation.nbchan;

coi_struct.id = id_list;
fprintf('recompose complete.\n');
end

% get oscillation from one cluster
function coi_data = get_one_cluster(oscillation,coi,oscillation_type)
    [nf,nt,nc] = size(oscillation.ERSP);

    if strcmp(oscillation_type,'ERSP')
        temp = mean(oscillation.ERSP(:,:,:,coi.channel),4);
    elseif strcmp(oscillation_type,'ITC')
        temp = mean(oscillation.ITC(:,:,:,coi.channel),4);
    else
        fprintf('type must be either ERSP or ITC\n');
    end
    
    coi_data = temp; %coi.data: freqs * times * nc
end



