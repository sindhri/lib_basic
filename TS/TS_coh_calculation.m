%channel_clusters
%20130222, use alleeg read by pop_read_egi, the EEG structure

%20130131, adjusted timeout to be 1244 for 6 seconds segmentation
%512-5484ms output
%added baseline
%added output channel_pairs and baseline

%input is the alleeg that is read by read_egi_jia
%2011-10-20, manually calcualte coh,
%instead of using the condition comparison in newcrosf. exactly the same
%as the condition comparison. change it back

%baseline in terms of miliseconds
%updated input to montage structure 20150526

%20150603, added category_names to COH
%20150604, randomly pick k trials from the category that has more trials
%than the other
%20150608, use all available trials

function COH = TS_coh_calculation(alleeg,montage,baseline)

%channel_clusters = {{[36,37],[25,27]},{[36,37],[105,104]},{[11,16],[36,37]},{[11,16],[105,104]}};
channel_clusters = montage.channel;

npair = length(channel_clusters);
nsubject = length(alleeg);

n_frames = alleeg(1).pnts;
sampling_rate = alleeg(1).srate;
time_min = 0-baseline;
time_max = n_frames/sampling_rate*1000-4-baseline;

all_coh = cell(nsubject,npair,3);
id_list = cell(nsubject,1);
trial_list = zeros(nsubject,3);

COH.group_name = alleeg(1).group_name;
COH.category_names = alleeg(1).category_names;
if length(COH.category_names)==2
    COH.category_names{3}=['diff_' alleeg(1).category_names{1} '-' alleeg(1).category_names{2}];
end
COH.baseline = baseline;
COH.montage_channel = montage.channel;
COH.montage_name = montage.name;
COH.npairs = npair;
COH.nsubjects = nsubject;
COH.nframes = n_frames;
COH.srate = sampling_rate;
COH.xmin = time_min;
COH.xmax = time_max;

for i = 1:nsubject
    EEG = alleeg(i);
    data = EEG.data; %chan x datapoint x trials
    category_names_count = EEG.category_names_count;
    n_category = size(category_names_count,1);
    nogo_trial_number = [];
    go_trial_number = [];
    
    %find the trials for each condition
    for p = 1:n_category
        if strcmp(category_names_count{p,1},'nogo_correct')==1
            nogo_trial_number = category_names_count{p,3};
            continue;
        end
        if strcmp(category_names_count{p,1},'go_correct')==1
            go_trial_number = category_names_count{p,3};
            continue;
        end
    end
    if isempty(nogo_trial_number) || isempty(go_trial_number)
        fprintf('nogo or go with 0 trials\n');
        return
    end
    
    %pick the minimum number of trials
    nogol = length(nogo_trial_number);
    gol = length(go_trial_number);
    
    if nogol <= gol
        minl = nogol;
        if nogol < gol
%            go_trial_number(nogol+1:gol) = []; %choosing the first k trials
%            go_trial_number = go_trial_number([randperm(gol,nogol)]);%random choose k trials
        end
    else 
        minl = gol;
%        nogo_trial_number(gol+1:nogol) = [];%choose the first k trials
%         nogo_trial_number = nogo_trial_number([randperm(nogol,gol)]);
    end
    
    id_list{i} = EEG.id;
    trial_list(i,:) = [nogol,gol,minl];
    
    for j = 1:npair
        clusters = channel_clusters{j};
        cluster1 = clusters{1};
        cluster2 = clusters{2};
        data_cluster1 = mean(data(cluster1,:,:),1); %1 x dataopint x trial
        data_cluster2 = mean(data(cluster2,:,:),1); %1 x datapoint x trial
        
        data_cluster1_nogo = data_cluster1(:,:,nogo_trial_number);
        data_cluster1_go = data_cluster1(:,:,go_trial_number);
        data_cluster2_nogo = data_cluster2(:,:,nogo_trial_number);
        data_cluster2_go = data_cluster2(:,:,go_trial_number);
        
      [coh,~,timesout,freqsout,~,~,...
        ~,~,~] = newcrossf({data_cluster1_nogo,data_cluster1_go},...
        {data_cluster2_nogo, data_cluster2_go},...
        n_frames,[time_min, time_max],...
        sampling_rate,0,'plotamp','off','plotphase','off',...
        'timesout', 200, 'freqs',[0.1,30],'type','coher');

        all_coh(i,j,:) = coh;
        
    end
end

COH.data = all_coh;
COH.times = timesout;
COH.freqs = freqsout;
COH.id = id_list;
COH.trial_list = trial_list;

end