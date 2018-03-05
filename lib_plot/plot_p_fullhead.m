%fill in the adj_p_list, whose dimension is 39x187
%chan_list gives out the 39 channels
%39 is the number of frontal channel
%187 is after excluding baseline
%fill it to be 129 and 187+baseline

%2011-08-22, adapted from fill_post_FDR_p_matrix
%2012-02-29, process positive and negative separately to fit the log10
%plotting

%2013-04-15, added chan_list and net_type(1 hydro129; 2, GSN129)

%20160802, added srate, added using struct, added title
%20160917, check field names for report
%since when comparing two conditions, there is no such field names
%20160917, fixed a baseline caculation error from the last version
%should solve the baseline problem completely eventually

%20170810, updated to 2017 version
%20170831, added alpha_level
%20170927, added title
%20170927, consolidate long name files to short

%20171107, save as fig and pdf
%20171107, added default net_type and alpha_level
%removed some extra old defaults
%remove baseline? because no need

function [p_matrix_pos, p_matrix_neg] = plot_p_fullhead(report,net_type,alpha_level)

if nargin == 1
    net_type = 1;
    alpha_level = 0.05;
end
if nargin==2
    alpha_level = 0.05;
end
chan_list = report.channel_list;
srate = report.srate;
p_list = report.p_list;
p_list_sign = report.p_sign;
if any(strcmp(fieldnames(report),'rating_name'))
    title_text = [report.condition_name ' and ' report.rating_name];
else
    title_text = report.name;
end

[nchan, ndatapoint] = size(p_list);

if nchan ~= length(chan_list)
    fprintf('channel number mismatch, abort\n');
    return
end

total_n_chan = 129;


p_matrix_pos = ones(total_n_chan, ndatapoint);
p_matrix_neg = ones(total_n_chan, ndatapoint);

for i = 1:nchan
    for j = 1:ndatapoint
        if p_list_sign(i,j) > 0
            p_matrix_pos(chan_list(i),j) = p_list(i,j);
        else
            p_matrix_neg(chan_list(i),j) = p_list(i,j);
        end
    end
end

%plotMap_angleAxis_log(p_matrix);
%updated to 2017 version
%plotMap_angleAxis_log2_wholehead_2016(p_matrix_pos, p_matrix_neg,net_type,srate,title_text);
plot_p_fullhead_helper(p_matrix_pos,...
    p_matrix_neg,net_type,srate,title_text,alpha_level);
end

%7 colors %multiple shapes
%present 1 measurement on a plot
%present 1 or more condition on a plot
%update 2/7/2011
%2011-09-12, fixed baseline issue

%2012-02-29, plot log10 of p
%first convert every number to be positive
%second convert too small ps into the lowerest p to show
%removed multiple conditions

%2012-07-18
%revisited, make the plot better

%2013-04-15, added net_type, 1 hydrocell129, 2, GSN129
%20160802, added srate for x tick
%possibly need to rewrie the plot chan location part
%20170320, added channel indicator because the laptop doesn't generate
%partial image before finish,if fninsh at all

%20170810 plot 1-p on a 0.95-1 scale axis/map
%thus able to remove criterion
%changed it to positive-red, negative-blue

%20170831, input alpha_level, default 0.05

function plot_p_fullhead_helper(p_matrix_pos, p_matrix_neg,...
    net_type,srate,title_text,alpha_level)

if nargin==2
    position_in_range = getChanLocation;
else
    position_in_range = getChanLocation(net_type);
end

axis_upper = 1;
if nargin==5
    alpha_level = 0.05;
end
axis_lower = 1 - alpha_level;


[channel,datapoint]=size(p_matrix_pos);
%for a = 1:channel
%    for b = 1:datapoint
 %       if p_matrix_pos(a,b) < criterion_lower
 %           p_matrix_pos(a,b) = criterion_lower;
 %       else
 %           if p_matrix_pos(a,b) > criterion_upper
 %               p_matrix_pos(a,b) = 1;
 %           end
 %      end
 %       if p_matrix_neg(a,b) < criterion_lower
 %           p_matrix_neg(a,b) = criterion_lower;
 %       else
 %           if p_matrix_neg(a,b) > criterion_upper
 %               p_matrix_neg(a,b) = 1;
 %           end
 %       end
%    end
%end

if channel~=size(position_in_range,1)
    fprintf('channel number mismatch!\n');
    return
end

data_length = datapoint*1000/srate;
%color_lab = 'rbgcmyk';
%shape_lab = '.ox+*sdv^<>ph';

page_size = [1280,800];
figure('Units','pixels','Position',[100,100,page_size],'color',[1,1,1]);


for i = 1:channel
    if mod(i,10)==0
        fprintf('%d\t',i);
    end
%for i = 1
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,(position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.03,0.03]);
    if nargin > 0
       %plot(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_pos(i,:),'bo');
       bar(0:1000/srate:data_length-1000/srate, 1-p_matrix_pos(i,:),'facecolor','red','edgecolor','red');
       hold on;
       %plot(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_neg(i,:),'rx');
       bar(0:1000/srate:data_length-1000/srate, 1-p_matrix_neg(i,:),'facecolor','blue','edgecolor','blue');
       h = gca;
%       set(h,'fontsize',1,'YScale','log','YMinorTick','off',...
%           'YMinorGrid','off','ycolor','white','xcolor','white');
       set(h,'fontsize',1,'YScale','log','YMinorTick','off',...
           'YMinorGrid','off','ycolor',[0.3,0.3,0.3],'xcolor',[0.3,0.3,0.3]);
 
       %start of code B
       %enale the following for whole head plotting 
       %disable for single channel
       yplot_min = axis_lower;
       yplot_max = 1;
       xplot_min = 0;
       xplot_max = data_length;
       line([xplot_min, xplot_min],[yplot_min, yplot_max],'Color','k','linewidth',3);
       line([xplot_max, xplot_max],[yplot_min, yplot_max],'Color','k','linewidth',3);
       
       line([xplot_min, xplot_max],[axis_lower, axis_lower],'Color','k','linewidth',3);
       line([xplot_min, xplot_max],[axis_upper, axis_upper],'Color','k','linewidth',3);
       %end of code B
       
       axcopy; 
    end
    %xlabel('Time(ms)');
    %ylabel('p value in log');
    axis([0,data_length,axis_lower,axis_upper]);
    h = title(int2str(i));
    set(h,'fontsize', 12,'fontweight','bold','fontname','arial');
end

%changed the y value for plotting p upside down
t = text(10^4,2,title_text);
set(t,'interpreter','none','fontsize',20);

set(gcf,'color','w');
hold off;
axcopy; 
fprintf('\n');

set(gcf, 'PaperPosition', [0 0 page_size/100]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', page_size/100); 
if ~exist('plot_correlation/')
    mkdir('plot_correlation/');
end
fprintf('saving fig\n');
tic
saveas(gcf,['plot_correlation/' title_text],'fig');
toc
%fprintf('saving pdf\n');
%tic
%saveas(gcf,['plot_correlation/' title_text],'pdf');
%toc
close;   
end
