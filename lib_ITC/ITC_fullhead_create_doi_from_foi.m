%input: 
%IE_struct, eitehr the struct of ITC or ERSP
%poi, point of interest, number of poi x 4 columns
%[f1,f2,t1,t2]
%IE_type, either 'ITC' or 'ERSP'
%export_text, whether to export text
%if there is only one cluster, only export 1 file for ITC or ERSP, easy
%combine by hand
%if there are more than one clusters, a little bit harder to combine, so
%don't export. use further tool to combine
%extra_filename, mostly for different montages

%export
%doi is a struct has
%poi
%data
%label
%id

%2014903, total rewrite of ITC_export_mean_max

%20140929, a bug about fprintf can not print string that reads 'error'.
%should avoid using 'error' as variable names.

%20141106, input channel of interest and only output that channel or an
%average of a cluster

%20150919, if ncond==1, no post test
%20150920, fixed bug for 1 cond situation

%20160211, small adjustment to ITC_create_doi_fullhead, removed group_name,
%added chan_cluster's name, removed IE_type, because there is only one type
%now from ITC_fullhead_recompose, 
%cluster.channel, cluster.name

%channel, frequency, time, all three inputs, need rewrite to be able to do 
%more than one cluster

%data structure has changed, 
%now the input structure is freq x time x condition x channel x subj
%20171003, added group name in ttests export

%20190212, start from foi, which is already averaged across frequency
%thus poi is changed to toi, IE_struct change to foi_struct
%rearranged ttests output, output all the condition comparisons
%simplifed data dimension change by using reshape

function doi = ITC_fullhead_create_doi_from_foi(foi_struct,cluster,toi,...
    oscillation_type,export_text)

chan_cluster = cluster.channel;

foi_struct.cluster = cluster;


doi_mean = get_doi(foi_struct,toi,'mean',chan_cluster,oscillation_type);
doi_max = get_doi(foi_struct,toi,'max',chan_cluster,oscillation_type);
doi = doi_combine_mean_max(doi_mean,doi_max);

if export_text == 'y' 
    doi_export_2d_to_text(doi);
end

end


%added extra_filename to the end of the export file
%add extra_label to the begining of each label, only for within subject
%variable such as montage, not for group_name
function [extra_filename,extra_label] = construct_extra_names(montage_name,group_name)
    if isempty(montage_name) && isempty(group_name)
        extra_filename = '';
        extra_label = '';
    end
    if isempty(montage_name) && ~isempty(group_name)
       extra_filename = strcat('_', group_name);
       extra_label = '';
    end
    if ~isempty(montage_name) && isempty(group_name)
        extra_filename = strcat('_', montage_name);
        extra_label = strcat(montage_name,'_');
    end
    if ~isempty(montage_name) && ~isempty(group_name)
        extra_filename = strcat('_', montage_name, '_', group_name);
        extra_label = strcat(montage_name,'_');
    end
end

function doi = get_doi(foi_struct,toi,result_type,chan_cluster,oscillation_type)

times = foi_struct.times;
cond_names = foi_struct.category_names;
nc = length(cond_names);
subject_list = foi_struct.id;
doi.oscillation_type = oscillation_type;

%need to change, no frequency dimension
data = mean(foi_struct.(oscillation_type)(:,:,chan_cluster,:),3); %average across chan_cluster
[ntimes,ncond,~,nsubj] = size(data);
data = reshape(data,[ntimes,ncond,nsubj]);
%data2 = zeros(ntimes,ncond,nsubj);
%data2(:,:,:) = data(:,:,1,:);
%data = data2;
%now the dimension is freq x time x cond x subj. avoid using squeeze
%because if the ncond is 1, it would reduce that dimension as well

if nc==2
    data(:,3,:) = data(:,1,:)-data(:,2,:);
    cond_names{3} = 'diff';
end

[extra_filename,extra_label] = construct_extra_names(foi_struct.cluster.name,foi_struct.group_name);


[toi_index,toi_adjusted] = adjust_toi(toi,times);
doi = doi_get_data(data,toi_index,result_type);

doi.oscillation_type = oscillation_type;
doi.foi = foi_struct.foi;
doi.toi = toi;
doi.toi_adjusted = toi_adjusted;
doi.toi_index = toi_index;

doi.cond_names = cond_names;
doi.id = subject_list;
doi.extra_label = extra_label;
doi.extra_filename = extra_filename;
doi.cluster = foi_struct.cluster;
doi.group_name = foi_struct.group_name;

doi = doi_create_label_2d(doi);
if nc>1
    doi_post_ttest(doi);
end

end

%toi = [200,300;...
%400,500;]
%two columns of starting and ending time
function [toi_index,toi_adjusted] = adjust_toi(toi,times)

toi_adjusted = zeros(size(toi));
toi_index = zeros(size(toi));

for i = 1:size(toi,1)
    [toi_index(i,1:2),toi_adjusted(i,1:2),adjusted1] = adjust_range(toi(i,1:2),times);

    if adjusted1 == 1
        fprintf('range of interest %d adjusted to:\n',i);
        fprintf('%d to %d ms\n',poi_adjusted(i,1),...
        poi_adjusted(i,2));
    end
end    
end


%internal function for adjust_poi
function [range_of_interest_index, ...
    range_of_interest_adjusted,adjusted]= adjust_range(range_of_interest,list)

range_of_interest_index = zeros(size(range_of_interest));

range_of_interest_adjusted = range_of_interest;

