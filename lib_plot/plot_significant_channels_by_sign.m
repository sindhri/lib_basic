%20170810, added net_type
%plot channels with positive r/t with red
%plot channels with negative r/t with blue
function plot_significant_channels_by_sign(channel_list_pos,channel_list_neg,net_type)

if nargin==0
    channel_list_pos = [];
    channel_list_neg = [];
end

if nargin<3
    net_type = 1;
    fprintf('default using hydrocel 129\n');
end

position_in_range = getChanLocation(net_type);
ntotalchannel = 129;
figure;
fprintf('plotting...... ');

for i = 1:ntotalchannel

    if mod(i,10)==0 
        fprintf('%d ',i);
    end
    subplot('position',[(position_in_range(i,2)*sin(position_in_range(i,1)/180*3.1416)+0.55)*0.9,...
        (position_in_range(i,2)*cos(position_in_range(i,1)/180*3.1416)+0.55)*0.9,0.04,0.04]);
    if ~isempty(find(channel_list_pos ==i,1))
        draw_a_circle(0,0,0.1,i,'r');
    else
        if  ~isempty(find(channel_list_neg ==i,1))
            draw_a_circle(0,0,0.1,i,'b');
        else
            draw_a_circle(0,0,0.1,i);
        end
    end
end
set(gcf,'color','w');
fprintf('\n');
