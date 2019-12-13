%20180316
%IE is the either ERSP or ITC after recompose
%chan_cluster.channel
%chan_cluster.montage_name
%only for ERSP
%20180323, add range parameter in ms, only plot a certain range, time_range =
%[0,550];
%select the sequence of condition, selected_condition = [2,1];
%for some reason, the middle figure needs to be wider
function tfplot = ITC_images_for_2cond_after_recompose_cmap(IE,chan_cluster,...
    cmap,selected_condition, time_range,limit_ERSP,diff_limit_ERSP)

    tfplot = IE;
    tfplot = rmfield(tfplot,'channames');
    tfplot.montage_name = chan_cluster.montage_name;
    tfplot.nbchan = length(chan_cluster.channel);
    tfplot.ERSP_mean = squeeze(mean(mean(IE.ERSP(:,:,:,chan_cluster.channel,:),4),5));

    times = tfplot.times;
    freqs = tfplot.freqs;

    plot_datapoint_range = adjust_range(time_range,times);
    plot_datapoint_start = plot_datapoint_range(1);
    plot_datapoint_end = plot_datapoint_range(2);
    times_updated = times(plot_datapoint_start:plot_datapoint_end);

    %ERSP
    data = tfplot.ERSP_mean;
    data = data(:,plot_datapoint_start:plot_datapoint_end,selected_condition);
    diff = data(:,:,1)-data(:,:,2);
    if nargin==4
        limit_ERSP = [min(min(min(data))),max(max(max(data)))];
        diff_limit_ERSP = [min(min(min(diff))),max(max(max(diff)))];    
    end
    titlename=['ERSP_' tfplot.group_name '_' tfplot.montage_name];
    cond_names{1} = ['ERSP_' tfplot.category_names{selected_condition(1)}];
    cond_names{2} = ['ERSP_' tfplot.category_names{selected_condition(2)}];
    cond_names{3} = [cond_names{1} '-' cond_names{2}];
    images_for_2cond_single(times_updated,freqs,data,diff,cond_names,...
        limit_ERSP,diff_limit_ERSP, titlename,cmap);

end

%plot the time and frequency plot for each condition, 
%and the difference (cond1-cond2)

%required input: 
%times: generated from newtimef
%freqs: generated from newtimef
%data: freqs x times x cond(2)
%cond_names: {'cond1','cond2'}

%optional input:
%limit, diff_limit: arbitrary range for the plot

%updated xtick for longer segments
%20180323, input difference data instead of calculating it
function images_for_2cond_single(times, freqs, data, diff, cond_names,...
    limit,diff_limit,titlename,cmap)

fontsize = 15;

ndp = length(times);
tick_interval = 100;
nbasic_xtick = floor((times(ndp)-times(1))/tick_interval);
if nbasic_xtick > 12
    tick_interval = 200;
%    nbasic_xtick = floor((times(ndp)-times(1))/tick_interval);
end

xtick_start = -floor(-(times(1)/tick_interval))*tick_interval;
xtick_end = floor(times(ndp)/tick_interval)*tick_interval;
xtick = xtick_start:tick_interval:xtick_end;

if ~exist('plot_oscillation','dir')
    mkdir('plot_oscillation');
end
figure;

colormap(cmap);

%plot condition 1
h1=subplot(1,3,1);
imagesc(times,freqs,data(:,:,1),limit);
t=title(cond_names{1},'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;
enlarge_plot(h1,-0.09);

%plot condition 2
h2=subplot(1,3,2);
imagesc(times,freqs,data(:,:,2),limit);
t=title(cond_names{2},'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;
%enlarge_plot(h2,-0.04);
size = get(h2,'position');
size2 = size;
size2(1) = size(1) -0.04;
size2(3) = size(3) * 2.5;
set(h2,'position',size2);

%plot difference
h3=subplot(1,3,3);
imagesc(times,freqs,diff,diff_limit);
t=title(cond_names{3},'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;
enlarge_plot(h3,0);

set(gcf, 'PaperPosition', [0 0 18 10]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [18 10]); 
saveas(gcf,['plot_oscillation/' titlename],'pdf');
close;
end

function enlarge_plot(h,xchange)
size = get(h,'position');
size2 = size;
size2(1) = size(1) + xchange;
size2(3) = size(3) * 2;
set(h,'position',size2);
end

function [index_range_of_interest, ...
    range_of_interest_adjusted]= adjust_range(range_of_interest,list)

index_range_of_interest = zeros(size(range_of_interest));

range_of_interest_adjusted = range_of_interest;

adjusted = 0;
for i = 1:size(range_of_interest,1)
    for j = 1:size(range_of_interest,2)
        target = range_of_interest(i,j);
        [index,target_adjusted] = find_index(target,list);
        index_range_of_interest(i,j)= index;
        range_of_interest_adjusted(i,j) = target_adjusted;
        if target ~= target_adjusted
            adjusted = 1;
        end
    end
end

fprintf('range of interest');
if adjusted == 1
    fprintf(' adjusted to: ');
end
fprintf('\n');
for i = 1:size(range_of_interest,1)
    for j = 1:size(range_of_interest,2)
        if mod(j,2) == 1
            fprintf('from ');
        else
            fprintf(' to ');
        end
        fprintf('%d',range_of_interest_adjusted(i,j));
    end
fprintf('\n');
end

end

function [index, target_adjusted] = find_index(target, list)
index = 0;
for i = 1:length(list)-1
    diff = list(i)-target;
    if abs(list(i+1) - target) > abs(diff)
        index = i;
        target_adjusted = list(i);
        break;
    end
end
if index==0
    index = length(list);
    target_adjusted = list(length(list));
end
end

