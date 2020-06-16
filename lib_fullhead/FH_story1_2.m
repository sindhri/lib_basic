%20200318, use updated doi which has ID has it's own field
%not with amplitude/latency

%2020031, fixed bug on peakpicking vname generation
%20200204, moved the data_plot calculation out, removed
%'time_range_to_plot', changed function structure completely
%20200203, only export condition_selected, plotting line and dash
%20200113, output both latency and amplitude
%20200107, fixed a bug of not using all the conditions
%20191211, added calculating peaks
%added stats_type to poi:
%'+' means positive peak
%'-' means negative peak
%'avg' means averaged amplitude
%output doi, which is a copy of poi plus the data for output

%for comparing condition difference.
%20190306, input EEG_ave, place of interest, and condition selected
%do paird sampled t tests of selected conditions at place of interest
%and make plots of the whole region
%poi.name, cluster, time
%EEG_ave data, chan x time x subj x cond
%20190402, added time_range_to_plot
%20191017, change data to chan x time x ncond x subj
%20191115, fixed underscore for legend
%20200108, added exporting data_plot

%20200120, added group_name to the plot
%20200120, removed exporting individual
%amplitude and latency table, but only export the jointed table

function [doi,output_table,data_plot,...
    data_plot_table] = FH_story1_2(EEG_ave,poi,cond_selected)

EEG_ave = FH_select_condition(EEG_ave,cond_selected);

if isempty(EEG_ave.group_name)
    fprintf('\n\nSummary:\npoi name: %s\n',poi.name);
else
    fprintf('\n\nSummary:\ngroup name: %s\npoi name: %s\n',...
        EEG_ave.group_name,poi.name);
end
fprintf('poi channel: ');
for i = 1:length(poi.cluster)
    fprintf('%d ',poi.cluster(i));
end
fprintf('\npoi time: %d to %d ms\n',poi.time(1),poi.time(2));
fprintf('poi stats type: %s\n',poi.stats_type);

%t tests
doi = calc_doi_simple(EEG_ave,poi);    

%plot
data_plot = calc_data_plot(EEG_ave,poi);

if isempty(EEG_ave.group_name)
   title_text = poi.name;
else
   title_text = [EEG_ave.group_name '_' poi.name];
end

legend_text = EEG_ave.eventtypes;

plot_1ERP_poi_ave(data_plot,EEG_ave.times,title_text,legend_text,...
    poi.time);

output_table = export_output_table(poi,doi,EEG_ave);
data_plot_table=export_data_plot(EEG_ave,poi,data_plot);
end


function output_table = export_output_table(poi,doi,EEG_ave)
    %compose output table(s)
    vnames = cell(1);
    vnames{1} = 'ID';
    if ~exist('export','dir')
        mkdir('export');
    end
    
    ncond = length(EEG_ave.eventtypes);
    %export individual stats values
    if strcmp(poi.stats_type,'avg')==1
        for i = 2:(ncond+1)
            vnames{i} = [EEG_ave.eventtypes{i-1} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
        end
           ID = doi.ID;
        for i = 1:ncond
            temp = doi.data_avg(:,i);
            eval([vnames{i+1} '= temp;']); %super strange!!
        end
        temp_str = 'output_table = table(ID';
        for i = 1:ncond
            temp_str = strcat(temp_str,[',eval(vnames{' int2str(i+1) '})']);
        end
        temp_str = [temp_str ');'];
        eval(temp_str);
        output_table.Properties.VariableNames = vnames;
        if isempty(EEG_ave.group_name)
            writetable(output_table,['export/export_' poi.name '_avg.csv']);
        else
            writetable(output_table,['export/export_' EEG_ave.group_name '_' poi.name '_avg.csv']);
        end
    else
        for i = 2:(ncond+1)
            vnames{i} = [EEG_ave.eventtypes{i-1} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
            vnames{i} = [vnames{i} '_amplitude'];
        end
        ID = doi.ID;
        for i = 1:ncond
            temp = doi.data_amplitude(:,i);
            eval([vnames{i+1} '= temp;']); %super strange!!
        end
        temp_str = 'output_table1 = table(ID';
        for i = 1:ncond
            temp_str = strcat(temp_str,[',eval(vnames{' int2str(i+1) '})']);
        end
        temp_str = [temp_str ');'];
        eval(temp_str);
        output_table1.Properties.VariableNames = vnames;
%        output_table1 = array2table(doi.data_amplitude,'VariableNames',vnames);
%        writetable(output_table1,['export/export_' poi.name '_amplitude.csv']);

        for i = 2:(ncond+1)
            vnames{i} = [EEG_ave.eventtypes{i-1} '_'];
            vnames{i} = [vnames{i} poi.name '_' int2str(poi.time(1))];
            vnames{i} = [vnames{i} '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
            vnames{i} = [vnames{i} '_latency'];
        end
        for i = 1:ncond
            temp = doi.data_latency(:,i);
            eval([vnames{i+1} '= temp;']); %super strange!!
        end
        temp_str = 'output_table2 = table(ID';
        for i = 1:ncond
            temp_str = strcat(temp_str,[',eval(vnames{' int2str(i+1) '})']);
        end
        temp_str = [temp_str ');'];
        eval(temp_str);
        output_table2.Properties.VariableNames = vnames;

%        output_table2 = array2table(doi.data_latency,'VariableNames',vnames);
%        writetable(output_table2,['export/export_' poi.name '_latency.csv']);
        output_table = join(output_table1,output_table2);
        if isempty(EEG_ave.group_name)
            writetable(output_table,['export/export_' poi.name '_amplitude_latency.csv']);
        else
            writetable(output_table,['export/export_' EEG_ave.group_name '_' poi.name '_amplitude_latency.csv']);
        end
    end
 
end

function data_plot_table = export_data_plot(EEG_ave,poi,data_plot)
            %export data_plot
    for i = 1:length(EEG_ave.eventtypes)
        if isempty(EEG_ave.group_name)
            data_plot_rownames{i,1} = [poi.name '_' EEG_ave.eventtypes{i}];
        else
            data_plot_rownames{i,1} = [EEG_ave.group_name '_' poi.name '_' EEG_ave.eventtypes{i}];
        end
    end
    data_plot_vname = cell2table(data_plot_rownames,'VariableNames',{'vname'});
    data_plot_value = array2table(data_plot);
    data_plot_table = [data_plot_vname,data_plot_value];
    if isempty(EEG_ave.group_name)
        writetable(data_plot_table,['export/for_plot_' poi.name '.csv']);
    else
        writetable(data_plot_table,['export/for_plot_' EEG_ave.group_name '_' poi.name '.csv'])
    end
end