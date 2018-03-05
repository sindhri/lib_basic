%2/7/2011
%input: data1, data2 are data of 2 conditions, nchanx ncatapointxnsubject
%make sure the channel is either frontal or back, do not mix!
%3/10/2011, automate, use more than one factors

%2011-09-07, added ttest_jia to report everything for t
%2011-09-07, added count for sig without FDR.

function [pcareport, factor_time, ...
    FactorResults] = do_2cond_pca_fdr(data1,data2, fdr_method)

if nargin==2
    fdr_method = 'pdep';
end

baseline = 25;
[~, ndatapoint, nsubject] = size(data1);

channel_list = read_channelclusters;
channel_list = squeeze(channel_list{1});

rnchan = length(channel_list);


%prepare data for pca
data_for_pca = zeros(rnchan,ndatapoint,2*nsubject);
data_for_pca(:,:,1:nsubject) = data1(channel_list,:,:);
data_for_pca(:,:,nsubject+1:2*nsubject) = data2(channel_list,:,:);

nFactor = 5;
%do PCA
FactorResults = ep_doPCA('temp','VMAX',1,'COV',nFactor,...
    data_for_pca(:,baseline+1:ndatapoint,:),'K');


%analyze rotated matrix to get factor time
factor_time = analyze_rotatedmatrix_tpca(FactorResults);
nFactor = size(factor_time,1);

%average data based on factor time on the selected channels
p_data1 = data_avgdatapoint(data1,convert_time2datapoint(factor_time));
p_data2 = data_avgdatapoint(data2,convert_time2datapoint(factor_time));

p_data1 = p_data1(channel_list,:,:);
p_data2 = p_data2(channel_list,:,:);

H_list = zeros(size(p_data1, 1), size(p_data1, 2));
p_list = zeros(size(p_data1, 1), size(p_data1, 2));
p_list_sign = zeros(size(p_data1, 1), size(p_data1, 2));

%do all the ttests
for j = 1:size(p_data1,2)
    for i = 1:size(p_data1,1)
        d1 = squeeze(p_data1(i,j,:));
        d2 = squeeze(p_data2(i,j,:));
        n = length(d1);
        [H_list(i,j),p_list(i,j)] = ttest(d1,d2);
        if mean(d1)>mean(d2)
            p_list_sign(i,j) = p_list(i,j);
        else
            p_list_sign(i,j) = -p_list(i,j);
        end
    end
end

for i = 1:nFactor   
    fprintf('current facotr %d\n',i);
    factor_of_interest = i;

    
    count = count_sig(p_list);
    fprintf('%d tests were significant without FDR\n', count);
    report.sigwithoutFDR = count;

    %FDR the interested factor
    
    [report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list(:,...
        factor_of_interest),0.05,fdr_method,'yes');
        
    report.ptable(:,1) = channel_list;
    report.ptable(:,2) = report.FDR_adj_p;
    report.ptable(:,3) = report.FDR_h;
    report.ptable(:,4) = p_list(:,factor_of_interest);
    report.ptable(:,5) = p_list_sign(:,factor_of_interest);

    report.sig_chan_list = report.ptable(report.ptable(:,3) == 1, 1);
    report.n = n;
    if ~isempty(report.sig_chan_list)
        chan = report.sig_chan_list;
        p_data1 = data_avgdatapointchan(data1,...
           convert_time2datapoint(factor_time(factor_of_interest,:)), chan);
        p_data2 = data_avgdatapointchan(data2,...
           convert_time2datapoint(factor_time(factor_of_interest,:)), chan);
        report.afterfdr_tresult = ttest_jia(p_data1, p_data2);
        export_data_2cond(p_data1,p_data2);
    end
    
    pcareport{i} = report;
end
end

function export_data_2cond(data1,data2)

fid=fopen('data_export.txt','w');
fprintf(fid,'SID\tdata1\tdata2\n');
for i=1:length(data1)
    fprintf(fid,'%d\t%f\t%f\n',i,data1(i),data2(i));
end
fclose(fid);
msgbox('data for correlation exported in ''data_export.txt''');
end