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
%adjusted title position based on plotting 1-p instead of log

%20190127, fixed a baseline bug

function plotMap_angleAxis_log2_wholehead_2017(p_matrix_pos, p_matrix_neg,...
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

%criterion_upper = 0.05;
%criterion_lower = 0.001;

baseline = 100; %default it to 100

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


figure;

for i = 1:channel
    if mod(i,10)==0
        fprintf('%d\t',i);
    end
%for i = 1
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,(position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.03,0.03]);
    if nargin > 0
       %plot(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_pos(i,:),'bo');
       bar(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_pos(i,:),'facecolor','red','edgecolor','red');
       hold on;
       %plot(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_neg(i,:),'rx');
       bar(0-baseline:1000/srate:data_length-1000/srate-baseline, 1-p_matrix_neg(i,:),'facecolor','blue','edgecolor','blue');
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
       xplot_min = 0-baseline;
       xplot_max = data_length-baseline;
       line([xplot_min, xplot_min],[yplot_min, yplot_max],'Color','k','linewidth',3);
       line([xplot_max, xplot_max],[yplot_min, yplot_max],'Color','k','linewidth',3);
       
       line([xplot_min, xplot_max],[axis_lower, axis_lower],'Color','k','linewidth',3);
       line([xplot_min, xplot_max],[axis_upper, axis_upper],'Color','k','linewidth',3);
       %end of code B
       
       axcopy; 
    end
    %xlabel('Time(ms)');
    %ylabel('p value in log');
    axis([0-baseline,data_length-baseline,axis_lower,axis_upper]);
    h = title(int2str(i));
    set(h,'fontsize', 12,'fontweight','bold','fontname','arial');
end

%t = text(10^4,10^28,title_text);
t = text(5000,2,title_text);
set(t,'interpreter','none','fontsize',14);

set(gcf,'color','w');
hold off;
axcopy; 
fprintf('\n');
end
