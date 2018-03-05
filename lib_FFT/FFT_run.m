%20130204, delete Impedances from netstaion output
%20130129

%before running the file, update the file with desired channel_list_cell
%and frequency_range_cell
%to run simple type the following in the command window
%power = FFT_run;

%import, will guide to choose the data folder and process all the .mat
%files in it
%output, will guide to save the data in a text file, that can be opened by
%excel.
%also output the actual data and its label, all in the output struct 'power'

%20140121, added trial number output, changed filename to subject id in
%output

%20151031, added find_id2 for autism ids
%20151031, added clear ECI_TCPIP_55513;


function [power,ntrials] = FFT_run

[channel_list_cell,frequency_range_cell]= FFT_config;

[~,pathname] = uigetfile('*.mat',pwd);
file_list = dir(pathname);

power.filenames = cell(1);

power.data = [];
ntrials.data = [];
m = 0;
for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')~=1
       if strcmp(temp(length(temp)-3:length(temp)),'.mat');
           m = m + 1;
           filename = temp;
           power.filenames{m} = filename;
           power.ids{m} = find_id2(filename);
           fprintf('%s\n',filename);
           data = read_mat_file(pathname,filename);
           data = FFT_process_single_file(data);
           data.channel_list = channel_list_cell;
           data.frequency_list = frequency_range_cell;
           data = FFT_average_single_file(data); 
           power.data = [power.data ; data.output_data];
           power.label = data.output_label;
           ntrials.data = [ntrials.data;data.ntrials];
           ntrials.ids = power.ids;
           ntrials.label = data.conditions;
       end
    end

end
if ~isempty(power.data)
    export_power_text(power)
    export_ntrials_text(ntrials)
end

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


function data = read_mat_file(pathname,filename)
    load([pathname filename]);
    data.filename = filename;
    data.pathname = pathname;
    data.samplingRate = samplingRate;
    clear filename;
    clear pathname;
    clear samplingRate;
    clear ECI_TCPIP_55513;
    t = who;
    m = 1;
    n_datapoint= 0;
    for i = 1:length(t)
        variable_name = t{i};
        if length(variable_name) >=10 
            if strcmp(variable_name(1:10),'Impedances')==1
                continue;
            end
        end
        if strcmp(variable_name,'data') ~=1 
            data.conditions{m} = t{i};
            data.(data.conditions{m}) = eval([data.conditions{m}]);
            if n_datapoint ==0 
                n_datapoint = size(data.(data.conditions{m}),2);
            end
            data.ntrials(1,m) = size(data.(data.conditions{m}),3);
            m = m + 1;
        end
    end
    data.duration = n_datapoint/data.samplingRate;
end

function export_power_text(power)
    A = dataset({power.data,power.label{:}},'ObsNames',power.ids);
    [filename,pathname] = uiputfile('*.txt','save the exported data as: ');
    export(A,'file',[pathname, filename]);
end

function export_ntrials_text(ntrials)
    A = dataset({ntrials.data,ntrials.label{:}},'ObsNames',ntrials.ids);
    [filename,pathname] = uiputfile('*.txt','save the trialnumber as: ');
    export(A,'file',[pathname, filename]);
end
       
%data is a structure, has samplingRate, conditions, 
%name of the data as the field name, and data
%name of the power as the field name, and power
%all data dimenions is chan x time x seg

function data = FFT_average_single_file(data)

Fs = data.samplingRate;
D = data.duration;
condition_names = data.conditions;
channel_list_cell = data.channel_list;
frequency_range_cell = data.frequency_list;

freqs_scale = Fs/2*linspace(0,1,Fs/2*D);
frequency_index_cell = convert_freqs_to_index(freqs_scale,frequency_range_cell);%convert [8,10] to [16:20]


m = 1;
data.output_data = [];
data.output_label = cell(1);
for i = 1:length(condition_names)
    power_name = ['power_' condition_names{i}];
    power = data.(power_name);
    power = mean(power,3); %average across trials

    for a = 1:length(channel_list_cell)
        chan = channel_list_cell{a};
        chan_name = 'at';
        for j = 1:length(chan)
            chan_name = [chan_name '_' int2str(chan(j))];
        end
        power_chanave = squeeze(mean(power(chan,:),1));
        for b = 1:length(frequency_index_cell)
            freq = frequency_index_cell{b};
            power_chanave_freqave = mean(power_chanave(freq));

            freq_name = 'at';
            for j = 1:length(frequency_range_cell{b})
                t = frequency_range_cell{b};
                freq_name = [freq_name '_' int2str(t(j))];
            end
            freq_name = [freq_name 'Hz'];

            ave_name = [power_name '_ave_chan' int2str(a) chan_name 'freq' int2str(b) freq_name];
%            data.(ave_name) = power_chanave_freqave;
            data.output_data = [data.output_data power_chanave_freqave];
            data.output_label{m} = ave_name;
            m = m + 1;
        end
    end
end
end

function index = convert_freqs_to_index(freqs_scale,frequency_range_cell)

index = cell(1);
for i = 1:length(frequency_range_cell)
    freq = frequency_range_cell{i};
    startfreq = freq(1);
    endfreq = freq(2);
    freq_index_start = find(freqs_scale>startfreq,1);
    temp = find(freqs_scale<endfreq);
    freq_index_end = temp(length(temp));
    index{i} = freq_index_start:freq_index_end;
end
end
            
%20130121,data is a structure
%data.conditions describes the conditons
%data.(data.conditons{i}) has the data in chan x time x seg

%detrend can be done on all channels at the same time,but 1 seg a time
%fft can be done onn all channels and all segs together
%refernce tap007script.m

function data = FFT_process_single_file(data)
    n_cond = length(data.conditions);
    for i = 1:n_cond
        condition_name = data.conditions{i};
        power_name = ['power_' condition_name];
        d = data.(condition_name);
        d_detrend = zeros(size(d));
        for j = 1:size(d,3)
            d_detrend(:,:,j) = detrend(d(:,:,j));
        end
%        show_detrend_effect(d,d_detrend);
        d_fft = fft(d_detrend,[],2)/size(d_detrend,2);
        power = 2*abs(d_fft).^2;
        data.(power_name) = power;
    end
end

function show_detrend_effect(d,d_detrend)
    figure;
    n_seg = size(d,3);
    chan = randi([1,129]);   
    ncol = 2;
    nrow = n_seg;
    for i = 1:2
        if i==1
            data = d;
        else
            data = d_detrend;
        end
        for j = 1:nrow
            order = ncol*(j-1)+i;
            subplot(nrow,2,order);
 
            plot(data(chan,:,j));
            ylabel(['chan ' int2str(chan)]);
            title(int2str(order));
        end
    end
        
end