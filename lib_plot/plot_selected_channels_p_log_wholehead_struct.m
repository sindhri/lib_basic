%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline
%fill it to be 129 and 187+baseline

%2011-08-22, adapted from fill_post_FDR_p_matrix
%2012-02-29, process positive and negative separately to fit the log10
%plotting

%2013-04-15, added chan_list and net_type(1 hydro129; 2, GSN129)
%2014-07-28, gather info in struct
%2019-01-22, replaced 'baseline' with 'baseline_dpt'

function [p_matrix_pos, p_matrix_neg] = plot_selected_channels_p_log_wholehead_struct(report,...
    pre_or_post_fdr,net_type)

if nargin==2
    net_type = 1;
end

if nargin<4
    net_type = 2;    
end

chan_list = squeeze(report.channel_list);

if strcmp(pre_or_post_fdr, 'pre') == 1
    p_list = report.p_list;
else
    p_list = report.FDR_adj_p;
end

p_list_sign = report.p_sign;


[nchan, ndatapoint] = size(p_list);


total_n_chan = 129;
baseline_dpt =report.baseline_dpt;

p_matrix_pos = ones(total_n_chan, baseline_dpt+ndatapoint);
p_matrix_neg = ones(total_n_chan, baseline_dpt+ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        if p_list_sign(i,j) > 0
            p_matrix_pos(chan_list(i),baseline_dpt + j) = p_list(i,j);
        else
            p_matrix_neg(chan_list(i),baseline_dpt + j) = p_list(i,j);
        end
    end
end

%plotMap_angleAxis_log(p_matrix);

plotMap_angleAxis_log2_wholehead(p_matrix_pos, p_matrix_neg,net_type);