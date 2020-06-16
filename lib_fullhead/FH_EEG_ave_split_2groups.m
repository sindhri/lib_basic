function [EEG1,EEG2]=FH_EEG_ave_split_2groups(EEG_ave,group_table,group_variable)

EEG1 = EEG_ave;
EEG2 = EEG_ave;

unique_items = unique(group_table.(group_variable));
index1 = (group_table.(group_variable)==unique_items(1));
index2 = (group_table.(group_variable)==unique_items(2));

fprintf('split into 2 groups\n');

EEG1.data = EEG_ave.data(:,:,:,index1);
EEG1.ID = EEG_ave.ID(index1,:);
EEG1.nsubject = length(find(index1==1));
if ~isempty(EEG_ave.group_name)
    EEG1.group_name = [EEG_ave.group_name '_' group_variable int2str(unique_items(1))];
else
    EEG1.group_name = [group_variable int2str(unique_items(1))];
end
fprintf('%s n = %d\n',EEG1.group_name,EEG1.nsubject);

EEG2.data = EEG_ave.data(:,:,:,index2);
EEG2.ID = EEG_ave.ID(index2,:);
EEG2.nsubject = length(find(index2==1));
if ~isempty(EEG_ave.group_name)
    EEG2.group_name = [EEG_ave.group_name '_' group_variable int2str(unique_items(2))];
else
    EEG2.group_name = [group_variable int2str(unique_items(2))];
end
fprintf('%s n = %d\n',EEG2.group_name,EEG2.nsubject);

end