%20170604, revised FFT_topoplot_step1 to FFT_waveform
%input channel clusters that needs waveforms
%will draw a row x col waveform for only 1 group at a time
%col is the number of conditions
%row is the number of clusters
%for the whole freuqency limit

%step1 returns the power in the following dimension
%nchan x nfreqs (defined by freqs) x ncond x nsubjects

function power = FFT_waveform_step1(category_names)


pathname = uigetdir;
pathname = [pathname '/'];
file_list = dir(pathname);

group_name = find_group_name(pathname); %use last folder name as the group name
power.group_name = group_name;

power_all = [];
m = 0;
id_all = cell(1);
for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')~=1
       if strcmp(temp(length(temp)-3:length(temp)),'.mat');
           m = m + 1;
           filename = temp;
           id = find_id(filename);
           power.filenames{m} = filename;
           fprintf('%s\n',filename);
           data = read_mat_file(pathname,filename,category_names);
           data = FFT_process_single_file(data);
           
           id_all{m} = id;
           power_all(:,:,:,m) = data.power;
       end
    end
end
power.id = id_all;
power.power = power_all;
power.freqs = data.freqs;
power.samplingRate = data.samplingRate;
power.category_names = data.conditions;
power.ncond = data.ncond;
power.nsubj = length(id_all);

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


function group_name = find_group_name(pathname)
    total = length(pathname);
    found_target = zeros(2,1);
    m=1;
    for i = 1:total
        target = total-i+1;
        if strcmp(pathname(target),'/')==1
            found_target(m)=i;
            m = m+1;
        end
        if m>2
            break
        end
    end
    found_target = total-found_target+1;
    found_target(1) = found_target(1)-1;
    found_target(2) = found_target(2)+1;
    group_name = pathname(found_target(2):found_target(1));
end

function data = read_mat_file(pathname,filename,category_names)
    load([pathname filename]);
    
    data.filename = filename;
    data.pathname = pathname;
    data.samplingRate = samplingRate;
    data.conditions = category_names;
    data.ncond = length(category_names);
    for i = 1:data.ncond
        data.(category_names{i}) = eval(category_names{i});
    end
    [data.nchan,data.ndpt,~] = size(data.(category_names{1}));
    data.duration = data.ndpt/data.samplingRate;
end


%20130121,data is a structure
%data.conditions describes the conditons
%data.(data.conditons{i}) has the data in chan x time x seg

%detrend can be done on all channels at the same time,but 1 seg a time
%fft can be done onn all channels and all segs together
%refernce tap007script.m

function data = FFT_process_single_file(data)
   
    data.power = zeros(data.nchan,data.ndpt/2,data.ncond);
    data.freqs = 0:0.5:data.samplingRate/2-0.5;
    for i = 1:data.ncond
        condition_name = data.conditions{i};
       
        d = data.(condition_name);
        d_detrend = zeros(size(d));
        for j = 1:size(d,3)
            d_detrend(:,:,j) = detrend(d(:,:,j));
        end
%        show_detrend_effect(d,d_detrend);
        d_fft = fft(d_detrend,[],2)/size(d_detrend,2);
        power = 2*abs(d_fft).^2;
        power = mean(power,3);
        power = power(:,1:size(power,2)/2); %assuming ndatapoint is always an even number
        data.power(:,:,i) = power;
    end
end        
