%2013-02-19, added baseline

%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline
%fill it to be 129 and 187+baseline, forming p_matrix_pos and p_matrix_neg

%2011-08-22, adapted from fill_post_FDR_p_matrix
%2012-02-29, process positive and negative separately to fit the log10
%plotting
%2013-03-22, added channel_to_plot

%2014-07-18
%merged single and wholehead. either input a single channel or if ommitted, 
%default as whole head

%1. plot all channels whole head, montage, no need of filling the matrix,
%but need to separate them into positive and negative
%2. plot all channels in part of the head, montage, filling the matrix and
%separation
%3. plot one channel, no montage, no need of filling the matrix, still need
%separation.

function [p_matrix_pos, p_matrix_neg] = plot_selected_channels_p_log(p_list, ...
    p_list_sign,channel_to_plot,baseline,sampling_rate,net_type,total_nchan)

[nchan, ndatapoint] = size(p_list);

if nargin==2
    channel_to_plot = 1:nchan;
end

if nargin==3 || nargin ==2
    baseline = 25;
    sampling_rate = 250;
    net_type = 1; %hydrocel
    total_nchan = 129;
end

if nargin==3 && length(channel_to_plot)>1
    fprintf('can only plot 1 channel! abort\n');
    return
end

if length(channel_to_plot) > 1
    plot_single = 0;
else
    plot_single = 1;
end

if plot_single == 0
    chan_list = read_channelclusters;
    chan_list = squeeze(chan_list{1});
    if nchan ~= length(chan_list)
        fprintf('channel number mismatch, abort\n');
        return
    end
else
    chan_list = channel_to_plot;
end

total_nchan = 129;

p_matrix_pos = ones(total_nchan, baseline+ndatapoint);
p_matrix_neg = ones(total_nchan, baseline+ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        if p_list_sign(i,j) > 0
            p_matrix_pos(chan_list(i),baseline + j) = p_list(i,j);
        else
            p_matrix_neg(chan_list(i),baseline + j) = p_list(i,j);
        end
    end
end

if plot_single = 1

    plotMap_angleAxis_log2_singlechan(p_matrix_pos, p_matrix_neg,...
        baseline*1000/sampling_rate,sampling_rate,channel_to_plot);
else
    plotMap_angleAxis_log2_wholehead(p_matrix_pos, p_matrix_neg,...
        baseline*1000/sampling_rate,sampling_rate,channel_to_plot);
end    