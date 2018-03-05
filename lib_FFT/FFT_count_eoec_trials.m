
%20170817, modified it to count eoec trials from .mat files. b/c .raw files
%don't containt any information.

function trial_count = FFT_count_eoec_trials(category_names,id_type)

%[channel_list_cell,frequency_range_cell]= FFT_config;


[pathname] = uigetdir(pwd,'select mat file folder');
pathname = [pathname '/'];
fprintf('pathname is %s\n', pathname);
file_list = dir(pathname);


trial_count = [];
id_list = cell(1);
m = 1;
    
for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')~=1
       if strcmp(temp(length(temp)-3:length(temp)),'.mat');

           filename = temp;
           
           if id_type==1
                id = find_id(filename);
            else
                id = find_id2(filename);
            end
            id_list{m} = id;
            fprintf('%s\n',id);
            
            simple_count = count_mat_trials(pathname,filename,category_names);
            m = m+1;
            trial_count = [trial_count;simple_count];

       end
    end

end
    export_trial_count(pathname,trial_count,category_names,id_list);
    msgbox('trial count saved in ''trial_count.txt''.');

end

function id = find_id(filename)
    first = [];
    last = [];
    for i = 1:length(filename)
        if ~isempty(str2num(filename(i))) && isempty(first)
            first = i;
            break
        end
    end
    for i = first+1:length(filename)
        if isempty(str2num(filename(i))) && isempty(last)
            last = i-1;
            break
        end
    end
    id = filename(first:last);
end

function id=find_id2(filename)
    dots = find(filename=='.');
    id = filename(1:dots(1)-1);
end

function simple_count = count_mat_trials(pathname,filename,category_names)
    simple_count = zeros(1,length(category_names));
    
    load([pathname filename]);
    for i = 1:length(category_names)
        current = category_names{i};
        if exist(current,'var')
            temp = eval(current);
            simple_count(i) = size(temp,3); %nchan x ndpt x ntrial
        else
            simple_count(i) = 0;
        end
    end
end

function export_trial_count(pathname,trial_count,category_names,id_list)
    A = dataset({trial_count,category_names{:}},'ObsNames',id_list);
    export(A,'file',[pathname 'trial_count.txt']);
end