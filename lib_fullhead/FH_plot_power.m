% input foi from ITC_recompose_to_fullheadmap
% input, cluster.channel = []; cluster.name = '';
% output line plot of power of two conditions
function FH_plot_power(foi, cluster)

temp = split(foi(1).setname,'_');
oscillation_type = temp{1};
freq_range = temp{2};

ndpt = size(foi(1).data,2);
data_plot = zeros(ndpt,2);
condition_names = cell(1);
for i = 1:2
    data = foi(i).data;
    data = mean(data,3);
    data = squeeze(mean(data(cluster.channel,:),1));
        
    data_plot(:,i) = data;
    
    underscores = find(foi(i).setname=='_');
    condition_names{i} = foi(i).setname(underscores(2)+1:end);
end

figure;
plot(foi(1).times, data_plot(:,1),'r');
hold on
plot(foi(1).times, data_plot(:,2), 'b');
legend(condition_names, 'interpreter','none','location','north');
titlename = [oscillation_type '_' freq_range '_' cluster.name];
xlim([foi(1).times(1), foi(1).times(end)]);

title(titlename, 'interpreter','none');

if exist('plot_power/','dir')~=7
    mkdir('plot_power');
end

set(gcf, 'PaperPosition', [0 0 7 4]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [7 4]); 
saveas(gcf,['plot_power/' titlename],'pdf');
close;

end