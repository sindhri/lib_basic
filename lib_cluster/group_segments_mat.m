%20200116, from processed file to single trial with segments grouped
%also save as mat
%20200116, do not do average, export single trial
%For FFT
function EEG_split = group_segments_mat(params)

pathname = uigetdir('select the processed folder');
allfiles = dir(pathname);
allfiles = {allfiles.name};
allfiles = allfiles(~ismember(allfiles,{'.','..','.DS_Store'}));


for i = 1:length(allfiles)
    filename = allfiles{i};
    %check load and noload, between the second and third _
    EEG_singletrial = pop_loadset([pathname filesep filename]);
    
    EEG_split = split_events(EEG_singletrial,params.task_event_markers);
    eventtypes = params.task_event_markers;
    for j = 1:length(eventtypes)
        temp_data = EEG_split.(eventtypes{j});
        eval([eventtypes{j} '= temp_data;' ]);
    end
    
    save_filename = filename(1:8);
    all_fileseps = find(pathname==filesep);
    save_pathname = pathname(1:all_fileseps(end));
    if ~exist([save_pathname 'mat'],'dir')
        mkdir([save_pathname 'mat']);
    end
    save([save_pathname 'mat' filesep save_filename],eventtypes{:});
end
    
end