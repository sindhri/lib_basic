%2013-02-19, added baseline_dpt
%cond1 and cond2 are 129x250x34 for NR_2010
%2010-08-23
%2011-09-06, added t_list to the report
%2011-09-06, fixed the p_sign bug.
%2011-09-07, added count for sig without FDR.

%2013-04-15, added channel_list
%2013-04-25, added squeeze
%20171107 removed all defaults, fixed baseline_dpt issue, need to input
%baseline_dpt datapoint, not just baseline_dpt
%there is another wapper for this function, do_2cond_struct, addes srate
%and channel_list and name to the report
%only use this function when you want to do a quick and easy comparison
%otherwise use 'do_2cond_struct'
function report = do_2cond_fdr(cond1, cond2, dependency,baseline_dpt,...
    channel_list)


%baseline_dpt = 25;
if nargin<5
    channel_list = read_channelclusters;
    channel_list = squeeze(channel_list{1});
end

cond1 = squeeze(cond1);
cond2 = squeeze(cond2);

[~,ndatapoint,~] = size(cond1);

cond1 = cond1(channel_list, baseline_dpt+1 : ndatapoint,:);
cond2 = cond2(channel_list, baseline_dpt+1 : ndatapoint,:);

[nchan,ndatapoint,~] = size(cond1);
fprintf('revised channel number is %d, revised datapoint number is %d\n',...
    nchan, ndatapoint);

H_list = zeros(nchan, ndatapoint);
p_list = zeros(nchan, ndatapoint);
p_list_sign = zeros(nchan, ndatapoint);
t_list = zeros(nchan, ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        temp1 = squeeze(cond1(i,j,:));
        temp2 = squeeze(cond2(i,j,:));
        n = length(temp1);
        [H,p,~,stats] = ttest(temp1, temp2);
        H_list(i,j) = H;
        p_list(i,j) = p;
        t_list(i,j) = stats.tstat;
        if mean(temp1) > mean(temp2)
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
report.n = length(cond1);
report.t_list = t_list;
report.baseline_dpt = baseline_dpt;

end