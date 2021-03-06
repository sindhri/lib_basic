%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline
%fill it to be 129 and 187+baseline

%2011-08-22, adapted from fill_post_FDR_p_matrix
%2012-02-29, process positive and negative separately to fit the log10
%plotting

%2013-04-15, added chan_list and net_type(1 hydro129; 2, GSN129)
function [p_matrix_pos, p_matrix_neg] = plot_selected_channels_p_log_wholehead(p_list,...
    p_list_sign,chan_list,net_type)

if nargin==2
    chan_list = read_channelclusters;
    chan_list = squeeze(chan_list{1});
    net_type = 1;
end

if nargin<4
    net_type = 2;    
end

[nchan, ndatapoint] = size(p_list);

if nchan ~= length(chan_list)
    fprintf('channel number mismatch, abort\n');
    return
end

total_n_chan = 129;
baseline = 25;

p_matrix_pos = ones(total_n_chan, baseline+ndatapoint);
p_matrix_neg = ones(total_n_chan, baseline+ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        if p_list_sign(i,j) > 0
            p_matrix_pos(chan_list(i),baseline + j) = p_list(i,j);
        else
            p_matrix_neg(chan_list(i),baseline + j) = p_list(i,j);
        end
    end
end

%plotMap_angleAxis_log(p_matrix);

plotMap_angleAxis_log2_wholehead(p_matrix_pos, p_matrix_neg,net_type);