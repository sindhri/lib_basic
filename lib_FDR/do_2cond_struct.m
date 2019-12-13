%20170927
%struct has field data
%the 3rd dimension is condition
%cond1, cond2 choose which two condition to compare
%a20171107 put result in a report folder, fixed baseline issue
%20171113, added group_name
%20190122, treat xmin in ms
function report = do_2cond_struct(data_struct,cond1,cond2)

data1 = data_struct.data(:,:,cond1,:);
data2 = data_struct.data(:,:,cond2,:);
dependency = 'pdep';
baseline_dpt = -(data_struct.xmin)*data_struct.srate/1000;
channel_list = 1:data_struct.nbchan;
report = do_2cond_fdr(data1, data2, dependency,baseline_dpt,channel_list);
report.net_type = data_struct.net_type;
report.chanlocs = data_struct.chanlocs;
report.nbchan = data_struct.nbchan;

if strcmp(data_struct.group_name,'') == 1
    report.name = ['diff_' data_struct.category_names{cond1} '_' data_struct.category_names{cond2}];
else
    report.name = ['diff_' data_struct.group_name '_' data_struct.category_names{cond1} '_' data_struct.category_names{cond2}];
end
report.srate = data_struct.srate;
report.channel_list = channel_list;

if ~exist('report/')
    mkdir('report/');
end
save(['report/' report.name],'report');

end