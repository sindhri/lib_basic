function line_by_group(behavioral,group_column,column_to_plot)
unique_items = unique(behavioral.(group_column),'sorted');
nplots = length(unique_items);

for i = 1:nplots
    ctable = behavioral(behavioral.(group_column)==unique_items(i),:);
    all_tables{i} = ctable;
    fprintf('%s = %d n = %d\n',group_column,unique_items(i),size(ctable,1));
end

nitems = length(column_to_plot);
data_mean = zeros(nplots,nitems);
data_se = zeros(nplots,nitems);

for i = 1:nplots
    ctable = all_tables{i};
    for j = 1:nitems
        data_mean(i,j) = mean(ctable.(column_to_plot{j}));
        data_se(i,:) = std(ctable.(column_to_plot{i}));
    end
    data_se(i,:) = data_se(i,:)/sqrt(size(ctable,1));
end

%ymin = min(min(data_mean))+max(max(data_se));
%ymax = max(max(data_mean))+max(max(data_se));
color_lib = {'b','r','g','k','m','y'};
figure;

for i = 1:nplots
    x = 1:nitems;
    line(x,data_mean(i,:),'Color',color_lib{i});
    if i==1
        set(gca,'XTickLabel',column_to_plot,'TickLabelInterpreter','none');
    end
    hold on;
    er = errorbar(x,data_mean(i,:),data_se(i,:));    
    er.Color = color_lib{i};                            
    er.LineStyle = 'none';  
    %title([group_column '=' int2str(unique_items(i))],'interpreter','none');
    legend_text{i*2-1} = [group_column '=' int2str(unique_items(i))];
    legend_text{i*2} = [group_column '=' int2str(unique_items(i)) '_error'];
%    ylim([ymin,ymax]);
end
     legend(legend_text,'interpreter','none');
hold off;
end