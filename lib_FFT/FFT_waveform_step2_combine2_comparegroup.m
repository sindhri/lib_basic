%m waveformplots
%m = length of cluster
%in each plots, ncond of waves

%combine 2 groups

%20170821, added log function to transfer the plot to log
%fixed a small bug, should not affect previous plot
%had to remove the first first point which doesn't make sense.

function FFT_waveform_step2_combine2_comparegroup(power1,power2,...
    freq_limit,cluster,log_or_not)

ncluster = length(cluster);

[nchan,ntimes,ncond,~] = size(power1.power);
power_plot = zeros(nchan,ntimes,ncond,2);


power_plot(:,:,:,1) = mean(power1.power,4);
power_plot(:,:,:,2) = mean(power2.power,4);


index1 = find(power1.freqs==freq_limit(1),1)+1;
index2 = find(power1.freqs==freq_limit(2),1);

power_plot = power_plot(:,index1:index2,:,:);

if log_or_not == 1
    power_plot = log(power_plot);
end

freq_plot = power1.freqs(index1:index2);
title_names = power1.category_names; 

paper_size = [2000,1000];

fig = figure('Units','Pixel','Position',[100,100,paper_size]);
fontname = 'Arial';
fontsize = 25;

legend_text = {power1.group_name,power2.group_name};
for m = 1:2 %now represents conditions
    
    for i = 1:ncluster
        current = ncluster*(m-1)+i;
        current_plot = subplot(2,ncluster,current);
        pos_plot = get(current_plot,'Position');
        pos_plot(1) = pos_plot(1)+0.032;
        set(current_plot,'Position',pos_plot);
       
        chan = cluster(i).channel;
        name = cluster(i).name;
        tname = name;
        ltname = length(tname);
        name = [upper(tname(1)) tname(2:ltname)];
        
        data_plot = squeeze(mean(power_plot(chan,:,:,:),1));
        
        plot(freq_plot,data_plot(:,m,1),'color','r','linewidth',1.5);
        hold on;
        plot(freq_plot,data_plot(:,m,2),'color','k','linewidth',1.5);
        xlim ([0,25]);
        ylim ([-3.5,4]);
        if m == 1
            t = title(name,'Fontname',fontname,'FontSize',fontsize);
            set(t,'interpreter','none');
        end
        if m == 2
            xlabel('Frequency (Hz)','FontName',fontname,'FontSize',fontsize);
        end
        
        set(gca,'Fontname',fontname,'FontSize',fontsize);
        if i == 1
            if m == 1
                leg = legend(legend_text);
                pos_leg = get(leg,'Position');
                pos_leg(1) = pos_leg(1)-0.15;
                pos_leg(2) = pos_leg(2)-0.37;
                set(leg,'interpreter','none','Fontname',fontname,'FontSize',fontsize);
                set(leg,'Position',pos_leg);
            end
            if log_or_not == 0
                te = text(-37,5,title_names{m},'FontName',fontname,...
                'FontSize',fontsize,'interpreter','none');
                ylab = ylabel('Power (\muV^2/Hz)','FontName',fontname,'FontSize',fontsize);
            else
                 te = text(-37,1,title_names{m},'FontName',fontname,...
                'FontSize',fontsize,'interpreter','none');

                ylab = ylabel('Log Power (\muV^2/Hz)','FontName',fontname,'FontSize',fontsize);
            end
            
            pos_ylab = get(ylab,'Position');
            pos_ylab(1) = pos_ylab(1)-2;
            set(ylab,'Position',pos_ylab);
            
        end
    
    end

end

set(gcf,'PaperPosition',[0,0,paper_size/100],'paperSize',paper_size/100);
if log_or_not == 0
    saveas(gcf,'waveform_plot','pdf');
else
    saveas(gcf,'waveform_plot_log','pdf');
end

close
end

