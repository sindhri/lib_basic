%COH is from ITC_calculation_struct
%name_group_info is used to identify groups, eg, exposed, control
%%20140908, pulled in internal functions
%20150603, developed it to plot for coh
%incomplete

function coh_images_for_2cond(COH,limit_ERSP,diff_limit_ERSP,...
    limit_ITC,diff_limit_ITC)

times = COH.times;
freqs = COH.freqs;

data = COH.data;
[nsubj,npair,ncond]=size(data); 

for i = 1:npair

    data1_mean = mean(data(:,i,1),1);
    data2_mean = mean(data(:,i,2),1);
    diff_mean = mean(data(:,i,3),1);
    
    if nargin==1
        limit_data = 
end

if nargin==1
    limit_ERSP = [min(min(min(data))),max(max(max(data)))];
    diff_limit_ERSP = [min(min(min(diff))),max(max(max(diff)))];
end
titlename=[COH.group_name '_' COH.montage_name 'ERSP'];
images_for_2cond_single(times,freqs,data,COH.ERSP_category,limit_ERSP,...
    diff_limit_ERSP, titlename);

%ITC
data = COH.ITC_mean;
diff = data(:,:,1)-data(:,:,2);
if nargin==1
    limit_ITC = [min(min(min(data))),max(max(max(data)))];
    diff_limit_ITC = [min(min(min(diff))),max(max(max(diff)))];
end
titlename=[COH.group_name '_' COH.montage_name 'ITC'];
images_for_2cond_single(times,freqs,data,COH.ITC_category,limit_ITC,...
    diff_limit_ITC,titlename);
    
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

function images_for_2cond_single(times, freqs, data, cond_names,limit,...
    diff_limit,titlename)

fontsize = 15;

diff = data(:,:,1)-data(:,:,2);

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

figure;

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
enlarge_plot(h2,-0.04);

%plot difference
h3=subplot(1,3,3);
imagesc(times,freqs,diff,diff_limit);
t=title([cond_names{1} '-' cond_names{2}],'fontsize',fontsize);
set(t,'Interpreter','none');
set(gca,'ydir','normal','fontsize',fontsize,'xtick',xtick);
xlabel('Time(ms)');
ylabel('Frequency(Hz)');
colorbar;
enlarge_plot(h3,0);

set(gcf, 'PaperPosition', [0 0 18 10]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [18 10]); 
saveas(gcf,['plot/' titlename],'pdf');
close;
end

function enlarge_plot(h,xchange)
size = get(h,'position');
size2 = size;
size2(1) = size(1) + xchange;
size2(3) = size(3) * 2;
set(h,'position',size2);
end
