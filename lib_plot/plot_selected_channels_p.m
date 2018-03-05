%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline
%fill it to be 129 and 187+baseline

%2011-08-22, adapted from fill_post_FDR_p_matrix


function p_matrix = plot_selected_channels_p(p_list, p_list_sign)

chan_list = read_channelclusters;
chan_list = squeeze(chan_list{1});

[nchan, ndatapoint] = size(p_list);

if nchan ~= length(chan_list)
    fprintf('channel number mismatch, abort\n');
    return
end

total_n_chan = 129;
baseline = 25;

p_matrix = ones(total_n_chan, baseline+ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        if p_list_sign(i,j) > 0
            p_matrix(chan_list(i),baseline + j) = p_list(i,j);
        else
            p_matrix(chan_list(i),baseline + j) = -p_list(i,j);
        end
    end
end

%plotMap_angleAxis_log(p_matrix);

plotMap_angleAxis(p_matrix);