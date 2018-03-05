%20170810, added net_type
function plot_significant_channels(channel_list,net_type)

if nargin==0
    channel_list = [];
end

if nargin<2
    net_type = 1;
    fprintf('default using hydrocel 129\n');
end

position_in_range = getChanLocation(net_type);
ntotalchannel = 129;

for i = 1:ntotalchannel
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,...
        (position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.04,0.04]);
    if ~isempty(find(channel_list ==i,1))
        draw_a_circle(0,0,0.1,i,'r');
    else
        draw_a_circle(0,0,0.1,i);
    end
end
set(gcf,'color','w');