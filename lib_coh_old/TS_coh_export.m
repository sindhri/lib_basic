%20130225, modified channel_pairs to channel_names,read time_mean from tab
%file
%build a time.txt file using excel
%first column, mean for time1
%second column, mean time for time 2
%each row represents an individual
%save it as Tab-delimit file
%you can include the file within the raw file data folder

%read time_mean

%time_range, eg: [-500,0;0,500], calculate the average of each row
%to run, 
%dataset= coh_export(all_coh,timesout,freqsout,id_list,[-500,0;0,500]);
%dataset= coh_export(all_coh,timesout,freqsout,id_list,[-500,0;400,600]);

%20130130, need to manually make time_range, which is a matrix
%each row represents one subject
%each column is the center of the desired time, then expand 250ms to each
%side

%example of time_mean
%[-250,500;
%-250,400] 
%means:
%fist subject take first time period -500 to 0, second time period 250 to 750
%second subject take first time period -500 to 0, second time period 150 to 650

%data might not be long enough, then just go to the end of the data and report
%the situation

function [dataset_data,dataset_label] = TS_coh_export(all_coh,...
    timesout,freqsout,id_list,channel_names)

[filename,pathname] = uigetfile('*.txt','Choose the timing file');
time_mean = dlmread([pathname filename]);

if size(time_mean,1) ~= length(id_list)
    message('subject number mismatch between time file and imported eeg file, aborted\n');
    return
end
    
expand = 250;

[nsubject,n_channelpair,ncond] = size(all_coh);
if size(time_mean,1) ~=nsubject || nsubject~=length(id_list)
    fprintf('subject number mismatch, abort\n');
    return
end

ntime = size(time_mean,2);

freq_want = [8,12];
freq_datapoint_start=find(freqsout>freq_want(1),1);
freq_datapoint_end=find(freqsout>freq_want(2),1)-1;
freq_datapoint = freq_datapoint_start:freq_datapoint_end;

total = length(id_list);

nogo=zeros(length(timesout),nsubject,n_channelpair);
go=zeros(length(timesout),nsubject,n_channelpair);
nogo_go=zeros(length(timesout),nsubject,n_channelpair);

x = timesout;

%each subject one row, then most inner is condition
% then time range
%then channel pair

dataset_data = zeros(total,ntime*ncond*n_channelpair);
dataset_label = cell(1);
m = 1;

for j = 1:n_channelpair
    channel_pair_name = channel_names{j};
    for i = 1:nsubject

        nogo_temp = all_coh{i,j,1};
        go_temp = all_coh{i,j,2};
        nogo_go_temp = all_coh{i,j,3};
        nogo(:,i,j) = mean(nogo_temp(freq_datapoint,:),1)';
        go(:,i,j) = mean(go_temp(freq_datapoint,:),1)';
        nogo_go(:,i,j) = mean(nogo_go_temp(freq_datapoint,:),1)';
        
        for p = 1:ntime%export each time point
            time_mean_individual = time_mean(i,p);
            time_start = time_mean_individual - expand;
            time_end = time_mean_individual + expand;
            time_start_datapoint = find(x>time_start,1);
            time_end_datapoint = find(x>time_end,1)-1;
            if isempty(time_start_datapoint) || isempty(time_end_datapoint)
                fprintf('subject %s time %d ms not in range,return 0.\n',id_list{i},time_mean_individual);
                dataset_data(i,m:m+2) = [0,0,0];
            else
                nogo_export = mean(nogo(time_start_datapoint:time_end_datapoint,i,j),1);
                go_export = mean(go(time_start_datapoint:time_end_datapoint,i,j),1);
                diff_export = mean(nogo_go(time_start_datapoint:time_end_datapoint,i,j),1);
                dataset_data(i,m:m+2) = [nogo_export,go_export,diff_export];

            end
            if i==1
                dataset_label{m} = [channel_pair_name '_nogo_time' int2str(p)];
                dataset_label{m+1} = [channel_pair_name '_go_time' int2str(p)];
                dataset_label{m+2} = [channel_pair_name '_diff_time' int2str(p)];
            end
            m = m + 3;          
        end
        m = m - 6;
    end
    m = m + ntime*ncond;
end
A = dataset({dataset_data,dataset_label{:}},'ObsNames',id_list);
[filename,pathname] = uiputfile('*.txt','save the exported data as: ');
export(A,'file',[pathname, filename]);
end