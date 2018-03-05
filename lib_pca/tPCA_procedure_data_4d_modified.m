%2014-07-01, use chanxdatapoint x condition x subject

%2011-04-12
%data_4d is 4dim (use data(:,:,:,1) = cond1, data(:,:,:,2) = cond2)
%chan x datapoint x subject x condition
%which means all the subjects in one condition comes first
%then all the subjects in the next condition come next
%tested aganist tPCA_procedure in lib_FDR_jia using stacked data

function [result,result_header,factor_time, ...
    FactorResults_tpca, factor_time_peak] = tPCA_procedure_data_4d_modified(data_4d,...
    n_tpca,condition_selected)

if nargin==2
    condition_selected =1:size(data_4d,3);
end

data_4d = data_switch_dimension(data_4d);
[result,result_header,factor_time, ...
    FactorResults_tpca, factor_time_peak] = tPCA_procedure_data_4d(data_4d,...
    n_tpca,condition_selected);
end