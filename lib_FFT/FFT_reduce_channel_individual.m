%use the fullhead power calculated using FFT_topoplot_step1
%reduce to single channel clusters
%20160628, added option for not doing log
%added subplot for each cluster, figure for each frequency
%also added rearrange sequence
%individual plots for pilots, need to build

function data_averaged = FFT_reduce_channel_individual(power,channel_list_cluster,log_or_not,rearrange_sequence)


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

data_label_wrap.data = data_averaged;
data_label_wrap.label = power.condition_names;
data_label_wrap_new = data_rearrange(data_label_wrap,rearrange_sequence);

if ~exist('plot','dir')
    mkdir('plot');
end

for i = 1:nf
    figure;
    
        
    for j = 1:ncluster
        subplot(1,ncluster,j)
        bar(data_label_wrap_new.data(i,:,j),0.6);
        
        set(gca, 'XTickLabel',data_label_wrap_new.label,...
            'XTick',1:numel(data_label_wrap_new.label))
        freq_range = frequency_range_cell{i};
        
    end
    title_text = [int2str(freq_range(1)) 'to' int2str(freq_range(2)) 'Hz_' channel_list_cluster.name{j}];
    t=title(title_text);
    set(t,'Interpreter','none');
    
    set(gcf, 'PaperPosition', [0 0 12 4]); 
    set(gcf, 'PaperSize', [12 4]); 
    saveas(gcf,['plot/' title_text],'pdf');
    close;
end

%bar(data_averaged(:,:,i));
%        title_names{m} = [freq_names{i} ' ' power.group_name ' ' condition_names{j}];
%        h=title(title_names{m});
%        set(h,'interpreter','none');


end


function data_label_wrap_new = data_rearrange(data_label_wrap,rearrange_sequence)
    
    data = data_label_wrap.data;
    label = data_label_wrap.label;
    data_new = zeros(size(data));
    label_new = cell(size(label));
    
    for i = 1:length(rearrange_sequence)
        current = rearrange_sequence(i);
        data_new(:,i,:) = data(:,current,:);
        label_new{i}=label{current};
    end
    data_label_wrap_new.data = data_new;
    data_label_wrap_new.label = label_new;
    
end