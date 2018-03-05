%m waveformplots
%m = length of cluster
%in each plots, ncond of waves

function FFT_waveform_step2(power,freq_limit,cluster)

ncluster = length(cluster);
ncond = power.ncond;

power_plot = zeros(size(power.power));

for i = 1:power.nsubj
%    power_plot(:,:,:,i) = log(power.power(:,:,:,i));
end
power_plot = mean(power.power,4);
%power_plot = mean(power_plot,4);

index1 = find(power.freqs==freq_limit(1),1);
index2 = find(power.freqs==freq_limit(2),1);

power_plot = power_plot(:,index1:index2,:);
freq_plot = power.freqs(index1:index2);

paper_size = [1800,600];

fig = figure('Units','Pixel','Position',[100,100,paper_size]);
fontname = 'Arial';
fontsize = 14;

for i = 1:ncluster

        subplot(1,ncluster,i);
       
        chan = cluster(i).channel;
        name = cluster(i).name;
        
        data_plot = squeeze(mean(power_plot(chan,:,:),1));
        
        plot(freq_plot,data_plot(:,1),'b');
        hold on;
        plot(freq_plot,data_plot(:,2),'k');
        xlim = [0,25];
        ylim = [0,15];
        axis([xlim,ylim]);
        t = title(name,'Fontname',fontname,'FontSize',fontsize);
        xlabel('Frequency (Hz)','FontName',fontname,'FontSize',fontsize);
        ylabel('Power (db)','FontName',fontname,'FontSize',fontsize);
end

leg = legend(power.category_names);
set(leg,'interpreter','none','Fontname',fontname,'FontSize',fontsize);
set(gca,'Fontname',fontname,'FontSize',fontsize);

end