%20130515, added channel_clusters as input

%2011-04-12
%input: data, chan x datapoint x subject x condition x ...
%output: data_avg, nclusters x datapoint x subject x condition x ...
%1st dimension, average at the channel cluster
%other dimensions unchange, data max dim 5

function [data_avg,channel_clusters] = data_avgchannel(data,channel_clusters)

ndim = length(size(data));
if ndim > 5
    msgbox('too many dimensions, abort');
    data_avg = [];
    return
end

if nargin==1
    channel_clusters = read_channelclusters;
end

nclusters = length(channel_clusters);
[~,ndim2,ndim3,ndim4,ndim5] = size(data);

data_avg = zeros(nclusters, ndim2,ndim3,ndim4,ndim5);
for i = 1:nclusters
    channel_list = squeeze(channel_clusters{i});
    data_avg(i,:,:,:,:) = mean(data(channel_list,:,:,:,:),1);
end