adjusted = 0;
for i = 1:size(range_of_interest,1) %rows
    for j = 1:size(range_of_interest,2) %columns
        target = range_of_interest(i,j);
        [index,target_adjusted] = find_index(target,list);
        range_of_interest_index(i,j)= index;
        range_of_interest_adjusted(i,j) = target_adjusted;
        if target ~= target_adjusted
            adjusted = 1;
        end
    end
end
end

%internal function for adjust_range
function [index, target_adjusted] = find_index(target, list)
index = 0;
for i = 1:length(list)-1
    diff = list(i)-target;
    if abs(list(i+1) - target) > abs(diff)
        index = i;
        target_adjusted = list(i);
        break;
    end
end
if index==0
    index = length(list);
    target_adjusted = list(length(list));
end
end

%get data for all rows of poi, getting either mean or max
%result_type is either mean or max
%doi is a struct
%doi.data is np x nc x ns
%doi.type identifies both ITC/ERSP and mean/max, for labelling purpose only 
function doi = doi_get_data(data,toi_index,result_type)

nt = size(toi_index,1);
[~,nc,ns] = size(data);
doi.data = zeros(nt,nc,ns);
doi.type = result_type;
doi.toi_index = toi_index;

for i = 1:nt
    t1 = toi_index(i,1);
    t2 = toi_index(i,2);

    if strcmp(result_type,'mean')==1
        doi_temp = mean(data(t1:t2,:,:),1); %data nc *ns
    else
        if strcmp(result_type,'max')==1
            doi_temp = max(data(t1:t2,:,:),[],1); %data nc *ns
        else
            fprintf('function not defined. Aborted\n');
            return
        end
    end
    doi.data(i,:,:) = doi_temp(1,:,:);
end
end

%create label and 2d data for all rows of poi
%IE_type is either ITC or ERSP
%result_type is either mean or max
%both types are only for labelling purpose

function doi = doi_create_label_2d(doi)

data = doi.data;
type = doi.type;
cond_names = doi.cond_names;
toi = doi.toi;
extra_label = doi.extra_label;
[nt,nc,ns] = size(data);

new_size = nt*nc;
data_2d = zeros(ns,new_size);

m = 0;
label_nosubject = cell(new_size,1);
%label{1} = 'Subject';

for i = 1:nt
    t1 = toi(i,1);
    t2 = toi(i,2);

    if nc>1
        new = squeeze(data(i,:,:))'; %change from cond x subj to subj x cond by transpose        
    else
        new = squeeze(data(i,:,:));
    end
        for n = 1:nc
            label_nosubject{m+n,1} = strcat(doi.oscillation_type, '_',...
                num2str(doi.foi(1)), '_', num2str(doi.foi(2)), 'Hz_',...
                extra_label, type, '_',...
            int2str(t1), '_', int2str(t2), 'ms_', cond_names{n});
            data_2d(:,m+n) = new(:,n);
        end
        
        m = m + n;
end
doi.data_2d = data_2d;
doi.label = label_nosubject;
end

%internal function
function temp = convert_frequency(f)
    temp = num2str(f);
    temp2 = find(temp=='.',1);
    if ~isempty(temp2)
        temp(temp2)='p';
    end
end


%compare all poi for the first two condition repeated measure t test
function doi_post_ttest(doi)

cond_names = doi.cond_names;
type = doi.type;
toi = doi.toi;
data = doi.data;

if strcmp(cond_names{2},'error')==1
    cond_names{2} = 'eerror';
end

fprintf('%s\n',doi.group_name)
nt = size(toi,1);

for i = 1:nt
    f1 = doi.foi(1);
    f2 = doi.foi(2);
    t1 = toi(i,1);
    t2 = toi(i,2);

    data1 = squeeze(data(i,:,:));
    for m = 1:length(cond_names)
        for n = m+1:length(cond_names)
            fprintf('%s,frequency %.2f to %.2f Hz, ',doi.oscillation_type,f1,f2);
            fprintf('time %d to %d ms\n',t1,t2);
            fprintf('%s %s vs. %s:',type, cond_names{m},cond_names{n});
            [h,p,~,stats] = ttest(data1(m,:)',data1(n,:)');
            print_t_result(h,p,stats);
            fprintf('\n');
        end
    end
end
end

%export data_2d and label, added 'Subject' to label
function doi_export_2d_to_text(doi)
data_2d = doi.data_2d;
type = doi.type;
extra_filename = doi.extra_filename;

for i = 1:length(doi.label)
    label{i,1} = doi.label{i};
end

%d = dataset({data_2d,label{:}},'obsnames',doi.id);
d = dataset({data_2d,label{:}},'obsnames',doi.id);
exported_filename = ['export_' type extra_filename '.txt'];
export(d,'file',exported_filename);

end


function doi =  doi_combine_mean_max(doi_mean,doi_max)
    doi.data_2d = [doi_mean.data_2d doi_max.data_2d];
    doi.type = strcat(doi_mean.type, '_', doi_max.type);
    doi.id = doi_mean.id;
    doi.label = doi_mean.label;
    doi.extra_filename = doi_mean.extra_filename;
    n = length(doi_mean.label);
    for i = 1:length(doi_max.label)
        doi.label(n+i,1) = doi_max.label(i,1);
    end
end

function print_t_result(h,p,stats)
    if h==0
        fprintf('not significant.\n');
    else
        fprintf('significant.\n');
    end
    fprintf('t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p);
end