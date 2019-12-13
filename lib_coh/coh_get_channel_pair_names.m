%if single channel, convert to string
%if cluster, use the first channel + andother
%output a structure with name and channel

function montage = coh_get_channel_pair_names(channels,is_cluster)

channel_names = cell(1);

if is_cluster == 0
    n_pairs = size(channels,1);
    for i = 1:n_pairs
        channel_names{i} = ['chan' int2str(channels(i,1)) 'withchan' int2str(channels(i,2))];
    end
else
    n_pairs = length(channels);
    for i = 1:n_pairs
        clusters = channels{i};
        cluster1 = clusters{1};
        cluster2 = clusters{2};
        channel_names{i} = ['cluster' int2str(cluster1(1)) 'withcluster' int2str(cluster2(1))];
    end        
end
montage.name = channel_names;
montage.channel = channels;
end