%convert single condition segmented file win or lose into set
%baseline is 1000;

function raw_to_set_single(baseline)
    [~,pathname] = uigetfile('*.raw',pwd);
    pathname_set = strrep(pathname,'raw','set');
    mkdir(pathname_set);
    file_list = dir(pathname);
    
    for i = 1:length(file_list)
        temp = file_list(i).name;
        fnl = length(temp);
        if strcmp(temp(1),'.')~=1 && strcmp(temp(fnl-3:fnl),'.raw')
            filename = temp;
            if strcmp(temp(fnl-7:fnl-4),'lose')
                condition_name = 'lose';
            elseif strcmp(temp(fnl-6:fnl-4),'win')
                condition_name = 'win';
            else
                condition_name = '';
            end
            id = find_id(filename);
            fprintf('%s\n',id);
            EEG = pop_readegi([pathname filename]);
            EEG.baseline = baseline;
            EEG.xmin = EEG.xmin - baseline/1000;
            EEG.xmax = EEG.xmax - baseline/1000;
            EEG.times = EEG.times - baseline;
            pop_saveset(EEG,'filepath',pathname_set,'filename',[id '_' condition_name]);
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