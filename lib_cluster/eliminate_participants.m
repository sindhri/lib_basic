%remove participants that don't have min_ntrials for each condition

function EEG_ave= eliminate_participants(EEG_ave, min_ntrials)

%min_ntrials = 15;
to_exclude = [];
for i = 1:length(EEG_ave.ID)
    if min(EEG_ave.ntrials(i,:)) < min_ntrials
        to_exclude = [to_exclude,i];
        fprintf('%d excluded\n',EEG_ave.ID(i));
    end
end
if ~isempty(to_exclude)
    fprintf('Total of %d out of %d subjects excluded\n',length(to_exclude),length(EEG_ave.ID));
else
    fprintf('No subjects were excluded due to minimum number of trials!\n');
end
EEG_ave.data(:,:,:,to_exclude)=[];
EEG_ave.ID_excluded = EEG_ave.ID(to_exclude);
EEG_ave.ID_original = EEG_ave.ID;
EEG_ave.ID(to_exclude)=[];
EEG_ave.ntrials_original = EEG_ave.ntrials;
EEG_ave.ntrials(to_exclude,:)=[];
EEG_ave.nsubject_original = EEG_ave.nsubject;
EEG_ave.nsubject = EEG_ave.nsubject-length(to_exclude);
end