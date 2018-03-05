%collection needs to have .id
%collection needs to have .data, in which data is organized as nsubject*ncond
%data should be nchan x ndatapoint x (nsubject*ncond)
%which means all the subjects in one condition comes first
%then all the subjects in the next condition come next

%2012-04-18. change doPCA to ep_doPCA, updated number of arguments
%updated analyze_rotated_matrix to analyze_rotatedmatrix_tpca

function [result,result_header,factor_time, FactorResults] = tPCA_procedure(collection)

data = collection.data;
nsubject = length(collection.id);
baseline = 25;
[~, ndatapoint, combinedn] = size(data);
ncond = combinedn/nsubject;

channel_list = read_channelclusters;
channel_list = squeeze(channel_list{1});

%prepare data for pca
data_for_pca = mean(data(channel_list,:,:),1);


nFactor = 1;
%do PCA
FactorResults = ep_doPCA('temp','VMAX',1,'COV',...
    nFactor,data_for_pca(:,baseline+1:ndatapoint,:),'K');

usable_factor = nFactor;
for i = 1:nFactor
    if isempty(find(FactorResults.FacPat(:,i)>0.4,1))
        usable_factor = i-1;
        break
    end
end
%analyze rotated matrix to get factor time
factor_time = analyze_rotatedmatrix_tpca(FactorResults);

%average data based on factor time on the selected channels
p_data = average_erp(data,change_time_to_datapoint(factor_time));

p_data = p_data(channel_list,:,:);

p_data = mean(p_data,1);
p_data = squeeze(p_data);%result: factor x nsubject*ncond


result = [];
result_header = cell(1,ncond*usable_factor);

%result: each subject is a row
%most inner, factor, outter, condition
%so f1,f2,f3etc for condition1, then f1,f2,f3 for condition2

for i = 1:ncond
    result = [result p_data(:,(i-1)*nsubject+1:i*nsubject)'];
    for j = 1:usable_factor
        result_header{(i-1)*usable_factor + j} = ['cond' int2str(i) 'factor' int2str(j) ];
    end
end