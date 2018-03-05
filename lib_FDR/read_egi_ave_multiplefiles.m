%need to think about how to get id from filename for other projects

%30130322 made based on reading singletrial data
%removed .raw requirement, assuming all files are in correct format.

%20130226, added baseline, in terms of miliseconds, because this
%information is unavailable in raw format
%baseline defined as the period before time 0, not for calculation purpose
%20130221, tried to group trials based on categoryname
%20130131, added file name validation
%20160802, added srate
%change field id to ID;

function alleeg = read_egi_ave_multiplefiles(baseline)

    if nargin==0
        baseline = 100;
    end

    [~,pathname] = uigetfile('*.raw',pwd);
    file_list = dir(pathname);
    
    alleeg.ID = cell(1);
    m = 1;
    for i = 1:length(file_list)
        temp = file_list(i).name;
        if strcmp(temp(1),'.')~=1
            filename = temp;
            id = find_id(filename); %for sasha's data
            alleeg.ID{m,1} = id;
            fprintf('%s\n',id);
            EEG = pop_readegi([pathname filename]);
            if m == 1
                %initiate data
                alleeg.data = zeros(size(EEG.data));
 
 
                %read in category_names from file 1
                alleeg.category_names = cell(1);
                for j = 1:length(EEG.epoch)
                    if iscell(EEG.epoch(j).eventcategory)
                        alleeg.category_names{j,1} = EEG.epoch(j).eventcategory{1};
                    else
                        alleeg.category_names{j,1} = EEG.epoch(j).eventcategory;
                    end
                end
                alleeg.baseline = baseline;
                alleeg.xmin = EEG.xmin - baseline/1000;
                alleeg.xmax = EEG.xmax - baseline/1000;
                alleeg.times = EEG.times - baseline;
                alleeg.srate = EEG.srate;
            end
            alleeg.data(:,:,:,m) = EEG.data;
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

%find_id2, look for the first _ and use what's in front of it as an id
function id = find_id2(filename)
    for i = 1:length(filename)
        if strcmp(filename(i),'_')==1
            break
        end
    end
    id = filename(1:i-1);
end