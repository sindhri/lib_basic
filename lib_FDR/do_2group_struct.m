%2012-06-22
%group1 is 129x250x16, group2 is 129x250x22 
%2013-04-15, added channel_list
%2013-04-25, added squeeze
%2017-11-13, added more defaults, input struct that has regular EEGLAB
%attributes.

function report = do_2group_struct(struct1, struct2,select_one_condition)

    dependency = 'pdep';

    channel_list = 1:struct1.nbchan;
    baseline_dpt = -(struct1.xmin)*struct1.srate;

    %time x dpt x cond x subj
    group1 = squeeze(struct1.data(:,:,select_one_condition,:));
    group2 = squeeze(struct2.data(:,:,select_one_condition,:));

    [nchan, ndatapoint,~] = size(group1);

    group1 = group1(channel_list, baseline_dpt+1 : ndatapoint,:);
    group2 = group2(channel_list, baseline_dpt+1 : ndatapoint,:);
   
    ndatapoint_updated = length(baseline_dpt+1 : ndatapoint);
    
    fprintf('revised channel number is %d, revised datapoint number is %d\n',...
    nchan, ndatapoint_updated);

    H_list = zeros(nchan, ndatapoint_updated);
    p_list = zeros(nchan, ndatapoint_updated);
    p_list_sign = zeros(nchan, ndatapoint_updated);
    t_list = zeros(nchan, ndatapoint_updated);

    fprintf('processing condition %d, %s\n',select_one_condition,...
        struct1.category_names{select_one_condition});
    for i = 1:nchan
        for j = 1:ndatapoint_updated
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
report.baseline_dpt = baseline_dpt;
report.sig_count_noFDR = count;
report.ndatapoint = ndatapoint_updated;

report.name = ['diff_' struct1.category_names{select_one_condition} '_' struct1.group_name '_' struct2.group_name];
report.srate = struct1.srate;
report.chanlocs = struct1.chanlocs;
report.channel_list = channel_list;

if ~exist('report/')
    mkdir('report/');
end
save(['report/' report.name],'report');

end