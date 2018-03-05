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


%20151006, use it to plot the whole head, need to calculate all 129
%channels

%added log to the final FFT values for each channel and each frequency
%need to manually import scale for comparison

%the power from the original FFT analysis, freq changes first, then
%channel, the last one is condition. need to change to channel, condition,
%freq


%20151031, added clear ECI_TCPIP_55513;
%20160407 using raw file in order to read all the segments

%20160413, trial_range indicates the allowed trials of each condition, such
%as [1:8], or [9:16]

%20160414, converted to log
%20160420, use log as optional because Tom's thesis uses absolute power,
%default log, also made some modifications on column names

%20160425, added data_in_array for easier exporting
%20160509, added channel_range_cell to enable non-fullhead analysis
%20160509, trial_range, input 'all'

function power = FFT_topoplot_step1_raw(ALLEEG,frequency_range_cell,...
    trial_range, log_or_not,channel_list_cell)

if nargin==3 || nargin==4
    if nargin ==3
        log_or_not = 1;
    end
    
    channel_list_cell = cell(1);
    nchan = 129;    
    for i = 1:nchan
        channel_list_cell{i}=i;
    end
end
%[channel_list_cell,frequency_range_cell]= FFT_config;

if strcmp(trial_range,'all')~=1
    fprintf('trial_range is %d to %d\n',trial_range(1),trial_range(length(trial_range)));
else
    fprintf('full range\n');
end

nchan = length(channel_list_cell);
power.nchan = nchan;
power.channel_list_cell = channel_list_cell;

power.data = [];

m=0;
for i = 1:length(ALLEEG)
    reject_subject = 0;
    
    EEG = ALLEEG(i);
           fprintf('%s\n',EEG.id);
           data.conditions = EEG.category_names;
           if m==0
               power.data_in_array = zeros(length(EEG.category_names),nchan,length(frequency_range_cell),length(ALLEEG));
           end
           
           if strcmp(trial_range,'all')~=1
            updated_count = update_trial_list(EEG.category_names_count,...
                   EEG.good_trial_indicator,trial_range);
           else
               updated_count = EEG.category_names_count;
           end
           
           for j = 1:size(updated_count,1)
               if updated_count{j,2}<3
                   reject_subject = 1;
                   break
               end
           end
           
           if reject_subject == 1
               fprintf('%s rejected for having insufficient trial\n',EEG.id);
               continue
           end

           for j = 1:length(EEG.category_names)
               condition_name = EEG.category_names{j};
               data.(condition_name) = EEG.data(:,:,updated_count{j,3});
           end

           data.samplingRate = EEG.srate;
           data.duration = EEG.xmax-EEG.xmin+1/data.samplingRate;
           data = FFT_process_single_file(data);
           data.channel_list = channel_list_cell;
           data.frequency_list = frequency_range_cell;
           data = FFT_average_single_file(data,log_or_not); 
           if log_or_not==1
               power_next = log(data.output_data);
               power_next_in_array = log(data.output_data_in_array);
           else
               power_next= data.output_data;
               power_next_in_array = data.output_data_in_array;
           end
           power.data = [power.data ; power_next];
           power.data_in_array(:,:,:,i) = power_next_in_array;
           
           m = m+1;
           power.filenames{m} = EEG.id;
           power.label = data.output_label;
           power.group_name = EEG.group_name;
end
power.condition_names = data.conditions;
power.frequency_range_cell = frequency_range_cell;

fprintf('power calculation completed, %d subjects included\n',m);
if ~isempty(power.data)
    export_power_text(power)
end

end

function updated_count= update_trial_list(count,good_trial_indicator,...
    trial_range)

    ncond = size(count,1);
    updated_count = count;

    for i = 1:ncond
        temp_count = updated_count{i,3};
        temp_count = temp_count(trial_range);

        t = good_trial_indicator(temp_count);
        temp_count = temp_count(find(t==1));
        updated_count{i,3} = temp_count;
        updated_count{i,2} = length(temp_count);
    end
end



function export_power_text(power)
    A = dataset({power.data,power.label{:}},'ObsNames',power.filenames);
    [filename,pathname] = uiputfile('*.txt','save the exported data as: ');
    export(A,'file',[pathname, filename]);
end

       
%data is a structure, has samplingRate, conditions, 
%name of the data as the field name, and data
%name of the power as the field name, and power
%all data dimenions is chan x time x seg

function data = FFT_average_single_file(data,log_or_not)

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
data.output_data_in_array = zeros(length(condition_names),length(channel_list_cell),length(frequency_index_cell));

for i = 1:length(condition_names)
    if log_or_not ==1
        power_name = 'log_';
    else
        power_name = '';
    end
    power_name = [power_name 'power_' condition_names{i}];
    power = data.(power_name);
    power = mean(power,3); %average across trials

    for a = 1:length(channel_list_cell)
        chan = channel_list_cell{a};
        chan_name = 'at';
        for j = 1:length(chan)
            chan_name = [chan_name '_chan' int2str(chan(j))];
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

            ave_name = [power_name '_c' int2str(a) chan_name 'freq' int2str(b) freq_name];
%            data.(ave_name) = power_chanave_freqave;
            data.output_data_in_array(i,a,b) = power_chanave_freqave;
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