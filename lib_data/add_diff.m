%add the difference waves to the EEG_ave structure for correlation
%calculation
function EEG_ave_diff = add_diff(EEG_ave)
ncond = length(EEG_ave.eventtypes);
EEG_ave_diff = EEG_ave;

m = 1;
for i = 1:ncond-1
    for j = i+1:ncond
        fprintf('calculating difference bewteen condition %d and %d\n',i,j);
        EEG_ave_diff.data(:,:,ncond+m,:) = EEG_ave.data(:,:,i,:)-EEG_ave.data(:,:,j,:);
        EEG_ave_diff.eventtypes{ncond+m} = ['diff_' EEG_ave.eventtypes{i} '_' EEG_ave.eventtypes{j}];
        m = m + 1;
    end
end
end