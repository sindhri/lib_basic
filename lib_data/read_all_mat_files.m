%read single mat file one by one, build database chan x datapoint x cond x
%subject
%20190121, added id_type, same configuration as find_id
%default id_type = 1, baseline in ms

function EEG_ave = read_all_mat_files(category_names,id_type,...
    net_type,baseline,group_name)


[~,pathname] = uigetfile('.mat',pwd);
file_list = dir(pathname);

m = 0;
data = [];
id_list = cell(1);
nc = length(category_names);

for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')==1
        continue;
    end
    [~,~,file_ext] = fileparts(temp);
    if nargin>1
        id = find_id_from_filename(id_type, temp);
    end
    if strcmp(file_ext,'.mat')==1
        fprintf('loading %s\n',temp);
        load([pathname temp]);
        m = m + 1;
        for j = 1:nc
            data(:,:,j,m) = eval(category_names{j});
        end
        srate = samplingRate;
        if nargin > 1
            id_list{m} = id;
        end
    end
end

EEG_ave.data = data;
EEG_ave.nsubject = length(id_list);
EEG_ave.category_names = category_names;
EEG_ave.nbchan = size(data,1);
EEG_ave.pnts = size(data,2);
EEG_ave.srate = srate;
EEG_ave.net_type = net_type;

if nargin > 1
    EEG_ave.id = id_list;
    if net_type == 1
        EEG_ave.chanlocs = pop_readlocs('GSN-HydroCel-129plus3.sfp');
    % EEG_ave.chanlocs = pop_readlocs('GSN-HydroCel-129_removedtop3.sfp.sfp');
    else
        if net_type ==2
            EEG_ave.chanlocs = pop_readlocs('GSN129.sfp');
        end
    end

    EEG_ave.xmin = -baseline;
    EEG_ave.xmax = EEG_ave.pnts /srate*1000-baseline;
    EEG_ave.group_name = group_name;
end

end