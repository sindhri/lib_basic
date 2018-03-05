%2011-08-22, adapted from average_erp.
%input: data-- chan x datapoint x subject x ... max dimension =5
%output: output --factor x subject x ...

%2011-09-09
%added datapoint and channel indication

function output = data_avgdatapointchan(data,factor_datapoint, chan)

%factor_datapoint = [157,250;110,197;71,146;26,86];

%factor_datapoint = [87,124;125,174];

nfactor = size(factor_datapoint,1);

fprintf('averaging datapoint..\n');
for i=1:nfactor
    fprintf('f%d: %d to %d, \n',i,factor_datapoint(i,1),factor_datapoint(i,2));
end
fprintf('\n');

fprintf('averaging channel..\n');
for i=1:length(chan)
    fprintf('%d ',chan(i));
end
fprintf('\n');

[ndim1,~,ndim3,ndim4,ndim5] = size(data);
output = zeros(ndim1,nfactor,ndim3,ndim4,ndim5);

for i = 1:nfactor
    output(:,i,:,:,:) = mean(data(:,...
        factor_datapoint(i,1):factor_datapoint(i,2),:,:,:),2);
end

%chan=[11,12,5,6];

output = squeeze(mean(output(chan,:,:,:,:),1));