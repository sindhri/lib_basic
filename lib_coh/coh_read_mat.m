%20130221, tried to group trials based on categoryname
%20130131, added file name validation
%20180920, read mat instead for eoec
%20190331, removed loading external chanlocs, not sure why it was there
%20190401, removed Tech_Markup, Markup
%20190824, added read_input_file to read .set

function alleeg = coh_read_mat(category_names, baseline,file_type)
if nargin==2
    file_type = 'mat';
end

if strcmp(file_type, 'mat')==1
    [~,pathname] = uigetfile('*.mat',pwd);
else
    [~,pathname] = uigetfile('*.set',pwd);
end
    file_list = dir(pathname);
%    category_names = {'go_correct','nogo_correct'};

    m = 1;
    for i = 1:length(file_list)
        temp = file_list(i).name;
        if strcmp(temp(1),'.')==1
            continue
        end
        if strcmp(temp(length(temp)-3:length(temp)),'.mat') || strcmp(temp(length(temp)-3:length(temp)),'.set')
            filename = temp;
            id = find_id(filename);
            fprintf('%s\n',id);
            EEG_old = read_input_file(pathname,filename,file_type);
            %EEG_old = read_mat_file(pathname, filename);
            EEG.filename = EEG_old.filename;
            EEG.filepath = EEG_old.pathname;
            EEG.srate = EEG_old.samplingRate;
            EEG.category_names = EEG_old.conditions;
            EEG.xmin = 0;
            EEG.xmax = EEG_old.duration;
            EEG.ncondition = length(category_names);
            EEG.data = [];
            EEG.trials = 0;
            for j = 1:EEG.ncondition
                current_condition_name = category_names{j};
                data_current_condition = EEG_old.(current_condition_name);
                ntrials = size(data_current_condition,3);
                if isempty(EEG.data)
                    EEG.data = data_current_condition;
                else
                    EEG.data(:,:,end+1:end+ntrials) = data_current_condition;
                end
                EEG.category_names_count{j,1} = current_condition_name;
                EEG.category_names_count{j,2} = ntrials;
                EEG.category_names_count{j,3} = EEG.trials + 1:EEG.trials + ntrials;
                EEG.trials = EEG.trials + ntrials;
           end
            EEG.nbchan = 129;
            EEG.pnts = EEG_old.samplingRate * EEG_old.duration;
            EEG.times = EEG.xmin*1000 : 1000/EEG.srate:EEG.xmax*1000 - 1000/EEG.srate;
            EEG.chanlocs = pop_readlocs('GSN-HydroCel-129plus3.sfp');
            EEG.urchanlocs = EEG.chanlocs;
        
          
            EEG.id = id;
            EEG.baseline = baseline;
            EEG.group_name = '';
            
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

function data = read_mat_file(pathname,filename)
    load([pathname filename]);
    data.filename = filename;
    data.pathname = pathname;
    data.samplingRate = samplingRate;
    clear filename;
    clear pathname;
    clear samplingRate;
    clear ECI_TCPIP_55513;
    clear Tech_Markup;
    clear Marks;
    clear esst_eeg;
    t = who;
    m = 1;
    n_datapoint= 0;
    for i = 1:length(t)
        variable_name = t{i};
        if length(variable_name) >=10 
            if strcmp(variable_name(1:10),'Impedances')==1
                continue;
            end
        end
        if strcmp(variable_name,'data') ~=1 
            data.conditions{m} = t{i};
            data.(data.conditions{m}) = eval([data.conditions{m}]);
            if n_datapoint ==0 
                n_datapoint = size(data.(data.conditions{m}),2);
            end
            m = m + 1;
        end
    end
    data.duration = n_datapoint/data.samplingRate;
end

function data = read_input_file(pathname,filename,file_type)
    if strcmp(file_type,'mat') == 1
        load([pathname filename]);
        data.filename = filename;
        data.pathname = pathname;
        data.samplingRate = samplingRate;
        clear filename;
        clear pathname;
        clear samplingRate;
        clear ECI_TCPIP_55513;
        clear Tech_Markup;
        clear Marks
        clear esst_eeg
        t = who;
        m = 1;
        n_datapoint= 0;
        for i = 1:length(t)
            variable_name = t{i};
            if length(variable_name) >=10 
                if strcmp(variable_name(1:10),'Impedances')==1
                    continue;
                end
            end
            if strcmp(variable_name,'data') ~=1 
                data.conditions{m} = t{i};
                data.(data.conditions{m}) = eval([data.conditions{m}]);
                if n_datapoint ==0 
                    n_datapoint = size(data.(data.conditions{m}),2);
                end
                data.ntrials(1,m) = size(data.(data.conditions{m}),3);
                m = m + 1;
            end
        end
        data.duration = n_datapoint/data.samplingRate;
    else
        addpath('/Users/wu/Documents/MATLAB/work/toolbox/eeglab14_0_0b/');
        addpath(genpath('/Users/wu/Documents/MATLAB/work/toolbox/eeglab14_0_0b/functions'));
        EEG = pop_loadset([pathname filename]);
        EEG = eeg_checkset(EEG);
        tempdata = EEG.data;
        data.filename = filename;
        data.pathname = pathname;
        data.samplingRate = EEG.srate;
        event = EEG.event;
        %check whether the first event is at the same latency as the second
        %event, if so remove the first.
        if event(1).latency == event(2).latency
            event(1) = [];
        end
        all_events = extractfield(event,'type');
        [unique_events,index_unique_events] = unique(all_events);
        n_condition = length(unique_events);
        
        n_datapoint= 0;
        for i = 1:n_condition
            variable_name = unique_events{i};
            data.conditions{i} = variable_name;
            event_indexes = find(strcmp(all_events,variable_name));
            unique_event_indexes = unique(extractfield(event(event_indexes),'epoch'));
            data.(variable_name) = tempdata(:,:,unique_event_indexes);
            data.ntrials(1,i) = size(tempdata,3);
            n_datapoint = size(tempdata,2);
        end
        data.duration = n_datapoint/data.samplingRate;
    end
end