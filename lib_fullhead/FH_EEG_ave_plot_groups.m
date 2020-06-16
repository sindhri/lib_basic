%20200208, added more export. need to make it better to automatically write
%files
%20200204, use the unique values in the grouping column,not just limited to
%1 and 2. but can only do 2 groups. changed structures
%input EEG_ave, a grouping table, the column to group
%input poi, name, time (unnecessary), cluster, stats_type
%export using FH_story1_2, data for plot

function [plot_struct1,plot_struct2]=FH_EEG_ave_plot_groups(EEG_ave,cond_selected, group_table,...
    column_to_group,poi)

EEG_ave = FH_select_condition(EEG_ave,cond_selected);

%get grouping
vname = group_table.Properties.VariableNames(column_to_group);
vname = vname{1};
unique_value = unique(group_table.(vname),'sorted');
group1_index = group_table.(vname)==unique_value(1);
group2_index = group_table.(vname)==unique_value(2);
group1_IDs = group_table.ID(group1_index);
group2_IDs = group_table.ID(group2_index);

[~,~,index1] = intersect(group1_IDs,EEG_ave.ID);
[~,~,index2] = intersect(group2_IDs,EEG_ave.ID);

EEG_ave1 = EEG_ave_take_partial(EEG_ave,index1,[vname '=' int2str(unique_value(1))]);
EEG_ave2 = EEG_ave_take_partial(EEG_ave,index2, [vname '=' int2str(unique_value(2))]);

%plot
data_plot1 = calc_data_plot(EEG_ave1,poi);
data_plot2 = calc_data_plot(EEG_ave2,poi);

plot_ylim(1) = floor(min(min([data_plot1;data_plot2])));
plot_ylim(2) = ceil(max(max([data_plot1;data_plot2])));

title_text1 = [EEG_ave1.group_name '_' poi.name];
title_text2 = [EEG_ave2.group_name '_' poi.name];

legend_text = EEG_ave.eventtypes;

plot_1ERP_poi_ave(data_plot1,EEG_ave1.times,title_text1,legend_text,...
    poi.time,plot_ylim);
plot_1ERP_poi_ave(data_plot2,EEG_ave2.times,title_text2,legend_text,...
    poi.time,plot_ylim);

%export
plot_struct1.data = data_plot1;
plot_struct1.legend_text = legend_text;
plot_struct1.title_text= title_text1;
plot_struct2.data = data_plot2;
plot_struct2.legend_text = legend_text;
plot_struct2.title_text= title_text2;

ncond = length(cond_selected);
for i = 1:ncond
    group_plot = [data_plot1(i,:);data_plot2(i,:)];
    legend_text = {EEG_ave1.group_name, EEG_ave2.group_name};
    title_text = [poi.name '_' EEG_ave.eventtypes{i}];
    plot_1ERP_poi_ave(group_plot,EEG_ave1.times,title_text,legend_text,...
    poi.time,plot_ylim);
end
end

function EEG_ave_partial = EEG_ave_take_partial(EEG_ave,index,group_name)

    EEG_ave_partial = EEG_ave;
    all_fieldnames = fieldnames(EEG_ave);
    for i = 1:length(all_fieldnames)
        cfieldname = all_fieldnames{i};
        if length(cfieldname) > length('_original')
            if strcmp(cfieldname(end-8:end),'_original')==1
                EEG_ave_partial = rmfield(EEG_ave_partial,cfieldname);
            end
        end
    end
    
    EEG_ave_partial.nsubject = length(index);
    EEG_ave_partial.ID = EEG_ave.ID(index);
    EEG_ave_partial.data = EEG_ave.data(:,:,:,index);
    EEG_ave_partial.group_name = group_name;
    fprintf('%s, n = %d\n', group_name,length(index));
end