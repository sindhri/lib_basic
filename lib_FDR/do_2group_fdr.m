%2012-06-22
%group1 is 129x250x16, group2 is 129x250x22 
%2013-04-15, added channel_list
%2013-04-25, added squeeze
function report = do_2group_fdr(group1, group2, dependency,channel_list)

if nargin==2
    dependency = 'pdep';
end

if nargin<4
    channel_list = read_channelclusters;
    channel_list = squeeze(channel_list{1});
end

baseline = 25;

group1 = squeeze(group1);
group2 = squeeze(group2);

[~,ndatapoint,~] = size(group1);

group1 = group1(channel_list, baseline+1 : ndatapoint,:);
group2 = group2(channel_list, baseline+1 : ndatapoint,:);

[nchan,ndatapoint,~] = size(group1);
fprintf('revised channel number is %d, revised datapoint number is %d\n',...
    nchan, ndatapoint);

H_list = zeros(nchan, ndatapoint);
p_list = zeros(nchan, ndatapoint);
p_list_sign = zeros(nchan, ndatapoint);
t_list = zeros(nchan, ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        temp1 = squeeze(group1(i,j,:));
        temp2 = squeeze(group2(i,j,:));
        n = length(temp1);
        [H,p,~,stats] = ttest2(temp1, temp2);
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
report.n = n;
report.t_list = t_list;
report.baseline = baseline;