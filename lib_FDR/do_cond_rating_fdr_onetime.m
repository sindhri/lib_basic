%data is channel x datapoint x subject
%rating is subject x value
%2011-09-07, added count for sig without FDR.

%2012-02-29
%added dependency as a parameter, so it calculates negative dependency

%2013-05-01
%added squeeze the data

%2013-11-19
%added to eliminate nan
%20170420, data is channel x subject, all id match

function report = do_cond_rating_fdr_onetime(data, rating,dependency)

if nargin ==2
    dependency = 'pdep';
end
[nchan,nsubj] = size(data);

r_list = zeros(nchan, 1);
p_list = zeros(nchan, 1);
p_list_sign = zeros(nchan, 1);

fprintf('%d total test,',nchan);
for i = 1:nchan
        temp_data = data(i,:);
     
        [r,p] = corrcoef(temp_data, rating);
        r_list(i) = r(1,2);
        p_list(i) = p(1,2);
        if r_list(i) > 0
            p_list_sign(i) = p_list(i);
        else
            p_list_sign(i) = - p_list(i);
        end
end

count = count_sig(p_list);
fprintf('%d were significant without FDR\n', count);
report.sigwithoutFDR = count;

[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    dependency,'yes');

report.p_list = p_list;
report.p_sign = p_list_sign;
report.r_list = r_list;
report.nsubj = nsubj;
report.nchan = nchan;

end

function count = count_sig(p)

count = 0;

for i=1:size(p,1)
    for j = 1:size(p,2)
        if p(i,j)>0 && p(i,j)<.05
            count = count + 1;
        end
    end
end
end