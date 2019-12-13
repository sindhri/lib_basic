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

%update using struction on 20150526
%20180924, export all time duration for eoec
%20190325, export z values
%20190717, added fall back when maximum frequency of the list is reached

function [dataset_data,dataset_label] = coh_export_fulltime_z(COH,freq_want)

all_coh = COH.data;
timesout = COH.times;
freqsout = COH.freqs;
id_list = COH.id;
channel_names = COH.montage_name;

[nsubject,n_channelpair,ncond] = size(all_coh);

%freq_want = [8,12];
freq_datapoint_start=find(freqsout>freq_want(1),1);
freq_datapoint_end=find(freqsout>freq_want(2),1)-1;
if isempty(freq_datapoint_end)
    fprintf('reaching the highest frequency in the list, using the last data point\n');
    freq_datapoint_end = length(freqsout);
end

freq_datapoint = freq_datapoint_start:freq_datapoint_end;

total = length(id_list);

nogo=zeros(length(timesout),nsubject,n_channelpair);
go=zeros(length(timesout),nsubject,n_channelpair);
nogo_go=zeros(length(timesout),nsubject,n_channelpair);

x = timesout;

%each subject one row, then most inner is condition
% then time range
%then channel pair

dataset_data = zeros(total,ncond*n_channelpair);
dataset_label = cell(1);
name_freq = [int2str(freq_want(1)) '_' int2str(freq_want(2)) 'Hz'];

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
        nogo_export = mean(nogo(:,i,j),1);
        go_export = mean(go(:,i,j),1);
        diff_export = mean(nogo_go(:,i,j),1);

        %convert to z
        znogo_export = 0.5*(log(1+nogo_export) - log(1-nogo_export));
        zgo_export = 0.5*(log(1+go_export) - log(1-go_export));
        zdiff_export = 0.5*(log(1+diff_export) - log(1-diff_export));

        dataset_data(i,(j-1)*ncond+1:j*ncond) = [znogo_export,zgo_export,zdiff_export];
        
        if i==1
                dataset_label{m} = [channel_pair_name '_' name_freq '_' COH.category_names{1}];
                dataset_label{m+1} = [channel_pair_name '_' name_freq '_' COH.category_names{2}];
                dataset_label{m+2} = [channel_pair_name  '_' name_freq  '_' COH.category_names{3}];
            m = m + 3;          
        end
    end
end
A = dataset({dataset_data,dataset_label{:}},'ObsNames',id_list);
if isempty(COH.group_name)
    export(A,'file',['zexport_coh' name_freq '.txt']);
else
    export(A,'file',['zexport_coh_' name_freq COH.group_name '.txt']);
end