%after reading from ITC_read_egi_ave, combine two groups

function EEG_ave = ITC_combine_ave(EEG_ave1, EEG_ave2)

EEG_ave = EEG_ave1;
EEG_ave.group_name = '';

for i = 1:EEG_ave1.nsubject
    EEG_ave.group_index(i) = 1;
end
for i = 1:EEG_ave2.nsubject
    EEG_ave.id{i+EEG_ave1.nsubject} = EEG_ave2.id{i};

end

    EEG_ave.nsubject = EEG_ave1.nsubject + EEG_ave2.nsubject;

    EEG_ave.group_index(1+EEG_ave1.nsubject:EEG_ave.nsubject) = 2;
    EEG_ave.data(:,:,:,1+EEG_ave1.nsubject:EEG_ave.nsubject) = EEG_ave2.data;

    EEG_ave.group_label{1} = EEG_ave1.group_name;
    EEG_ave.group_label{2} = EEG_ave2.group_name;
    
    %sort by id
    [~,index] = sort(EEG_ave.id);
    EEG_ave.id = EEG_ave.id(index);
    EEG_ave.data = EEG_ave.data(:,:,:,index);

end
