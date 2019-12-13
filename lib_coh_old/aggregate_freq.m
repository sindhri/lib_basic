function data_aggr = aggregate_freq(data, label, group)

for i=1:length(group)
    temp_freq = group{i};
    temp_column = [];
    for j = 1:length(temp_freq)
        temp_column = [temp_column,find(label == temp_freq(j))];
    end
    data_aggr(i,:,:) = mean(data(temp_column,:,:),1);
end