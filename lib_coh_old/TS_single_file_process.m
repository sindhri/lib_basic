function [data_freq_8_to_12, data_freq_10_to_12] = TS_single_file_process(data)

[number_of_frequencies, number_of_time_samples, number_of_channels] = size(data);

if number_of_frequencies ~= 19
    fprintf('need to relabel the frequencies!\n');
    return
end

frequency_range = 2:20;
time_group = {1:10,11:20,21:30,31:40,41:50,51:60,61:70,71:80,81:90,91:101};
frequency_alpha_8_to_12 = {2:3,4:7,8:12,13:max(frequency_range)};
frequency_alpha_10_to_12 = {2:3,4:7,8:9,9:12,13:max(frequency_range)};

for i = 1:number_of_channels
    for j = 1:number_of_time_samples
        for m = 1:number_of_frequencies
            data_z(m,j,i) = 0.5*(log(1+data(m,j,i))-log(1-data(m,j,i)));
        end
    end
end

for i = 1:length(time_group)
    data_z_time(:,i,:) = mean(data_z(:,time_group{i},:),2);
end
data_freq_8_to_12 = aggregate_freq(data_z_time, frequency_range, frequency_alpha_8_to_12);
data_freq_10_to_12 = aggregate_freq(data_z_time, frequency_range, frequency_alpha_10_to_12);


