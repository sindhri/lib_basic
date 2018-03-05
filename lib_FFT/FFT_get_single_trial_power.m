%input data is the single trial data with all frequency bins, not averaged
%across
%data.power_(cond_name) is chan x bins x trial
%need to average across desired frequency bins
%raw power, not through log.

function data = FFT_get_single_trial_power(data)

Fs = data.samplingRate;
D = data.duration;
condition_names = data.conditions;
channel_list_cell = data.channel_list;
frequency_range_cell = data.frequency_list;

freqs_scale = Fs/2*linspace(0,1,Fs/2*D);
frequency_index_cell = convert_freqs_to_index(freqs_scale,frequency_range_cell);%convert [8,10] to [16:20]

m = 1;


for i = 1:length(condition_names)
    power_name = ['power_' condition_names{i}];
    power = data.(power_name);
    data = rmfield(data,(power_name));
%    power = mean(power,3); %average across trials
    
    for a = 1:length(channel_list_cell)
        chan = channel_list_cell{a};
        power_chanave = squeeze(mean(power(chan,:,:),1));
        for b = 1:length(frequency_index_cell)
            freq = frequency_index_cell{b};
            power_chanave_freqave = mean(power_chanave(freq,:),1);
            data.(power_name)(b,:) = power_chanave_freqave;
                        
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