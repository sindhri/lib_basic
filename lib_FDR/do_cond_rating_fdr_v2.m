%data is channel x datapoint x subject
%rating is subject x value
%2011-09-07, added count for sig without FDR.

%2012-02-29
%added dependency as a parameter, so it calculates negative dependency

%2013-05-01
%added squeeze the data

%2013-11-19
%added to eliminate nan

%20160802, added srate
%removed alleeg dependency, input baseline and srate
%20170926
%sort the data and id before caculation
%remove subject_list
%clear some nargins
%20171114, removed converting id to double

function report = do_cond_rating_fdr_v2(data, rating, data_id, ...
    rating_id, baseline,srate, dependency,channel_list)


baseline_dps = baseline/(1000/srate); %in terms of datapoint

[data, rating,subject_list] = preprocess_unmatched_data_rating_v3(data,...
        rating, data_id, rating_id);

data = squeeze(data);
[~,ndatapoint,~] = size(data);

data = data(channel_list, baseline_dps+1 : ndatapoint,:);


[nchan,ndatapoint,~] = size(data);
fprintf('revised channel number is %d, revised datapoint number is %d\n',...
    nchan, ndatapoint);

r_list = zeros(nchan, ndatapoint);
p_list = zeros(nchan, ndatapoint);
p_list_sign = zeros(nchan, ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        temp_data = squeeze(data(i,j,:));

        n = length(temp_data);
        
        [r,p] = corrcoef(temp_data, rating);
        r_list(i,j) = r(1,2);
        p_list(i,j) = p(1,2);
        if r_list(i,j) > 0
            p_list_sign(i,j) = p_list(i,j);
        else
            p_list_sign(i,j) = - p_list(i,j);
        end
    end
    if mod(i,10) == 0
        fprintf('complete chan %d......\n',i);
    end
end

count = count_sig(p_list);
fprintf('%d tests were significant without FDR\n', count);
report.sigwithoutFDR = count;

[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    dependency,'yes');
report.channel_list = channel_list;
report.p_list = p_list;
report.p_sign = p_list_sign;
report.r_list = r_list;
report.n = n;
report.subject_list = subject_list;

end
