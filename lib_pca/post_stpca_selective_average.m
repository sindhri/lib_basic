%2013-05-06
%average amplitude based on spatial temporal pca result
%need to input manually for each interested component
%need more work, maybe put the selective on the data_avgtime,
%data_avgchannel level


%input 1, data, chan x datapoint x cond x subject
%input 2, time window
%input 3, cluster

%need more work

function [result, result_header] = post_stpca_selective_average(data,factor_time,channel_clusters)

%average data based on factor time on the selected channels
p_data = data_avgtime(data,factor_time);

p_data = data_avgchannel(p_data,channel_clusters);
%result: ncluster x nfactor x ncond x nsubject

[result,result_header] = data_allocation3(p_data);