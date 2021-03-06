%2014903, total rewrite of ITC_export_mean_max

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

%20140929, a bug about fprintf can not print string that reads 'error'.
%should avoid using 'error' as variable names.
%20150311, removed montage_name, group_name, get them from IE input
%standardized group_name and montage_name as IE and doi fields

%20150608, keep the extra info in final dio after combining
%added group_name and montage_name in stats output

%20160907, hacked to get around cond_name{2}
%20160907, fixed bug for nc==1

%20180215, signal noise 
function doi = ITC_create_snr(IE_struct,...
    poi, IE_type, export_text)


doi = get_doi(IE_struct,poi,IE_type);


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

function doi = get_doi(IE_struct,poi,IE_type)

times = IE_struct.times;
freqs = IE_struct.freqs;
cond_names = IE_struct.category_names;
nc = length(cond_names);
subject_list = IE_struct.id;

if strcmp(IE_type,'ERSP')==1
    data = IE_struct.ERSP;
else
    if strcmp(IE_type,'ITC')==1
        data = IE_struct.ITC;
    else
        fprintf('type needs to be either ERSP or ITC. Abort\n');
        return
    end
end

%if nc==2
%    data(:,:,3,:) = data(:,:,1,:)-data(:,:,2,:);
%    cond_names{3} = 'diff';
%end

[extra_filename,extra_label] = construct_extra_names(IE_struct.montage_name,IE_struct.group_name);


[poi_index,poi_adjusted] = adjust_poi(poi,times,freqs);
doi = doi_get_data(data,poi_index);

doi.type = strcat(IE_type,'_snr'); 
doi.poi = poi;
doi.poi_adjusted = poi_adjusted;
doi.poi_index = poi_index;
doi.cond_names = cond_names;
doi.id = subject_list;
doi.extra_label = extra_label;
doi.extra_filename = extra_filename;
doi.montage_name = IE_struct.montage_name;
doi.montage_channel = IE_struct.montage_channel;
doi.group_name = IE_struct.group_name;

doi = doi_create_label_2d(doi);
doi_post_ttest(doi);

end

%poi = [4,8,200,300;...
%4,8,400,500;]
%first two columns frequency, last two column time
function [poi_index,poi_adjusted] = adjust_poi(poi,times,freqs)

poi_adjusted = zeros(size(poi));
poi_index = zeros(size(poi));

for i = 1:size(poi,1)
    [poi_index(i,1:2),poi_adjusted(i,1:2),adjusted1] = adjust_range(poi(i,1:2),freqs);
    [poi_index(i,3:4),poi_adjusted(i,3:4),adjusted2] = adjust_range(poi(i,3:4),times);

    if adjusted1 == 1 || adjusted2 == 1
        fprintf('range of interest %d adjusted to:\n',i);
        fprintf('%.2f to %.2f Hz,%d to %d ms, \n',poi_adjusted(i,1),...
        poi_adjusted(i,2),poi_adjusted(i,3),poi_adjusted(i,4));
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
%removed mean and max distinction
function doi = doi_get_data(data,poi_index)

np = size(poi_index,1);
[~,~,nc,ns] = size(data);
doi.data = zeros(np,nc,ns);
doi.type = 'snr';
doi.poi_index = poi_index;

for i = 1:np
    f1 = poi_index(i,1);
    f2 = poi_index(i,2);
    t1 = poi_index(i,3);
    t2 = poi_index(i,4);

    data_square = data(f1:f2,t1:t2,:,:); %nf x nt x nc x nsubj
    [~,~,nc,ns] = size(data_square);
    data_var = zeros(nc,ns);
    for m = 1:ns
        for n = 1:nc
            data_var(n,m) = calculate_variance(data(f1:f2,t1:t2,n,m));
        end
    end
    
    doi.data(i,:,:) = data_var;
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
poi = doi.poi;
extra_label = doi.extra_label;
[np,nc,ns] = size(data);

new_size = np*nc;
data_2d = zeros(ns,new_size);

m = 0;
label_nosubject = cell(new_size,1);
%label{1} = 'Subject';

for i = 1:np
    f1 = poi(i,1);
    f2 = poi(i,2);
    t1 = poi(i,3);
    t2 = poi(i,4);

    if nc>1
        new = squeeze(data(i,:,:))'; %change into subj x cond by transpose        
    else
        new = squeeze(data(i,:,:));
    end
        for n = 1:nc
            label_nosubject{m+n,1} = strcat(extra_label, type, '_',...
            convert_frequency(f1), '_', convert_frequency(f2), 'Hz',...
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
poi = doi.poi;
data = doi.data;

if length(cond_names)>1
    if strcmp(cond_names{2},'error')==1
        cond_names{2} = 'eerror';
    end
end


if length(cond_names)>1
    fprintf('%s %s\n',doi.group_name, doi.montage_name);
    fprintf([type ' ' cond_names{1} ' - ' cond_names{2} ' comparison: \n']);
    np = size(poi,1);

    for i = 1:np
        f1 = poi(i,1);
        f2 = poi(i,2);
        fprintf('frequency %.2f to %.2f Hz ',f1,f2);
        t1 = poi(i,3);
        t2 = poi(i,4);
        fprintf('time %d to %d ms\n',t1,t2);

        fprintf('%s\n',type);
        data1 = squeeze(data(i,:,:));
        [h,p,~,stats] = ttest(data1(1,:)',data1(2,:)');
            print_t_result(h,p,stats);
    fprintf('\n');
    end
end
end

%export data_2d and label, added 'Subject' to label
function doi_export_2d_to_text(doi)
data_2d = doi.data_2d;
type = doi.type;
subject_list = doi.id;
extra_filename = doi.extra_filename;

for i = 1:length(doi.label)
    label{i,1} = doi.label{i};
end

d = dataset({data_2d,label{:}},'obsnames',subject_list);
exported_filename = ['export_' type extra_filename '.txt'];
export(d,'file',exported_filename);

end




function print_t_result(h,p,stats)
    if h==0
        fprintf('not significant.\n');
    else
        fprintf('significant.\n');
    end
    fprintf('t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p);
end

function data_var = calculate_variance(data) %data is nf x nt
    [nf,nt] = size(data);
    data_var = 0;
    for i = 1:nf
        for j = 1:nt
            data_var = data_var + data(i,j)^2;
        end
    end
    data_var = data_var/nt/nf;
end