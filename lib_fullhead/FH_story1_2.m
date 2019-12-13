%20191211, added calculating peaks
%added stats_type to poi:
%'+' means positive peak
%'-' means negative peak
%'avg' means averaged amplitude
%output doi, which is a copy of poi plus the data for output

%for comparing condition difference.
%20190306, input EEGAVE, place of interest, and condition selected
%do paird sampled t tests of selected conditions at place of interest
%and make plots of the whole region
%poi.name, cluster, time
%EEGAVE data, chan x time x subj x cond
%20190402, added time_range_to_plot
%20191017, change data to chan x time x ncond x subj
%20191115, fixed underscore for legend
function doi = FH_story1_2(EEGAVE,poi,cond_selected,time_range_to_plot)
if nargin==3
   time_range_to_plot = [EEGAVE.times(1),EEGAVE.times(end)];
end
%   time_index = find_valid_pos(poi.time,EEGAVE.times);
    time_range_to_plot_index = find_valid_pos(time_range_to_plot,EEGAVE.times);

%    data = EEGAVE.data(poi.cluster,time_index(1):time_index(2),cond_selected,:);
fprintf('\n\nSummary:\npoi name: %s\n',poi.name);
fprintf('poi channel: ');
for i = 1:length(poi.cluster)
    fprintf('%d ',poi.cluster(i));
end
fprintf('\npoi time: %d to %d ms\n',poi.time(1),poi.time(2));
fprintf('poi stats type: %s\n',poi.stats_type);

    if strcmp(poi.stats_type,'avg')==1
        data_ttest = calc_avgtimechan_simple(EEGAVE.data,EEGAVE.times,poi)';
        doi.data_avg = [EEGAVE.ID,data_ttest];
        %ttest
        for i = 1:length(cond_selected)-1
            for j = i+1:length(cond_selected)
                [h,p,~,stats] = ttest(data_ttest(:,i),data_ttest(:,j));
                fprintf('%s vs. %s', EEGAVE.eventtypes{cond_selected(i)},EEGAVE.eventtypes{cond_selected(j)});
                print_t_result(h,p,stats);
            end
        end
    
    else
        [peak_amplitude,peak_latency] = calc_pickpeaking_simple(EEGAVE.data,...
            EEGAVE.times,poi,poi.stats_type);
        for i = 1:length(cond_selected)-1
            for j = i+1:length(cond_selected)
                [h,p,~,stats] = ttest(peak_amplitude(i,:),peak_amplitude(j,:));
                fprintf('amplitude: %s vs. %s', EEGAVE.eventtypes{cond_selected(i)},EEGAVE.eventtypes{cond_selected(j)});
                print_t_result(h,p,stats);
                [h,p,~,stats] = ttest(peak_latency(i,:),peak_latency(j,:));
                fprintf('latency: %s vs. %s', EEGAVE.eventtypes{cond_selected(i)},EEGAVE.eventtypes{cond_selected(j)});
                print_t_result(h,p,stats);
            end
        end
        doi.data_amplitude = [EEGAVE.ID,peak_amplitude'];
        doi.data_latency = [EEGAVE.ID,peak_latency'];
    end
    
    %t tests
    %plot
    data_plot = EEGAVE.data(poi.cluster,time_range_to_plot_index(1):time_range_to_plot_index(2),cond_selected,:);
    data_plot = squeeze(mean(mean(data_plot,1),4));
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
    legend(EEGAVE.eventtypes{cond_selected},'interpreter','none');
    title(poi.name,'interpreter','none');
    
    %compose output table(s)
    vnames = cell(1);
    vnames{1} = 'ID';
    if ~exist('export','dir')
        mkdir('export');
    end
    if strcmp(poi.stats_type,'avg')==1
        for i = 2:length(cond_selected)+1
            vnames{i} = [EEGAVE.eventtypes{cond_selected(i-1)} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
        end
        output_table = array2table(doi.data_avg,'VariableNames',vnames);
        writetable(output_table,['export/export_' poi.name '_avg.csv']);
    else
        for i = 2:length(cond_selected)+1
            vnames{i} = [EEGAVE.eventtypes{cond_selected(i-1)} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
            vnames{i} = [vnames{i} '_amplitude'];
        end
        output_table = array2table(doi.data_amplitude,'VariableNames',vnames);
        writetable(output_table,['export/export_' poi.name '_amplitude.csv']);
        for i = 2:length(cond_selected)+1
            vnames{i} = [EEGAVE.eventtypes{cond_selected(i-1)} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
            vnames{i} = [vnames{i} '_latency'];
        end
        output_table = array2table(doi.data_latency,'VariableNames',vnames);
        writetable(output_table,['export/export_' poi.name '_latency.csv']);
    end     
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

