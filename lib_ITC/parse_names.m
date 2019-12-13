%20180413, modifed find_condition_name
%20180424, used ITC_find_id general function, input id_type
%added condition_name_type

function [info_list,id_list] = parse_names(data_path,category_names,...
    id_type,condition_name_type)

%project_path = '/Users/MACG03/Desktop/RESEARCH/self_compassion_2016/cluster_SC_oscillation/';
%data_path = [project_path '/analysis/data/set_cyberball_result/'];
%category_names = {'favor','notmyturn','rej','cuefair','cuerej'};

if nargin == 2
    id_type = 1; %default, first number
    condition_name_type =2; %default, second underscore to first dot
end

file_list = dir(data_path);
m = 1;
for i = 1:length(file_list)
    filename = file_list(i).name;
    if filename(1) =='.';
        continue
    end
    
    
    id = ITC_find_id(id_type,filename);
    [condition_name,condition_index] = find_condition_name(filename,...
        category_names, condition_name_type);
    info_list.id{m,1} = id;
    info_list.condition_index(m,1) = condition_index;
    info_list.condition_name{m,1} = condition_name;
    info_list.filename{m,1} = filename;

    if isempty(condition_index)
        fprintf('error at %s,condition reported as %s\n',filename,condition_name);
    end
    m = m + 1;
end

id_list = unique(info_list.id);

end

%rmoved i from number
function id = find_id(filename)
    first = [];
    last = [];
    for i = 1:length(filename)
        current = filename(i);
        if current == 'i';
            continue;
        end
        if ~isempty(str2num(current)) && isempty(first)
            first = i;
            break
        end
    end
    for i = first+1:length(filename)
            current = filename(i);
        if isempty(str2num(current)) && isempty(last)
            last = i-1;
            break
        end
    end
    id = filename(first:last);
end

function condition_name = find_lu_to_ext(filename)
    nfilename = length(filename);
    underscores = find(filename=='_');
    condition_name = filename(underscores(length(underscores))+1:nfilename-4);
end

%find the string between the second underscore to first dot
%should only be applied to file that is strictly named this way
%such as the .set file and result file, name generated by scripts

function astring = find_string_2u_to_dot(filename)

  
    underscores = find(filename == '_');
    dots = find(filename == '.');
    astring = filename(underscores(2)+1:dots(1)-1);
    
end

function astring = find_string_3u_to_dot(filename)

    
    underscores = find(filename == '_');
    dots = find(filename == '.');
    astring = filename(underscores(3)+1:dots(1)-1);
    
end

function [condition_name,condition_index] = find_condition_name(filename,...
    category_names,condition_name_type)
    switch condition_name_type
        case 1 %
            condition_name = find_string_2u_to_dot(filename);
        case 2 %from second underscore to first dot
            condition_name = find_string_2u_to_dot(filename);
        case 3 %from third underscore to first dot
            condition_name = find_string_3u_to_dot(filename);
    end
    for i = 1:length(category_names)
        if strcmp(category_names{i},condition_name)==1
            condition_index = i;
            break
        end
    end

end
