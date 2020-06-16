%input: the folder of processed single trial EEG
%split them based on params.task_event_markers
%average, 
%make a combined average to fit the structure in EEG_ave
%20200107, fixed some bugs to fit general purposes
%20200115, added srate to EEG_ave
%20200117, fixed bug of not able to have task_event_markers that start with
%numbers because they can't be used in field names

function EEG_ave = EEGprocessed_to_EEGAVE(params,group_name)

if nargin==1
    group_name = '';
end
pathname = uigetdir('select the processed folder');
allfiles = dir(pathname);
allfiles = {allfiles.name};
allfiles = allfiles(~ismember(allfiles,{'.','..','.DS_Store'}));

eventtypes = params.task_event_markers;
neventtypes = length(eventtypes);

for i = 1:length(allfiles)
    filename = allfiles{i};
    EEG = pop_loadset([pathname filesep filename]);
    EEG_split = split_events(EEG,eventtypes);

    if i==1
        EEG_ave.group_name = group_name;
        EEG_ave = EEG_split;
        EEG_ave = rmfield(EEG_ave,'setname');
        for j = 1:neventtypes
            vname = ['cond' int2str(j)];
            EEG_ave = rmfield(EEG_ave,vname);
        end
        EEG_ave.data = zeros(EEG_split.nbchan,EEG_split.pnts,neventtypes,length(allfiles));
        EEG_ave.nsubject = length(allfiles);
        EEG_ave.ntrials = zeros(length(allfiles),length(params.task_event_markers));
    end
    EEG_ave.ID(i,1) =str2double(find_id(1,EEG_split.setname));

    for j = 1:neventtypes
        vname = ['cond' int2str(j)];
        EEG_ave.data(:,:,j,i) = mean(EEG_split.(vname),3);
        EEG_ave.ntrials(i,j) = size(EEG_split.(vname),3);
    end
end
end