%7 colors %multiple shapes
%present 1 measurement on a plot
%present 1 or more condition on a plot
%update 2/7/2011
%2011-09-12, fixed baseline_ms issue

%2012-02-29, plot log10 of p
%first convert every number to be positive
%second convert too small ps into the lowerest p to show
%removed multiple conditions

%2012-07-18
%revisited, make the plot better

%2013-03-22, added channel_to_plot

%2013-04-16, limit plot to 0.05, instead of 0.1
%2014-07-28, added option for choosing net montage
function plotMap_angleAxis_log2_singlechan(p_matrix_pos, p_matrix_neg,...
    baseline_ms,sampling_rate,channel_to_plot,net_type)

if nargin == 2
    baseline_ms = 100;
    sampling_rate = 250;
    net_type = 1; %hydrocell, 2 for GSN
end

dps = 1000/sampling_rate;



axis_upper = 0.1;
axis_lower = 0.001;
criterion_upper = 0.05;
criterion_lower = 0.001;

[channel,datapoint]=size(p_matrix_pos);
for a = 1:channel
    for b = 1:datapoint
        if p_matrix_pos(a,b) < criterion_lower
            p_matrix_pos(a,b) = criterion_lower;
        else
            if p_matrix_pos(a,b) > criterion_upper
                p_matrix_pos(a,b) = 1;
            end
        end
        if p_matrix_neg(a,b) < criterion_lower
            p_matrix_neg(a,b) = criterion_lower;
        else
            if p_matrix_neg(a,b) > criterion_upper
                p_matrix_neg(a,b) = 1;
            end
        end
    end
end

position_in_range = getChanLocation(net_type);
if channel~=size(position_in_range,1)
    fprintf('channel number mismatch!\n');
    return
end

data_length = datapoint*1000/sampling_rate;
%color_lab = 'rbgcmyk';
%shape_lab = '.ox+*sdv^<>ph';


figure;

%for i = 1:channel
for i = channel_to_plot
     if nargin > 0
            plot(0-baseline_ms:dps:data_length-dps-baseline_ms, p_matrix_pos(i,:),'bo','markersize',20);
            hold on;
            plot(0-baseline_ms:dps:data_length-dps-baseline_ms, p_matrix_neg(i,:),'rx','markersize',20);
            h = gca;
            set(h,'fontsize',30,'YScale','log','YMinorTick','on','YMinorGrid','off');
       
       axcopy; 
    end
    %xlabel('Time(ms)');
    %ylabel('p value in log');
    axis([0-baseline_ms,data_length-baseline_ms,axis_lower,axis_upper]);
    h = title(int2str(i));
    set(h,'fontsize', 30,'fontweight','bold','fontname','arial');
end

set(gcf,'color','w');
hold off;
axcopy; 
  