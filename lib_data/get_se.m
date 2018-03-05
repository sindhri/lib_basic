%load the matlab output of the combined file first
%input only 1 condition, nchan x ndatapoint x nsubject
%output se and avg of each datapoint

function [se,avg] = get_se(data,cluster)

[~, ndatapoint, nsubject] = size(data);

%cluster = [19, 20, 23, 24, 26, 27, 28, 34];
if nargin==1
    cluster = read_channelclusters;
    cluster = cluster{1};
end

data = squeeze(mean(data(cluster,:,:),1));
avg = mean(data,2)';
se = zeros(1,ndatapoint);

for i=1:ndatapoint
    se(i) = std(data(i,:))/sqrt(nsubject);
end