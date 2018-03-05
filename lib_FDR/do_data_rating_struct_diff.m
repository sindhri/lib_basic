%20170927

%first load data_struct and rating_struct;
%data_struct must have id, data
%data dimension must be nchan x ndpt x ncond x nsubj
%rating_struct must have id, and various feilds of ratings
%input the name of one rating that is of interest
%20170930, calculate the differencewave correlation

%20171107, report folder
function do_data_rating_struct_diff(data_struct,rating_struct,rating_name,cond1,cond2)

data = data_struct.data(:,:,cond1,:) - data_struct.data(:,:,cond2,:);
rating = rating_struct.(rating_name);
data_id = data_struct.id;
rating_id = rating_struct.id;


%need channel x datapoint x subject
%for i = 1:size(data,3)
i = 1;
    data1 = squeeze(data(:,:,i,:));
    baseline = 100;
    srate = data_struct.srate;
    dependency = 'pdep';
    channel_list = 1:data_struct.nbchan;
    report = do_cond_rating_fdr_v2(data1, rating, data_id, ...
    rating_id, baseline,srate,dependency,channel_list);
    report.name = ['report_' rating_name '_diff' data_struct.category_names{cond1} '_' data_struct.category_names{cond2}];
    report.srate = srate;
    report.channel_list = channel_list;

%end
if ~exist('report/')
    mkdir('report/');
end
report_name = report.name;
save(['report/' report_name], 'report');

%for plotting
%load report_all_ostracism_cyberball;
%net_type = 1;
%alpha_level = 0.05;
%channel_list = 1:129;
%srate = 1000;
%plot_selected_channels_p_log_wholehead_2016(report_all(5),...
%    channel_list,net_type,srate,alpha_level);

end