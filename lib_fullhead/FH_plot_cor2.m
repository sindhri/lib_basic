%input corrintable
%20191017, replaced bmap to just print significance as white, no direction
%20191101, a better color contrast, green on light gray
%20200107, specify one condition and one column to plot, write the names

function item_pos = FH_plot_cor2(corrintable,cond_to_plot,column_to_plot,items)
    ncond = size(corrintable,1);
    nitems = length(items);
    alldim = corrintable.Properties.VariableNames;
    res = get(0,'screensize');
    item_pos = [];
    colorbar_width_param = 0.015; 

    f = figure;
    set(f,'position',[0,res(4),res(3),res(4)/5]);

    
   %bmap= zeros(200,3); %all black
   bmap = repmat([0.9,0.9,0.9],200,1);
            %top to bottom
            for i = 100:105
                bmap(i,:)=[0,1,0]; %p <0.5, red
            end
            for i = 96:100
                bmap(i,:)=[0,1,0]; %p <0.5, red
            end

        corrEEG = corrintable(cond_to_plot,column_to_plot).(alldim{column_to_plot});
        if iscell(corrEEG)
            corrEEG = corrEEG{1,1};
        end
%        if ~isfield(corrEEG,'pm_sign');
%            continue;
%        end
        if isempty(item_pos)
            item_pos = find_valid_pos(items,corrEEG.times);
        end
        corrEEG.data = corrEEG.pm_sign;
        corrEEG.trials = [];
        
        for j = 1:length(items)

            a(j) = subplot(1,nitems,j);
            
            %replaced the old bmap because it's not split at 0 precisely
            %bmap= ones(40,3);
            %top to bottom
            %bmap(22,:)=[1,0.7,0]; %p is between 0.05 and 0.1, orange
            %bmap(21,:)=[1,0,0]; %p < .05, red
            %bmap(20,:)=[0,0,1]; %p <.05 negative, blue
            %bmap(19,:)=[0,0.7,1]; %p between 0.05 and 0.1, negative, light blue
       
%           item_pos = find_valid_pos(items,corrEEG.times);
%           data_plot= corrEEG.data(:,item_pos(j));
%            topoplot(corrEEG.data(:,item_pos(j)),corrEEG.chanlocs,...
%                'maplimits',[-1,1],'style','map','colormap',bmap,'electrodes','numbers');
            topoplot(corrEEG.data(:,item_pos(j)),corrEEG.chanlocs,...
                'maplimits',[-1,1],'style','map','colormap',bmap);
            title([int2str(items(j)) ' ms']);
            axcopy;
        end
        b = colorbar;
        pos = get(a(nitems),'position');
        set(b,'position',[pos(1)+0.15,pos(2),colorbar_width_param,pos(4)]);

        %set(b,'XTick',-1:0.05:1);
%        t = title(['p map_' corrEEG.name_eeg '_' corrEEG.name_behavioral]);
%        set(t,'interpreter','none');
        %text(-nitems/2-10,0,[corrEEG.name1 '_' corrEEG.name2],'interpreter','none');
        title([corrEEG.name1 '_' corrEEG.name2],'interpreter','none');
end



function [items_pos, items_adjusted] = find_valid_pos(items,list)
    n = length(list);
    items_pos = round( (items-list(1))/(list(n)-list(1)) * (n-1))+1;
    items_pos(find(items_pos<1))=1;
    items_pos(find(items_pos>n))=n;
    items_adjusted = list(items_pos);
    
    for i = 1:size(items,1)
        for j = 1:size(items,2)
            if items(i,j)~=items_adjusted(i,j)
                fprintf('time %d adjusted to %d\n', items(i,j),items_adjusted(i,j));
            end
        end
    end
end