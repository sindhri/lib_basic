%plot whole head waveform for single subject
%EEGAVE.data, chanx time x subj x cond
%20191017, changed data struct to chan x time x cond x subj
function FH_plot_wholehead_singlesubject(EEGAVE,condition_selected,subject_selected)

fprintf('plotting %d\n',EEGAVE.ID(subject_selected));
data_to_plot = zeros(129,EEGAVE.pnts);

for i = 1:length(condition_selected)
    data_to_plot(:,:,i) = EEGAVE.data(:,:,condition_selected(i),subject_selected);
end

ylimits = zeros(2,1);
ylimits(1) = min(min(min(data_to_plot,[],1),[],2),[],3);
ylimits(2) = max(max(max(data_to_plot,[],1),[],2),[],3);
ylimits = round(ylimits/2)*2;

color_library = {'b','r','g','k','m','c'};
figure;
plottopo(data_to_plot,'chanlocs',EEGAVE.chanlocs,...
    'legend',EEGAVE.eventtypes(condition_selected),...
    'showleg','on','ydir',1,'limits',[EEGAVE.xmin*1000, EEGAVE.xmax*1000,ylimits(1),ylimits(2)],...
    'colors',color_library(1:length(condition_selected)),'title',int2str(EEGAVE.ID(subject_selected)));
end