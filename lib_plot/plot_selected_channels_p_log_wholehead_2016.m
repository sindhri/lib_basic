%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline_dpt
%fill it to be 129 and 187+baseline_dpt

%2011-08-22, adapted from fill_post_FDR_p_matrix
%2012-02-29, process positive and negative separately to fit the log10
%plotting

%2013-04-15, added chan_list and net_type(1 hydro129; 2, GSN129)

%20160802, added srate, added using struct, added title
%20160917, check field names for report
%since when comparing two conditions, there is no such field names
%20160917, fixed a baseline_dpt caculation error from the last version
%should solve the baseline_dpt problem completely eventually

%20170810, updated to 2017 version
%20170831, added alpha_level
%20170927, added title
%20190122, replaced wording 'baseline' with 'baseline_dpt', get
%baseline_dpt from the report
%get srate from the report
%get net_type and locs from the report
%20190122, added option to plot post FDR p values too
%confirmed it is plotting 1-p

function [p_matrix_pos, p_matrix_neg] = plot_selected_channels_p_log_wholehead_2016(report,...
    chan_list,pre_or_post,alpha_level)

if nargin==2
    alpha_level = 0.05;
    pre_or_post = 'pre';
end
if nargin==3
    alpha_level = 0.05;
end

if strcmp(pre_or_post,'pre')==1
    p_list = report.p_list;
else
    p_list = report.FDR_adj_p;
end

p_list_sign = report.p_sign;
if any(strcmp(fieldnames(report),'rating_name'))
    title_text = [report.condition_name ' and ' report.rating_name];
else
    title_text = report.name;
end

if nargin==1
    chan_list = read_channelclusters;
    chan_list = squeeze(chan_list{1});
end

if nargin<3
    net_type = 2;    
end

[nchan, ndatapoint] = size(p_list);

if nchan ~= length(chan_list)
    fprintf('channel number mismatch, abort\n');
    return
end

total_n_chan = 129; %so far only used on 129 nets
%baseline_dpt = 100/(1000/srate);
baseline_dpt = report.baseline_dpt;

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
%updated to 2017 version
%plotMap_angleAxis_log2_wholehead_2016(p_matrix_pos, p_matrix_neg,net_type,srate,title_text);
plotMap_angleAxis_log2_wholehead_2017(p_matrix_pos,...
    p_matrix_neg,report.net_type,report.srate,title_text,alpha_level);