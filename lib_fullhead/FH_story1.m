%for comparing condition difference.
%20190306, input EEGAVE, place of interest, and condition selected
%do paird sampled t tests of selected conditions at place of interest
%and make plots of the whole region
%poi.name, cluster, time
%EEGAVE data, chan x time x subj x cond
%20190402, added time_range_to_plot
function output_table = FH_story1(EEGAVE,poi,cond_selected,time_range_to_plot)
    if nargin==3
        time_range_to_plot = [EEGAVE.times(1),EEGAVE.times(end)];
    end
    time_index = find_valid_pos(poi.time,EEGAVE.times);
    time_range_to_plot_index = find_valid_pos(time_range_to_plot,EEGAVE.times);
    data = EEGAVE.data(poi.cluster,time_index(1):time_index(2),:,cond_selected);
    data_ttest = mean(mean(data,1),2);
    data_ttest = squeeze(data_ttest);
    output_data = [EEGAVE.ID, data_ttest];
    %t tests
    for i = 1:length(cond_selected)-1
        for j = i+1:length(cond_selected)
            [h,p,~,stats] = ttest(data_ttest(:,i),data_ttest(:,j));
            fprintf('%s vs. %s',EEGAVE.eventtypes{cond_selected(i)},EEGAVE.eventtypes{cond_selected(j)});
            print_t_result(h,p,stats);
        end
    end
    %plot
    data_plot = EEGAVE.data(poi.cluster,time_range_to_plot_index(1):time_range_to_plot_index(2),:,cond_selected);
    data_plot = squeeze(mean(mean(data_plot,1),3));
    figure;
    color_lib = {'b','r','g','k','m','c'};
    for i = 1:length(cond_selected)
        plot(EEGAVE.times(time_range_to_plot_index(1):time_range_to_plot_index(2)),data_plot(:,i),color_lib{i});
        xlabel('Time (ms)');
        hold on;
    end
    yl = ylim;
    plot([poi.time(1),poi.time(1)],[yl(1),yl(2)],'-.k');
    plot([poi.time(2),poi.time(2)],[yl(1),yl(2)],'-.k');
    legend(EEGAVE.eventtypes{cond_selected});
    title(poi.name,'interpreter','none');
    
    vnames = cell(1);
    vnames{1} = 'ID';
    for i = 2:length(cond_selected)+1
        vnames{i} = [EEGAVE.eventtypes{cond_selected(i-1)} '_' poi.name '_' int2str(poi.time(1)) '_to_' int2str(poi.time(2)) 'ms'];
    end
    output_table = array2table(output_data,'VariableNames',vnames);

     
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


function print_t_result(h,p,stats)
    if h==0
        fprintf(' not significant.\n');
    else
        fprintf(' significant.\n');
    end
    fprintf('t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p);
end

