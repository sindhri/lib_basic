%20161107, pull out the plot function based on averaged data
%chan_info is usually channel_list_cluster.name
%but it can also be used to generate difference plot, thus use manual
%naming
function FFT_kathy_bar(data_averaged,condition_names,rearrange_sequence,...
    frequency_range_cell,chan_info,y_limit)

data_label_wrap.data = data_averaged;
data_label_wrap.label = condition_names;
data_label_wrap_new = data_rearrange(data_label_wrap,rearrange_sequence);

if ~exist('plot','dir')
    mkdir('plot');
end

for i = 1:length(frequency_range_cell)
    figure;
    
    ncluster = length(chan_info);
 
    for j = 1:ncluster
        subplot(1,ncluster,j)
        bar(data_label_wrap_new.data(i,:,j),0.6);
        if ~isempty(y_limit)
            ylim(y_limit{i});
        end
        
        set(gca, 'XTickLabel',data_label_wrap_new.label,...
            'XTick',1:numel(data_label_wrap_new.label))
        freq_range = frequency_range_cell{i};
        
        title_text = [int2str(freq_range(1)) 'to' int2str(freq_range(2)) 'Hz_' chan_info{j}];
        t=title(title_text);
        set(t,'Interpreter','none');
    end
    
    set(gcf, 'PaperPosition', [0 0 25 5]); 
    set(gcf, 'PaperSize', [25 5]); 
    saveas(gcf,['plot/' title_text],'pdf');
    close;
end

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