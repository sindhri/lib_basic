function bar_by_group(behavioral,group_column,column_to_plot)
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
        data_se(i,:) = std(ctable.(column_to_plot{j}));
    end
    data_se(i,:) = data_se(i,:)/sqrt(size(ctable,1));
end

ymax = max(max(data_mean))+max(max(data_se));
figure;
for i = 1:nplots
    subplot(1,nplots,i);
    x = 1:nitems;
    bar(x,data_mean(i,:))
    hold on;
    er = errorbar(x,data_mean(i,:),-data_se(i,:),data_se(i,:));    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    set(gca,'XTickLabel',column_to_plot,'TickLabelInterpreter','none');
    title([group_column '=' int2str(unique_items(i))],'interpreter','none');
    ylim([0,ymax]);
    hold off
    set(gca,'fontsize',15);
end
