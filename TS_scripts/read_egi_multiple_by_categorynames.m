%20130221, tried to group trials based on categoryname
%20130131, added file name validation

function alleeg = read_egi_multiple_by_categorynames(category_names)
    [~,pathname] = uigetfile('*.raw',pwd);
    file_list = dir(pathname);
%    category_names = {'go_correct','nogo_correct'};

    m = 1;
    for i = 1:length(file_list)
        temp = file_list(i).name;
        if strcmp(temp(1),'.')~=1 && strcmp(temp(length(temp)-3:length(temp)),'.raw')
            filename = temp;
            id = find_id(filename);
            fprintf('%s\n',id);
            EEG = pop_readegi([pathname filename]);
            category_names_count = EEG_list_trials(EEG,category_names);
            EEG.id = id;
            EEG.category_names_count = category_names_count;

            alleeg(m) = EEG;
            m = m+1;
        end
    end
end

function id = find_id(filename)
    for i = 1:length(filename)
        if ~isempty(str2num(filename(i)))
            continue
        else
            break
        end
    end
    id = filename(1:i-1);
end


%EEG after using read_egi
%list the trial numbers for each member in category_names
function category_names_counts = EEG_list_trials(EEG,category_names)
    n_category = length(category_names);
    n_trials = EEG.trials;
    category_names_counts = cell(n_category,3);
    
    for i = 1:n_category
        category_names_counts{i,1} = category_names{i};
    end
    
    for j = 1:n_category
        category_names_counts{j,2} = 0;
        category_names_counts{j,3} = [];
    end
    for j = 1:n_trials
        category = EEG.epoch(j).eventcategory{1};

        for p = 1:n_category
            if strcmp(category_names{p},category)==1        
                category_names_counts{p,2} = category_names_counts{p,2} + 1;
                category_names_counts{p,3} = [category_names_counts{p,3}, j];
                break
            end
        end
    end
end