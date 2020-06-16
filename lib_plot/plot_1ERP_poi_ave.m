%input data_plot is ncond x times
%based on using text and time from poi, EEG_ave
function plot_1ERP_poi_ave(data_plot,times,title_text,legend_text,...
    xtime_highlight,plot_ylim)


figure;
%    color_lib = {'r','b','m','g','k','c',[0 0.7 0.9],'y'};
    color_lib = {'g','b','r','m','g','b','r','m'};
    linestyle_lib = {'-','-','-','-','-.','-.','-.','-.'};
    for i = 1:size(data_plot,1)
        plot(times,data_plot(i,:),...
            'Color',color_lib{i},'Linestyle',linestyle_lib{i});
        xlabel('Time (ms)');
        hold on;
    end
    
    if nargin==5
        yl = ylim;
    else
        yl = plot_ylim;
        ylim(plot_ylim);
    end

    plot([xtime_highlight(1),xtime_highlight(1)],[yl(1),yl(2)],'-.k');
    plot([xtime_highlight(2),xtime_highlight(2)],[yl(1),yl(2)],'-.k');
    xl = xlim;
    plot([xl(1),xl(2)],[0,0],'k');
    
    legend(legend_text,'interpreter','none');

    title(title_text,'interpreter','none');
    
end