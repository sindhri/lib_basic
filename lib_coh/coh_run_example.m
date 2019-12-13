%20180920, example
%configured for gonogo TS
addpath('Users/wu/Documents/MATLAB/work/lib_basic/lib_coh/');
addpath(genpath('Users/wu/Documents/MATLAB/work/toobox/eeglab14_0_0b/functions/'));

%configuration
category_names = {'nogo_correct','go_correct'};
baseline= 1000;

channel_clusters = {{[36,35,29,30],[24,27,23,19]},...%pair 1
    {[36,35,29,30],[11,18,16,10]},... %pair2
    {[104,105,111,110],[11,18,16,10]},...%pair3
    {[104,105,111,110],[124,4,3,123]},...
    }; %pair4


%create cluster names and build montage structure
montage = coh_get_channel_pair_names(channel_clusters,1);


%import file and read data
alleeg = coh_read_egi_multiple_by_categorynames(category_names);


%calculate coherence
COH = coh_calculation(alleeg,montage,baseline);


%export alpha
[dataset_data,dataset_label] =coh_export(COH,[8,12]);

%plotting
coh_plot(COH,[8,12]);