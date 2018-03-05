%input if more than 1 dim, has to be (channel_list, nFactor)
%if 1dim, has to be channel_list x 1
%input the >threshold and <-threshold channel clusters.

%used code, getChanLocation, draw_a_circle
%2013-05-06, removed parameters for getChanLocation for updated
%getChanLocation code

function plot_2clusters(channel_list1, channel_list2,net_type)

if nargin==2
    net_type = 1;
end

position_in_range = getChanLocation(net_type);
ntotalchannel = 129;

for i = 1:ntotalchannel
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,(position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.04,0.04]);
    if ~isempty(find(channel_list1 ==i,1))
        draw_a_circle(0,0,0.1,i,'b');
    else
        if~isempty(find(channel_list2==i,1))
          draw_a_circle(0,0,0.1,i,'r');
        else
            draw_a_circle(0,0,0.1,i);
        end
    end
end
set(gcf,'color','w');