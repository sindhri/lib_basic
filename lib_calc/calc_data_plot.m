%20200204, output ncond_selected x times
function data_plot = calc_data_plot(EEG_ave,poi)
%if isempty(EEG_ave.group_name)
%    fprintf('\n\nCalculating plotting data for:\npoi name: %s\n',poi.name);
%else
%    fprintf('\n\nCalculating plotting data for:\ngroup name: %s\npoi name: %s\n',...
%        EEG_ave.group_name,poi.name);
%end
%fprintf('poi channel: ');
%for i = 1:length(poi.cluster)
%    fprintf('%d ',poi.cluster(i));
%end
%fprintf('\npoi time: %d to %d ms\n',poi.time(1),poi.time(2));
%fprintf('poi stats type: %s\n',poi.stats_type);

time_range_to_plot_index = find_valid_pos([EEG_ave.times(1),EEG_ave.times(end)],EEG_ave.times);

data_plot = EEG_ave.data(poi.cluster,...
    time_range_to_plot_index(1):time_range_to_plot_index(2),:,:);
data_plot = squeeze(mean(mean(data_plot,1),4));
data_plot = data_plot';

end

function [items_pos, items_adjusted] = find_valid_pos(items,list)
    n = length(list);
    items_pos = round( (items-list(1))/(list(n)-list(1)) * (n-1))+1;
    items_pos(find(items_pos<1))=1;
    items_pos(find(items_pos>n))=n;
    items_adjusted = list(items_pos);
    
    for i = 1:size(items,1)
        for j = 1:size(items,2)
            if items(i,j)~=items_adjusted(i,j)
                fprintf('time %d adjusted to %d\n', items(i,j),items_adjusted(i,j));
            end
        end
    end
end