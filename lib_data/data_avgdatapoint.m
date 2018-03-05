%2011-04-12
%input: data, chan x datapoint x subject x condition x ...
%input: factor_datapoint, example [157,250;110,197;71,146;26,86];
%output: chan x nfactor x subject x condition x ...
%max data dim = 5

function output = data_avgdatapoint(data,factor_datapoint)

ndim = length(size(data));
if ndim < 2
    msgbox('data is 1-dimension, need 2nd dim as datapoint');
    output = [];
    return
end

if ndim > 5
    msgbox('data too many dimensions');
    output = [];
    return
end

nfactor = size(factor_datapoint,1);
[ndim1,~,ndim3,ndim4,ndim5] = size(data);
output = zeros(ndim1,nfactor,ndim3,ndim4,ndim5);

for i = 1:nfactor
    output(:,i,:,:,:) = mean(data(:,...
        factor_datapoint(i,1):factor_datapoint(i,2),:,:,:),2);
end
