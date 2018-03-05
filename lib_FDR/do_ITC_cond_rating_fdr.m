%20140325, modified it for ITC/ERSP

%data is channel x datapoint x subject
%rating is subject x value
%2011-09-07, added count for sig without FDR.

%2012-02-29
%added dependency as a parameter, so it calculates negative dependency

%2013-05-01
%added squeeze the data

%2013-11-19
%added to eliminate nan

function report_all = do_ITC_cond_rating_fdr(IE, rating_group,rating_name,...
    rating_id, subject_list, dependency)

for c = 1:size(rating_group,2) %rating group is subject x rating

    rating = rating_group(:,c);
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    fprintf('\n%s\n',rating_name{c});
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    [pick1, rating,common] = find_common_ids(IE,rating, rating_id, subject_list);

    for a = 1:2 %ERSP and ITC
        for b = 1:length(IE.ERSP_category)
            if a==1
                data = squeeze(IE.ERSP(:,:,b,:));
            else
                data = squeeze(IE.ITC(:,:,b,:)); %three dimension, freqxtimexsubject
            end
            data = data(:,:,pick1);
            report = do_ITC_one_cond_rating_fdr(IE,a,b,data,rating,dependency,common,rating_name{c});
            report_all(b,c,a) = report;
        end
    end

end
end

function [pick1, rating,common] = find_common_ids(IE,rating, rating_id,subject_list)

data_id = IE.id;

if iscell(data_id)
    data_id = str2double(data_id);
end
if iscell(rating_id)
    rating_id = str2couble(rating_id);
end
if iscell(subject_list)
    subject_list = str2double(subject_list);
end


[rating, rating_id] = eliminate_NAN(rating, rating_id);

[pick1, pick2, common] = find_matched_subjects_from_lists(data_id,...
    rating_id, subject_list);

fprintf('original data n = %d, rating n = %d, ',length(data_id),...
    length(rating_id));

data_id = data_id(pick1);
rating = rating(pick2);
rating_id = rating_id(pick2);

fprintf('common n = %d\n',length(common));
%fprintf('common id list: \n');
%for i = 1:length(common)
%    fprintf('%d\n',common(i));
%end

end





function report = do_ITC_one_cond_rating_fdr(IE,a,b,data,rating,dependency,common,rating_name)

nfreqs = IE.nfreqs;
ntimes = IE.ntimes;
times = IE.times;

if a==1
    category_name = IE.ERSP_category{b};
else
    category_name = IE.ITC_category{b};
end
fprintf('category %s\n',category_name);

baseline = find(abs(times)==min(abs(times)),1); %only pick 0 and after time points
data = data(:,baseline:ntimes,:);
for i = baseline:ntimes
    report.times(i-baseline+1) = times(i);
end
fprintf('only calculate %d ms to %d ms\n',times(baseline),times(ntimes));

newtimes = length(baseline:ntimes);


r_list = zeros(nfreqs, newtimes);
p_list = zeros(nfreqs, newtimes);
p_list_sign = zeros(nfreqs, newtimes);

for i = 1:nfreqs
    for j = 1:newtimes
        temp_data = squeeze(data(i,j,:));

        n = length(temp_data);
        
        [r,p] = corrcoef(temp_data, rating);
        r_list(i,j) = r(1,2);
        p_list(i,j) = p(1,2);
        if r_list(i,j) > 0
            p_list_sign(i,j) = p_list(i,j);
        else
            p_list_sign(i,j) = - p_list(i,j);
        end
    end
    if mod(i,10) == 0
        fprintf('complete frequency %.2f......\n',IE.freqs(i));
    end
end

count = count_sig(p_list);
fprintf('%d tests were significant without FDR\n', count);
report.sigWithoutFDR = count;

[report.FDR_h, report.FDR_crit_p, report.FDR_adj_p]=fdr_bh(p_list,0.05,...
    dependency,'yes');

report.sigAfterFDR = length(find(report.FDR_adj_p<.05));
report.p_list = p_list;
report.p_sign = p_list_sign;
report.r_list = r_list;
report.n = n;
report.subject_list = common;
report.category_name = category_name;
report.ITC_ERSP_index = a;
report.category_index = b;
report.rating_name = rating_name;
report.freqs = IE.freqs;

end


%input 2 or 3 lists
%output pick1, pick2, index of the common elements in all the lists
%relative to list1 and list2
%output common, the common elements

function [pick1, pick2, common] = find_matched_subjects_from_lists(list1,...
    list2, list3)

common = intersect(list1, list2);

if nargin == 3
    common = intersect(common, list3);
end

[~,pick1] = ismember(common, list1);
[~,pick2] = ismember(common, list2);
end


function [rating, rating_id] = eliminate_NAN(rating, rating_id)
    picked_unnan = ~isnan(rating);
    rating = rating(picked_unnan);
    rating_id = rating_id(picked_unnan);
end