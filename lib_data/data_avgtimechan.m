%2011-09-07, use data_avgdatapointchan

%2011-08-22, adapted from average_erp.
%input: data-- chan x datapoint x subject x ... max dimension =5
%output: output --factor x subject x ...




function output = data_avgtimechan(data,factor_time,chan)

n_factor = size(factor_time,1);

fprintf('averaging time point..\n');
for i=1:n_factor
    fprintf('f%d: %d ms to %d ms, \n',i,factor_time(i,1),factor_time(i,2));
end
fprintf('\n');

factor_datapoint = zeros(size(factor_time));

for i=1:n_factor
    for j = 1:2
    factor_datapoint(i,j) = convert_time2datapoint(factor_time(i,j)); 
    end
end

output = data_avgdatapointchan(data,factor_datapoint,chan);