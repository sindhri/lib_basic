%2013-02-19, added baseline
%cond1 and cond2 are 129x250x34 for NR_2010
%2010-08-23
%2011-09-06, added t_list to the report
%2011-09-06, fixed the p_sign bug.
%2011-09-07, added count for sig without FDR.

%2013-04-15, added channel_list
%2013-04-25, added squeeze
%20170420, only on one timepoint, or one average

function report = do_2cond_fdr_onetime(cond1, cond2, dependency)

if nargin==2
    dependency = 'pdep';
end
nchan = size(cond1,1);

cond1 = squeeze(cond1);
cond2 = squeeze(cond2);

H_list = zeros(nchan, 1);
p_list = zeros(nchan, 1);
p_list_sign = zeros(nchan, 1);
t_list = zeros(nchan, 1);

for i = 1:nchan
        temp1 = squeeze(cond1(i,:));
        temp2 = squeeze(cond2(i,:));
        n = length(temp1);
        [H,p,~,stats] = ttest(temp1, temp2);
        H_list(i,1) = H;
        p_list(i,1) = p;
        t_list(i,1) = stats.tstat;
        if mean(temp1) > mean(temp2)
            p_list_sign(i,1) = p_list(i,1);
        else
            p_list_sign(i,1) = - p_list(i,1);
        end
end

count = count_sig(p_list);
fprintf('%d conducted, %d tests were significant without FDR\n', nchan, count);
report.sigwithoutFDR = count;
    
[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    dependency,'yes');

report.p_list = p_list;
report.p_sign = p_list_sign;
report.n = n;
report.t_list = t_list;
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