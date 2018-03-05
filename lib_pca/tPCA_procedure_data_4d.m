%2011-04-12
%data_4d is 4dim (use data(:,:,:,1) = cond1, data(:,:,:,2) = cond2)
%chan x datapoint x subject x condition
%which means all the subjects in one condition comes first
%then all the subjects in the next condition come next
%tested aganist tPCA_procedure in lib_FDR_jia using stacked data

function [result,result_header,factor_time, ...
    FactorResults_tpca, factor_time_peak] = tPCA_procedure_data_4d(data_4d,...
    n_tpca,condition_selected)

%step 1: from the 4th dimension, selected particular condition
if nargin==2
    condition_selected =1:size(data_4d,4);
end
data_4d = data_4d(:,:,:,condition_selected);

%step 4: average across channel clusters, at 1st dimension
data_avg = data_avgchannel(data_4d);

%step 2: stacking data, converting 4d data to 3d
data_3d = data_stacking(data_avg);

%step 3: remove baseline for preparing PCA. at the 2nd dimension
baseline = 25;
ndatapoint = size(data_4d,2);
data_blr = data_3d(:,baseline+1:ndatapoint,:);

%step 5å: temporal PCA
nFactor = n_tpca;
FactorResults_tpca = ep_doPCA('temp','PMAX',3,'COV',nFactor,data_blr,'K');

[factor_time,factor_time_peak, ...
    ~] = analyze_rotatedmatrix_tpca(FactorResults_tpca);

%average data based on factor time on the clusters
output = data_avgtime(data_avg,factor_time);

%current_fomat: cluster x factor x nsubject x ncond
%goal: nsubj x factor1cluster1cond1 + factor1cluster1cond2 +
%...factor2cluster1factor1

[result,result_header] = data_allocation(output);