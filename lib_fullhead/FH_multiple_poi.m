%20201114, added exporting the final table
%20201030, put condition_selected into poi, makes more sense
%20201030, export multiple poi and plot
% a wrapper arond FH_story1_2
%EEG_ave could be multiple structures or just 1
%if EEG_ave is multiple, one should be corresponding to a group_name{i}
%multiple poi

function final_table = FH_multiple_poi(EEG_ave, poi, filename_export)
cond_selected = poi.condition_selected;

for j = 1:length(EEG_ave)
    for i = 1:length(poi)
        [doi,table_poi,data_plot,...
            data_plot_table] = FH_story1_2(EEG_ave(j),poi(i),cond_selected);
        if i==1
            table_group = table_poi;
        else
            table_group = join(table_group, table_poi);
        end
    end
    if j==1
        final_table = table_group;
    else
        final_table = [final_table; table_group];
    end
end
writetable(final_table, filename_export);
end