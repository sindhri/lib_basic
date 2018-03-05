%read single mat file one by one, build database chan x datapoint x cond x
%subject

%group is a two column variable, first column id, second column group
%for ifu, first column omitted all the zeros leading any other number

%only works for group 0 and 2 for now
function data = read_all_mat_files_by_group(categories,group)

[~,pathname] = uigetfile('.mat',pwd);
file_list = dir(pathname);

group_list = unique(group(:,2));
m = zeros(1,length(group_list));
data = cell(1);
nc = length(categories);

for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')==1
        continue;
    end
    [~,~,file_ext] = fileparts(temp);
    if strcmp(file_ext,'.mat')==1

        
        id = find_id(temp);
        id = remove_zeros(id);
        group_row = find(group(:,1)==str2double(id),1);
        group_id = group(group_row,2);
        group_id_in_list = find(group_list == group_id);
        
        load([pathname temp]);
        m(group_id_in_list) = m(group_id_in_list) + 1;
        fprintf('loading %s in group %d, size %d\n',temp, group_id, ...
            m(group_id_in_list));        
        for j = 1:nc
            data{group_id_in_list}(:,:,j,m(group_id_in_list)) = eval(categories{j});
        end

    end
end

end

function id = find_id(filename)
    first = [];
    last = [];
    for i = 1:length(filename)
        if ~isempty(str2num(filename(i))) && isempty(first)
            first = i;
            break
        end
    end
    for i = first+1:length(filename)
        if isempty(str2num(filename(i))) && isempty(last)
            last = i-1;
            break
        end
    end
    id = filename(first:last);
end

function new_id = remove_zeros(id)
    for i = 1:length(id)
        if strcmp(id(i),'0')==1
            continue;
        else
            new_id = id(i:length(id));
            break
        end
    end
end