%20141202
%makes heatmap provided the ALLEEG structure
%each EEG is for a condition
%EEG.data dimension follows nchanxntimexnsubj
%items are the time point for plotting

%20151102, added save image. added plot_oscillation folder
%20151102, added manually input limit and limit_diff
%20151215, use EEG.limit instead of EEG.abs. (limit was set to be abs most
%of the time except in the ITC situation)
%20160212, if print channel label, do not close the figure

function ITC_fullhead_heatmap(ALLEEG, items,print_labels,limit,limit_diff)

if nargin==2
    print_labels = 0;
end

ncond = length(ALLEEG);

%range = [min([ALLEEG(1).range,ALLEEG(2).range]),...
%    max([ALLEEG(1).range,ALLEEG(2).range])];
data_mean = mean([ALLEEG(1).mean, ALLEEG(2).mean]);
data_temp = [ALLEEG(1).data_avg, ALLEEG(2).data_avg];
data_std = std(data_temp(:));
data_abs = max(abs(data_mean - 2*data_std), abs(data_mean+2*data_std));
%limit = [-data_abs,data_abs];

if ~exist('plot_oscillation','dir')
    mkdir('plot_oscillation');
end

load cmap;

for i = 1:ncond
%    for i = 1
        if nargin==3
            limit = ALLEEG(i).limit;
        end
        
    if i==1 || i==2
    %cannot use 'absmax' or'maxmin', has to either omit it or use a
    %specific limit, otherwise it only applies the limit on the very last
    %graph
        if print_labels == 0
%            pop_topoplot(ALLEEG(i),1,items,ALLEEG(i).setname,[1,length(items)],'colormap',cmap,'maplimits',limit);
            pop_topoplot(ALLEEG(i),1,items,ALLEEG(i).setname,[1,length(items)],'colormap',cmap,'maplimits',limit,'style','map');
        else
            pop_topoplot(ALLEEG(i),1,items,ALLEEG(i).setname,[1,length(items)],'colormap',cmap,'maplimits',limit,'electrodes','numbers','style','map');
        end
    else
        if nargin==3
            limit_diff = ALLEEG(i).limit;
        end
        if print_labels == 0
           pop_topoplot(ALLEEG(i),1,items,ALLEEG(i).setname,[1,length(items)],'colormap',cmap,'maplimits',limit_diff,'style','map');
        else
            pop_topoplot(ALLEEG(i),1,items,ALLEEG(i).setname,[1,length(items)],'colormap',cmap,'maplimits',limit_diff,'electrodes','numbers','style','map');
        end
    end
    
    set(gcf, 'PaperPosition', [0 0 18 3]); 
    set(gcf, 'PaperSize', [18 3]); 
    saveas(gcf,['plot_oscillation/' ALLEEG(i).setname],'pdf');
    if print_labels == 0
        close;
    end
end
end