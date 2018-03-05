%20171106, compose from all categories
%20171107, added oscillation_split, added the option of not removing
%filename and setname when they don't exist
%20171108, fixed a bug about oscillation_split

function oscillation_multi = ITC_recompose_multi(data_path,...
    info_list,id_list,condition_index_of_interest)

m = 1;
    for i = 1:length(info_list.id)
%    for i = 1:5
        id = info_list.id{i};
        condition_index = info_list.condition_index(i);
        condition_index_in_dataset = find(condition_index_of_interest==condition_index,1);
        if isempty(condition_index_in_dataset)
            continue;
        end
        for j = 1:length(id_list)
            if strcmp(id_list{j},id)
                id_index = j;
                break
            end
        end
        filename = info_list.filename{i};
        fprintf('loading %s......\n',filename);
        load([data_path filename]);
        if exist('oscillation_split','var')
            oscillation = oscillation_split;
        end
        if m == 1
           oscillation_multi = oscillation;
           oscillation_multi = rmfield(oscillation_multi,'id');
           oscillation_multi.id = id_list;
           oscillation_multi.condition_index_of_interest = condition_index_of_interest;
           if isfield(oscillation_multi,'filename');
               oscillation_multi = rmfield(oscillation_multi,'filename');
           end
           if isfield(oscillation_multi,'setname');
               oscillation_multi = rmfield(oscillation_multi,'setname');
           end
           oscillation_multi.category_names{condition_index_in_dataset} = info_list.condition_name{i};
           filled_category = [];
           filled_category = [filled_category, condition_index_in_dataset];
           m = m + 1;
        end
        if ~isequal(sort(filled_category),1:length(condition_index_of_interest))
            oscillation_multi.category_names{condition_index_in_dataset} = info_list.condition_name{i};
        end
        
        oscillation_multi.ERSP(:,:,:,condition_index_in_dataset,id_index) = oscillation.ERSP;
        oscillation_multi.ITC(:,:,:,condition_index_in_dataset,id_index) = oscillation.ITC;
    end
end