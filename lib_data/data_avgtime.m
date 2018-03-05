%2013-05-05, it can also be used for chan x datapoint x cond x subj

%2011-09-09
%uses from data_avgdatapoint

%2011-04-12
%input: data, chan x datapoint x subject x condition x ...
%input: factor_datapoint, example [157,250;110,197;71,146;26,86];
%output: chan x nfactor x subject x condition x ...
%max data dim = 5

function output = data_avgtime(data,factor_time)

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

output = data_avgdatapoint(data,factor_datapoint);