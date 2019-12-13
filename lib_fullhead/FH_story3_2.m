%for comparing condition difference.
%20190306, input EEGAVE, place of interest, and condition selected
%do paird sampled t tests of selected conditions at place of interest
%and make plots of the whole region
%poi.name, cluster, time
%EEGAVE data, chan x time x subj x cond
%20190402, added time_range_to_plot
%20191017, change data to chan x time x ncond x subj
%20191111, group difference
function output_table = FH_story3_2(EEGAVE1, EEGAVE2,poi,cond_selected,time_range_to_plot)
    if nargin==4
        time_range_to_plot = [EEGAVE1.times(1),EEGAVE1.times(end)];
    end
    time_index = find_valid_pos(poi.time,EEGAVE1.times);
    time_range_to_plot_index = find_valid_pos(time_range_to_plot,EEGAVE1.times);
    data1 = EEGAVE1.data(poi.cluster,time_index(1):time_index(2),cond_selected,:);
    data2 = EEGAVE2.data(poi.cluster,time_index(1):time_index(2),cond_selected,:);
    data_ttest1 = mean(mean(data1,1),2);
    data_ttest1 = squeeze(data_ttest1)';
    data_ttest2 = mean(mean(data2,1),2);
    data_ttest2 = squeeze(data_ttest2)';
    output_data = [EEGAVE1.ID', data_ttest1;EEGAVE2.ID', data_ttest2];
    output_data1 = [EEGAVE1.ID', data_ttest1];
    output_data2 = [EEGAVE2.ID', data_ttest2];
    %t tests
    for i = 1:length(cond_selected)
        [h,p,~,stats] = ttest2(data_ttest1(:,i),data_ttest2(:,i));
        fprintf('%s in %s',EEGAVE1.eventtypes{cond_selected(i)},[EEGAVE1.group_name '_' EEGAVE2.group_name]);
            print_t_result(h,p,stats);
    end
    %plot
    data_plot1 = EEGAVE1.data(poi.cluster,time_range_to_plot_index(1):time_range_to_plot_index(2),cond_selected,:);
    data_plot1 = squeeze(mean(mean(data_plot1,1),4));
    data_plot2 = EEGAVE2.data(poi.cluster,time_range_to_plot_index(1):time_range_to_plot_index(2),cond_selected,:);
    data_plot2 = squeeze(mean(mean(data_plot2,1),4));
    figure;
%    color_lib = {'b','r','g','k','m','c'};
    for i = 1:length(cond_selected)
        subplot(1,length(cond_selected),i);
        plot(EEGAVE1.times(time_range_to_plot_index(1):time_range_to_plot_index(2)),data_plot1(:,i),'r');
        hold on
        plot(EEGAVE2.times(time_range_to_plot_index(1):time_range_to_plot_index(2)),data_plot2(:,i),'b');
        xlabel('Time (ms)');
    
    yl = ylim;
    plot([poi.time(1),poi.time(1)],[yl(1),yl(2)],'-.k');
    plot([poi.time(2),poi.time(2)],[yl(1),yl(2)],'-.k');
    legend({EEGAVE1.group_name,EEGAVE2.group_name});
    title(EEGAVE1.eventtypes{cond_selected(i)},'interpreter','none');
    end

    vnames = cell(1);
    vnames{1} = 'ID';
    for i = 2:length(cond_selected)+1
        vnames{i} = [EEGAVE1.eventtypes{cond_selected(i-1)} '_' poi.name '_' int2str(poi.time(1)) '_to_' int2str(poi.time(2)) 'ms'];
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

