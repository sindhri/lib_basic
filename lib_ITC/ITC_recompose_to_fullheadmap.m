%20200825, added option for not plotting, just exporting foi_ERSP, foi_ITC
%20200421, added limit and limit_diff to group comparison
%20200327, added ID
%20180711
%20180713, added group_name
function [foi_ERSP,foi_ITC] = ITC_recompose_to_fullheadmap(foi,...
    path_result,net_type,items,plot_or_not,group_name,selected_conditions,...
    limit_ERSP,limit_ERSP_diff, limit_ITC,limit_ITC_diff)

if nargin==4
    group_name = '';
    selected_conditions = [1,2];
    plot_or_not = 'y';
end

foi_struct = ITC_fullhead_recompose_individual(foi,path_result,group_name);
[foi_ERSP,foi_ITC] = ITC_prepare_data_for_heatmap_individual(foi_struct,net_type,selected_conditions);%prepare data for plotting

if plot_or_not == 'y'
    if nargin<11
        ITC_fullhead_heatmap_auto(foi_ERSP, items);
        ITC_fullhead_heatmap_auto(foi_ITC,items);
    else
        ITC_fullhead_heatmap_auto(foi_ERSP, items,limit_ERSP,limit_ERSP_diff);
        ITC_fullhead_heatmap_auto(foi_ITC,items,limit_ITC, limit_ITC_diff);
    end
end
end