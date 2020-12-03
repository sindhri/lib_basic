% 20201127
% EEG is from ITC_read_egi_ave, more than 1 group
% based on a cluster, export several csv for each condition
% each csv would have nsubj x timepoint

function export_to_single_datapoint(EEG, cluster)

ngroup = length(EEG);

[~, ~, ncond, ~] = size(EEG(1).data);

labels = cell(1);
for i = 1:length(EEG(1).times)
    labels{i} = num2str(EEG(1).times(i));
end

dir_name = 'export_individual_datapoint/';
if exist(dir_name,'dir')~=7
    mkdir(dir_name);
end

for i = 1:ngroup
    id_list = EEG(i).ID;
    group_data = squeeze(mean(EEG(i).data(cluster,:,:,:)));
    group_name = EEG(i).group_name;
    for j = 1:ncond
        group_cond_data = squeeze(group_data(:,j,:))';
        T = array2table(group_cond_data);
        T.Properties.VariableNames = labels;
        first_var = T.Properties.VariableNames{1};
        T = addvars(T,id_list,'Before',first_var);
        cond_name = EEG(i).eventtypes{j};
        filename = [dir_name group_name '_' cond_name '.csv'];
        writetable(T,filename);
    end
end