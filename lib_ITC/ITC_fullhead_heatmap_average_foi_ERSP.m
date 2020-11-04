% 20201104, modified the code to fit the fullhead oscillation foi_ERSP
% may have to adjust the colorbar's position to make it look ok

% input either foi_ERSP or foi_ITC
% need to pretreat the data so that it includes 2 conditions and their
% difference
% use ITC_select_2cond_foi_ERSP
% in summary, input foi_ERSP came from 
% 1. fullhead oscillation results.
% 2. ITC_fullhead_recompose_individual that generates foi_struct
% 3. ITC_prepare_data_for_heatmap_individual that generates foi_ERSP foi_ITC
% 4. ITC_select_2cond_foi_ERSP
%plot the average over some time ranges
%ALLEEG is a fake EEG struction for oscilaltion values
%time_ranges = [0,150;150,350,350,550;550,750;750,1050;1050,1350]
%only for 2 cond+diff ALLEEG

%todo, modify scale

function ITC_fullhead_heatmap_average_foi_ERSP(foi_ERSP,time_ranges,print_labels)

nplots = size(time_ranges,1);
ncond = length(foi_ERSP);
if ncond~=3
    fprintf('program is only designed for 2 cond+difference\n');
    return
end


times = foi_ERSP(1).times;
time_positions = find_valid_pos(time_ranges,times);
chanlocs = foi_ERSP(1).chanlocs;

data_mean = mean([foi_ERSP(1).mean, foi_ERSP(2).mean]);
data_temp = [foi_ERSP(1).data_avg, foi_ERSP(2).data_avg];
data_std = std(data_temp(:));
data_abs = max(abs(data_mean - 2*data_std), abs(data_mean+2*data_std));
data_limit = [-data_abs,data_abs];

res = get(0,'screensize');

division = ncond+2;
colorbar_width_param = 0.02; 
figure_y_position = [res(4)*0.8, res(4)*0.35,0];
figure_limit = [data_limit;data_limit;foi_ERSP(3).limit];
for i = 1:ncond
    f = figure;
    set(f,'position',[0,figure_y_position(i),res(3),res(4)/division]);
    
    for j = 1:nplots
        a(j) = subplot(1,nplots,j);
        data_plot= mean(foi_ERSP(i).data_avg(:,time_positions(j,1):time_positions(j,2)),2);
        if print_labels==0
            topoplot(data_plot,chanlocs,'maplimits',figure_limit(i,:));
        else
            topoplot(data_plot,chanlocs,'maplimits',figure_limit(i,:),'electrodes','numbers');
        end
        title([int2str(time_ranges(j,1)) 'to' int2str(time_ranges(j,2))]);
        axcopy;
    end
    b = colorbar;
    pos = get(a(nplots),'position');
    set(b,'position',[pos(1)+0.6,pos(2),colorbar_width_param,pos(4)]);
    caxis(figure_limit(i,:));
    t = suptitle(foi_ERSP(i).setname);
    set(t,'interpreter','none');

    plot_dir = 'plot_oscillation/average/';
    
    if exist(plot_dir,'dir')~=7
        mkdir(plot_dir);
    end
    set(gcf, 'PaperPosition', [0 0 18 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [18 5]); 
    saveas(gcf,[plot_dir foi_ERSP(i).setname],'pdf');
    close;
end
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
