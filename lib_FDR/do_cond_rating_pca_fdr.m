%2/7/2011
%input: data, nchanx ncatapointxnsubject
%make sure the channel is either frontal or back, do not mix!
%input ratings, 
%2/24/2011, used prepross_unmatched_data_rating, share it with
%do_cond-rating_fdr


%03/10/2010, check all the available factors that has ..<0.4
%enable automation.

%2011-08-22, modified to fit new folder structure
%2011-09-07, added count for sig without FDR.

function [pcareport, factor_time, ...
    factorResults] = do_cond_rating_pca_fdr(data,...
    rating, data_id,...
    rating_id, subject_list)

if nargin==4
    subject_list = rating_id;
end

if nargin>2
    [data, rating, subject_list] = preprocess_unmatched_data_rating(data,...
        rating, data_id, rating_id, subject_list);
else
    [data, rating] = eliminate_zero(data, rating);
    subject_list = 1:length(rating);
end


baseline = 25;
[~, ndatapoint, nsubject] = size(data);

channel_list = read_channelclusters;
channel_list = squeeze(channel_list{1});


%prepare data for pca
data_for_pca = data(channel_list,:,:);

nFactor = 5;
%do PCA
factorResults = ep_doPCA('temp','VMAX',1,'COV',nFactor,...
    data_for_pca(:,baseline+1:ndatapoint,:),'K');


%analyze rotated matrix to get factor time
factor_time = analyze_rotatedmatrix_tpca(factorResults);


%average data based on factor time on the selected channels
p_data = data_avgdatapoint(data,convert_time2datapoint(factor_time));

p_data = p_data(channel_list,:,:);

r_list = zeros(size(p_data, 1), size(p_data, 2));
p_list = zeros(size(p_data, 1), size(p_data, 2));
p_list_sign = zeros(size(p_data, 1), size(p_data, 2));

%do all the ttests
for j = 1:size(p_data,2) %each factor
    for i = 1:size(p_data,1) %each chan
        temp_data = squeeze(p_data(i,j,:)); %all subjects
        n = length(temp_data);
        [r,p] = corrcoef(temp_data,rating);
        r_list(i,j) = r(1,2);
        p_list(i,j) = p(1,2);
        if r_list(i,j) > 0
            p_list_sign(i,j) = p_list(i,j);
        else
            p_list_sign(i,j) = -p_list(i,j);
        end
    end
end

for i = 1:size(factor_time,1)
    fprintf('current facotr %d\n',i);
    factor_of_interest = i;
    
    count = count_sig(p_list);
    fprintf('%d tests were significant without FDR\n', count);
    report.sigwithoutFDR = count;


    %FDR the interested factor
    [report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list(:,...
        factor_of_interest),0.05,'pdep','yes');
    report.ptable(:,1) = channel_list;
    report.ptable(:,2) = report.FDR_adj_p;
    report.ptable(:,3) = report.FDR_h;
    report.ptable(:,4) = p_list(:,factor_of_interest);
    report.ptable(:,5) = p_list_sign(:,factor_of_interest);

    report.sig_chan_list = report.ptable(report.ptable(:,3) == 1, 1);
    report.n = n;
    if nargin>2
        report.subject_list = subject_list;
    end

    if ~isempty(report.sig_chan_list)
        chan = report.sig_chan_list;
        p_data = data_avgdatapointchan(data, ...
            convert_time2datapoint(factor_time(factor_of_interest,:)),...
            chan);
        [afterfdr_r, afterfdr_p] = corrcoef(p_data, rating)
        report.afterfdr_r = afterfdr_r;
        report.afterfdr_p = afterfdr_p;
        report.processed_data = p_data;
        report.processed_rating = rating;
        export_data_rating(subject_list,p_data,rating);
    end
    pcareport{i} = report;
end
end

function export_data_rating(id,data,rating)

fid=fopen('data_export.txt','w');
fprintf(fid,'SID\tAmplitude\tRating\n');
for i=1:length(id)
    fprintf(fid,'%d\t%f\t%d\n',id(i),data(i),rating(i));
end
fclose(fid);
msgbox('data for correlation exported in ''data_export.txt''');
end
