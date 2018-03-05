%input the EEG groups of all trials and only clean trials

function ALLEEG_all = identify_bad_trials(ALLEEG_all,ALLEEG_clean)

nsubj = length(ALLEEG_all);
if nsubj~=length(ALLEEG_clean)
    fprintf('subject number does not match, abort\n');
    return
end

for i = 1:nsubj
    
    EEG_all = ALLEEG_all(i);
    EEG_clean = ALLEEG_clean(i);
    %EEG_all.id
    
    data_all = EEG_all.data;
    data_clean = EEG_clean.data;
    
    ntotal = size(data_all,3);
    ngood = size(data_clean,3);
    good_trial_indicator = ones(1,ntotal);
    
    m = 1;
    
    for j = 1:ntotal

        if m <=ngood
            temp_compare = data_all(:,:,j)==data_clean(:,:,m);
            if ~isempty(find(temp_compare==0))
                good_trial_indicator(j)=0;
            else
                m =m+1;
            end
        else
            good_trial_indicator(j)=0;
        end
    end
    
    ALLEEG_all(i).good_trial_indicator = good_trial_indicator;
end

end