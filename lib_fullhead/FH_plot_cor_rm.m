%input corrintable
%20191017, replaced bmap to just print significance as white, no direction
%20191101, a better color contrast, green on light gray
%20191115, use rmintable
%item_to_plot [2,3], the [2,3] of the rmintable matrix
%make sure it is not empty
%20191117, small mods
function item_pos = FH_plot_cor_rm(rmintable,item_to_plot,items)

    alldim = rmintable.Properties.VariableNames;
    rm_table = rmintable(item_to_plot(1),item_to_plot(2)).(alldim{item_to_plot(2)}){1,1};

    item_pos = [];
    
    make_a_figure(rm_table.within,rm_table,items);
    make_a_figure(rm_table.between,rm_table,items);

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

function make_a_figure(pstruct,rm_table,items)
    
    nitems = length(items);
    item_per_row = 5;
    
    nrow = floor(nitems/item_per_row);
    if mod(nitems,item_per_row)~=0
        nrow = nrow+1;
    end
    

    colorbar_width_param = 0.015; 
    f = figure;
    res = get(0,'screensize');
    set(f,'position',[0,0,res(3),res(4)]);
    %bmap= zeros(200,3); %all black
    bmap = repmat([0.9,0.9,0.9],200,1);
    %top to bottom
    for i = 101:105
        bmap(i,:)=[0,1,0]; %p <.05, green
    end
    for i = 96:100
        bmap(i,:)=[0,1,0]; %p <.05, green
    end

    item_pos = find_valid_pos(items,rm_table.times);
    pdata = pstruct.p;
    for i = 1:nrow 
        last_item = min(item_per_row,length(items)- (i-1)*item_per_row);
        for j = 1:last_item
            item_index = (i-1)*item_per_row+j;
            a(j) = subplot(nrow,item_per_row,item_index);
            
            topoplot(pdata(:,item_pos(item_index)),rm_table.chanlocs,...
                'maplimits',[-1,1],'style','map','colormap',bmap,...
                'electrodes','numbers');
            title([int2str(items(item_index)) ' ms']);
            axcopy;
        end
        b = colorbar;
        pos = get(a(item_per_row),'position');
        set(b,'position',[pos(1)+0.15,pos(2),colorbar_width_param,pos(4)]);

        %set(b,'XTick',-1:0.05:1);
%        t = title(['p map_' corrEEG.name_eeg '_' corrEEG.name_behavioral]);
%        set(t,'interpreter','none');
        text(-nitems/2-10,0,[rm_table.name1 '_' rm_table.name2],'interpreter','none');
    end
end