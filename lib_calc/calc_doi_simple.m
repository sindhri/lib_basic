%20200318, moved ID outside of amplitude and latency matrix
%because it can be string

%20200316, fixed bug on peakpicking's dependency on cond_selected
%20200204, removed cond_selected. it should be taken care of before this
%step
%20200203
%calcualte either mean amplitude or peak amplitude and latency for given
%doi, on EEG_ave
%and do ttests
%on cond_selected

function [doi,data_ttest] = calc_doi_simple(EEG_ave,poi)

ncond = length(EEG_ave.eventtypes);
    if strcmp(poi.stats_type,'avg')==1
        data_ttest = calc_avgtimechan_simple(EEG_ave.data,EEG_ave.times,poi)';
        doi.ID = EEG_ave.ID;
        doi.data_avg =data_ttest;
        %ttest
        for i = 1:ncond-1
            for j = i+1:ncond
                [h,p,~,stats] = ttest(data_ttest(:,i),data_ttest(:,j));
                fprintf('%s vs. %s ', EEG_ave.eventtypes{i},EEG_ave.eventtypes{j});
                print_t_result(h,p,stats);
            end
        end
    
    else
        [peak_amplitude,peak_latency] = calc_pickpeaking_simple(EEG_ave.data,...
            EEG_ave.times,poi,poi.stats_type);
        ncond = size(EEG_ave.data,3); %hack, used the 3rd dimension
        for i = 1:length(ncond)-1
            for j = i+1:length(ncond)
                [h,p,~,stats] = ttest(peak_amplitude(i,:),peak_amplitude(j,:));
                fprintf('amplitude: %s vs. %s', EEG_ave.eventtypes{i},EEG_ave.eventtypes{j});
                print_t_result(h,p,stats);
                [h,p,~,stats] = ttest(peak_latency(i,:),peak_latency(j,:));
                fprintf('latency: %s vs. %s', EEG_ave.eventtypes{i},EEG_ave.eventtypes{j});
                print_t_result(h,p,stats);
            end
        end
        doi.ID = EEG_ave.ID;
        doi.data_amplitude = peak_amplitude';
        doi.data_latency = peak_latency';
    end

end