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
%20190401, 1cond, remove fulltime
function [dataset_data,dataset_label] = coh_export_1cond(COH,freq_want)

all_coh = COH.data;
timesout = COH.times;
freqsout = COH.freqs;
id_list = COH.id;
channel_names = COH.montage_name;

[nsubject,n_channelpair,ncond] = size(all_coh);

%freq_want = [8,12];
freq_datapoint_start=find(freqsout>freq_want(1),1);
freq_datapoint_end=find(freqsout>freq_want(2),1)-1;
freq_datapoint = freq_datapoint_start:freq_datapoint_end;

total = length(id_list);

nogo=zeros(length(timesout),nsubject,n_channelpair);

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
        nogo(:,i,j) = mean(nogo_temp(freq_datapoint,:),1)';
        nogo_export = mean(nogo(:,i,j),1);
        dataset_data(i,(j-1)*ncond+1:j*ncond) = nogo_export;

        if i==1
                dataset_label{m} = [channel_pair_name '_' name_freq '_' COH.category_names{1}];
            m = m + 1;          
        end
    end
end
A = dataset({dataset_data,dataset_label{:}},'ObsNames',id_list);
if isempty(COH.group_name)
    export(A,'file',['export_coh' name_freq '.txt']);
else
    export(A,'file',['export_coh_' name_freq COH.group_name '.txt']);
end