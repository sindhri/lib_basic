%20201101, input coi_struct, data alreayd averaged across channels
%20180316
%IE is the either ERSP or ITC after recompose
%chan_cluster.channel
%chan_cluster.montage_name
%only for ERSP
%20180427
%channel is the 3rd dimension if recompose from multiple condiitons
%together
%instead of from the IE that has all the conditions
%added oscillation_type, for either ERSP, or ITC
%only input the limit for the specific oscillation_type
%added able to pick 2 out of many conditions, condition is the 3rd
%dimension
function tfplot = ITC_images_for_2cond_coi(coi_struct, oscillation_type,...
    condition_of_interest, limit_cond,...
        limit_cond_diff)

    if length(condition_of_interest)~=2
        fprintf('can only plot 2 conditions and their difference.\n');
        return
    end
    
    tfplot = coi_struct;
    tfplot.montage_name = coi_struct.coi.name;
    tfplot.nbchan = 1;
    %20180427 change channel to the 3rd dimension 
    %tfplot.ERSP_mean = squeeze(mean(mean(IE.ERSP(:,:,:,chan_cluster.channel,:),4),5));
    times = coi_struct.times;
    freqs = coi_struct.freqs;

    
    %for either ERSP or ITC, but not both
    data = tfplot.(oscillation_type);
    data = mean(data,4);

    data = data(:,:,condition_of_interest);
    
    diff = data(:,:,1)-data(:,:,2);
    if nargin==3
        limit_cond = [min(min(min(data))),max(max(max(data)))];
        limit_cond_diff = [min(min(min(diff))),max(max(max(diff)))];    
    end
    condition_names_in_title = [tfplot.category_names{condition_of_interest(1)} '_' tfplot.category_names{condition_of_interest(2)}];
    if ~isempty(tfplot.group_name)
        titlename=[oscillation_type '_' tfplot.group_name '_' tfplot.montage_name '_' condition_names_in_title];
    else
        titlename=[oscillation_type '_' tfplot.montage_name '_' condition_names_in_title];
    end
    plot_cond_names{1} = [oscillation_type '_' tfplot.category_names{condition_of_interest(1)}];
    plot_cond_names{2} = [oscillation_type '_' tfplot.category_names{condition_of_interest(2)}];
    plot_cond_diff_names = [plot_cond_names{1} '_' plot_cond_names{2}];
    
    images_for_2cond_single(times,freqs,data,diff,...
        plot_cond_names,plot_cond_diff_names,limit_cond,...
        limit_cond_diff, titlename);
   

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
%added diff 201800427, cond_names_diff
function images_for_2cond_single(times, freqs, data,diff,...
cond_names, cond_names_diff,limit,...
    diff_limit,titlename)


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

% colormap needs to be introduced AFTER figure!
load('colormap_red_blue.mat');
colormap(red_blue);

set(gcf, 'PaperPosition', [0 0 18 10]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [18 10]); 
set(gcf,'position',[0,0,1200,800]);

%plot condition 1
h1=subplot(1,3,1);
pos = h1.get('position');
h1.set('position',[pos(1)-0.09, pos(2), pos(3)*1.3, pos(4)]);
imagesc(times,freqs,data(:,:,1),limit);
t=title(cond_names{1},'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;

%plot condition 2
h2=subplot(1,3,2);
pos = h2.get('position');
h2.set('position',[pos(1)-0.04, pos(2), pos(3)*1.3, pos(4)]);
imagesc(times,freqs,data(:,:,2),limit);
t=title(cond_names{2},'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;

%plot difference
h3=subplot(1,3,3);
pos = h3.get('position');
h3.set('position',[pos(1), pos(2), pos(3)*1.3, pos(4)]);
imagesc(times,freqs,diff,diff_limit);
t=title(cond_names_diff,'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;

if exist('plot_tf','dir') ~=7
    mkdir('plot_tf');
end
saveas(gcf,['plot_tf/' titlename],'pdf');
close;

end
