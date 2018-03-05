%20170927

%first load data_struct and rating_struct;
%data_struct must have id, data
%data dimension must be nchan x ndpt x ncond x nsubj
%rating_struct must have id, and various feilds of ratings
%input the name of one rating that is of interest
%20171107 dynamic baseline, put reports in a folder
%20171114 added compatability for noname, groupname
%20171130, minor addition, added report_all = 
function report_all = do_data_rating_struct(data_struct,rating_struct,rating_name)

data = data_struct.data;
rating = rating_struct.(rating_name);
data_id = data_struct.id;
rating_id = rating_struct.id;


%need channel x datapoint x subject
for i = 1:size(data,3)
    data1 = squeeze(data(:,:,i,:));
    baseline = -data_struct.xmin*1000;
    srate = data_struct.srate;
    dependency = 'pdep';
    channel_list = 1:data_struct.nbchan;
    report = do_cond_rating_fdr_v2(data1, rating, data_id, ...
    rating_id, baseline,srate,dependency,channel_list);
    report.name = [rating_name '_' data_struct.category_names{i}];
    report.srate = srate;
    report.channel_list = channel_list;
    report_all(i) = report;
end
if ~exist('report/')
    mkdir('report/');
end
if isfield(data_struct,'name')
    report_name = ['report_' rating_name '_' data_struct.name];
else if isfield(data_struct,'group_name')
        report_name = ['report_' rating_name '_' data_struct.group_name];
    else
        report_name = ['report_' rating_name '_noname'];
    end
end
save(['report/' report_name], 'report_all');

%for plotting
%load report_all_ostracism_cyberball;
%net_type = 1;
%alpha_level = 0.05;
%channel_list = 1:129;
%srate = 1000;
%plot_selected_channels_p_log_wholehead_2016(report_all(5),...
%    channel_list,net_type,srate,alpha_level);

end