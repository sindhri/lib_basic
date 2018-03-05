%use the fullhead power calculated using FFT_topoplot_step1
%reduce to single channel clusters
%20160628, added option for not doing log
%added subplot for each cluster, figure for each frequency
%also added rearrange sequence
%20161107, added y_limit which is a cell of arrays, each corresponding to
%the ylim of one particular frequency, in order to match two clusters
%20161107, split out the plot part

function data_averaged = FFT_reduce_channel(power,channel_list_cluster,...
    log_or_not,rearrange_sequence,y_limit)


frequency_range_cell = power.frequency_range_cell;
condition_names = power.condition_names;
nchan = power.nchan;

nc = length(condition_names);
nf = length(frequency_range_cell);


freq_names=cell(1);
for i= 1:nf
    freq = frequency_range_cell{i};
    freq_names{i} = [num2str(freq(1)) ' to ' num2str(freq(2)) 'Hz'];
end


%prepare and convert data
if log_or_not == 1
    power_log = log(power.data);
    power_ave = squeeze(mean(power_log,1));
else
    power_ave = squeeze(mean(power.data,1));
end

data=zeros(nc,nchan,nf);
index=zeros(nc*nchan*nf,1);
m = 1;
for i = 1:nc
    for j = 1:nchan
        for p = 1:nf
            index(m) = (i-1)*nchan*nf+(j-1)*nf+p;
            data(i,j,p) = power_ave(index(m));
            m = m+1;
        end
    end
end

data_converted = zeros(nf,nc,nchan);
for i = 1:nf
    for j = 1:nc
        for p = 1:nchan
            data_converted(i,j,p) = data(j,p,i);
        end
    end
end

ncluster = length(channel_list_cluster.channel);
data_averaged = zeros(nf,nc,ncluster);

for i = 1:ncluster
    channel = channel_list_cluster.channel{i};
%    for j = 1:nf
%        
    data_averaged(:,:,i) = mean(data_converted(:,:,channel),3);
end

FFT_kathy_bar(data_averaged,power.condition_names,rearrange_sequence,...
    frequency_range_cell,channel_list_cluster.name,y_limit)
%bar(data_averaged(:,:,i));
%        title_names{m} = [freq_names{i} ' ' power.group_name ' ' condition_names{j}];
%        h=title(title_names{m});
%        set(h,'interpreter','none');


end

