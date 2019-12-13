%20130225
%configuration
%categorynames, baseline and channel cluster configuration
category_names = {'nogo_correct','go_correct'};
baseline= 1000;
channel_clusters = {{[36,35,29,30,41,42,47],[24,27,23,19,28,20]},...%pair 1
    {[36,35,29,30,41,42,47],[11,18,16,10,12,5]},... %pair2
    {[104,105,111,110,103,93,87],[11,18,16,10,12,5]},...%pair3
    {[104,105,111,110,103,93,87],[124,4,3,123,118,117]},...
      }; %pair4


%create cluster names
channel_names = TS_get_channel_pair_names(channel_clusters,1);


%import file and read data
alleeg = read_egi_multiple_by_categorynames(category_names);


%calculate coherence
[all_coh,timesout,freqsout,...
id_list,trial_list] = TS_coh_calculation(alleeg,channel_clusters,baseline);


%export
[dataset_data,dataset_label] =TS_coh_export(all_coh,...
        timesout,freqsout,id_list,channel_names);

%plotting
TS_coh_plot(all_coh,timesout,freqsout,id_list,channel_names);