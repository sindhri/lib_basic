%2011-09-07 added support for 1 dim data
%2014-07021, added support for 2 dim data
%20170914, added support for 4 dim data
%20170914, add the functionnality to use two unmatched list
%without inputting a common list
%instead generate a common list, use intersect
%20170918, added more report for removed data

function [data, rating, subject_list] = preprocess_unmatched_data_rating(data,...
    rating, data_id, rating_id,subject_list)

if nargin == 4
    [pick1, pick2, subject_list] = find_matched_subjects_from_lists(data_id,...
    rating_id);
else
    [pick1, pick2, subject_list] = find_matched_subjects_from_lists(data_id,...
    rating_id, subject_list);
end
report_removed(pick1,data_id,'data');
report_removed(pick2,rating_id,'rating');
fprintf('final subject list n= %d\n',length(subject_list));

switch length(size(data))
    case 1
        data = data(pick1);
    case 2
        data = data(:,pick1);
    case 3
        data = data(:,:,pick1);
    case 4
        data = data(:,:,:,pick1);
    otherwise
        fprintf('did not set up to process multiple dimension > 4\n');
        return
end

rating = rating(pick2);
[data, rating, subject_list] = eliminate_zero(data, rating, subject_list);
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

function report_removed(picked,id_list,id_list_name)
if length(picked) == length(id_list)
    fprintf('%s: n = %d, all included\n',id_list_name, length(id_list));
else
    complete_list = 1:length(id_list);
    diff = setdiff(complete_list,picked);
    fprintf('%s: n = %d, %d included\n',id_list_name,length(id_list),length(picked));
    fprintf('removed from list: ')
    if length(diff)>1
        for i = 1:length(diff)
                fprintf('%d\t',id_list(diff(i)));
        end
        fprintf('\n');
    else
        fprintf('%d\n',id_list(diff));
    end
end
end