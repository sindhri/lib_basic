function data_z = z_transfer(data)

[number_of_frequencies, number_of_time_samples, number_of_channels] = size(data);

if number_of_frequencies ~= 19
    fprintf('need to relabel the frequencies!\n');
    return
end

frequency_range = 2:20;

for i = 1:number_of_channels
    for j = 1:number_of_time_samples
        for m = 1:number_of_frequencies
            data_z(m,j,i) = 0.5*(log(1+data(m,j,i))-log(1-data(m,j,i)));
        end
    end
end


