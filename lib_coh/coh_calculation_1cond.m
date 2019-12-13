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
%20190401, adjust it to use in 1 condition data
%201908, fixed an important bug about not importing single trial!
%previously in April I was not able to import single trial
%Now I figured out how! And previously the coherence values were larger
%than 1! Now everything seems normal!

function COH = coh_calculation_1cond(alleeg,montage,baseline,coh_interest)

%channel_clusters = {{[36,37],[25,27]},{[36,37],[105,104]},{[11,16],[36,37]},{[11,16],[105,104]}};
channel_clusters = montage.channel;

npair = length(channel_clusters);
nsubject = length(alleeg);

n_frames = alleeg(1).pnts;
sampling_rate = alleeg(1).srate;
time_min = 0-baseline;
time_max = n_frames/sampling_rate*1000-4-baseline;

all_coh = cell(nsubject,npair,1);
id_list = cell(nsubject,1);
trial_list = zeros(nsubject,1);

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
    trial_of_condition_of_interest = [];
    
    %find the trials for each condition
    for p = 1:n_category
        if strcmp(category_names_count{p,1},alleeg(1).category_names{1})==1
            trial_of_condition_of_interest = category_names_count{p,3};
            continue;
        end
    end
    if isempty(trial_of_condition_of_interest) 
        fprintf('condition 1 has 0 trials\n');
        return
    end
    
    
    id_list{i} = EEG.id;
    trial_list(i,:) = length(trial_of_condition_of_interest);

    for j = 1:npair
        clusters = channel_clusters{j};
        cluster1 = clusters{1};
        cluster2 = clusters{2};
        data_cluster1 = squeeze(mean(data(cluster1,:,:),1)); %dataopint x trial
        data_cluster2 = squeeze(mean(data(cluster2,:,:),1)); %datapoint x trial

        data_cluster1_DOI = data_cluster1(:,trial_of_condition_of_interest); %datapoint x specif_trial
        data_cluster2_DOI = data_cluster2(:,trial_of_condition_of_interest);
        
        data_cluster1_reshaped = reshape(data_cluster1_DOI,[1,n_frames*length(trial_of_condition_of_interest)]);
        data_cluster2_reshaped = reshape(data_cluster2_DOI,[1,n_frames*length(trial_of_condition_of_interest)]);
       
      [coh,~,timesout,freqsout,~,~,...
        ~,~,~] = newcrossf(data_cluster1_reshaped,data_cluster2_reshaped,...
        n_frames,[time_min, time_max],...
        sampling_rate,0,'plotamp','off','plotphase','off',...
        'timesout', 200, 'freqs',coh_interest,'type','coher');

   
        all_coh(i,j,:) = {coh};
        
    end
end

COH.data = all_coh;
COH.times = timesout;
COH.freqs = freqsout;
COH.id = id_list;
COH.trial_list = trial_list;

end