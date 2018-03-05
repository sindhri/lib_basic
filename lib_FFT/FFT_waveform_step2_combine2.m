%m waveformplots
%m = length of cluster
%in each plots, ncond of waves

%combine 2 groups

function FFT_waveform_step2_combine2(power1,power2,freq_limit,cluster)

ncluster = length(cluster);


power_plot = zeros(size(power1.power));


power_plot(:,:,:,1) = mean(power1.power,4);
power_plot(:,:,:,2) = mean(power2.power,4);


index1 = find(power1.freqs==freq_limit(1),1);
index2 = find(power1.freqs==freq_limit(2),1);

power_plot = power_plot(:,index1:index2,:,:);
freq_plot = power1.freqs(index1:index2);
title_names = {power1.group_name,power2.group_name};

paper_size = [2000,1000];

fig = figure('Units','Pixel','Position',[100,100,paper_size]);
fontname = 'Arial';
fontsize = 25;

for m = 1:2
    
    for i = 1:ncluster
        current = ncluster*(m-1)+i;
        current_plot = subplot(2,ncluster,current);
        pos_plot = get(current_plot,'Position');
        pos_plot(1) = pos_plot(1)+0.032;
        set(current_plot,'Position',pos_plot);
       
        chan = cluster(i).channel;
        name = cluster(i).name;
        
        data_plot = squeeze(mean(power_plot(chan,:,:,:),1));
        
        plot(freq_plot,data_plot(:,1,m),'color','b','linewidth',1.5);
        hold on;
        plot(freq_plot,data_plot(:,2,m),'color','k','linewidth',1.5);
        xlim = [0,25];
        ylim = [0,10];
        axis([xlim,ylim]);
        if m == 1
            t = title(name,'Fontname',fontname,'FontSize',fontsize);
        end
        if m == 2
            xlabel('Frequency (Hz)','FontName',fontname,'FontSize',fontsize);
        end
        
        set(gca,'Fontname',fontname,'FontSize',fontsize);
        if i == 1
            if m == 1
                leg = legend(power1.category_names);
                pos_leg = get(leg,'Position');
                pos_leg(1) = pos_leg(1)-0.15;
                pos_leg(2) = pos_leg(2)-0.35;
                set(leg,'interpreter','none','Fontname',fontname,'FontSize',fontsize);
                set(leg,'Position',pos_leg);
            end
            text(-30,5,title_names{m},'FontName',fontname,'FontSize',fontsize);
            ylab = ylabel('Power (\muV^2/Hz)','FontName',fontname,'FontSize',fontsize);
            pos_ylab = get(ylab,'Position');
            pos_ylab(1) = pos_ylab(1)+0.032;
            set(ylab,'Position',pos_ylab);
            
        end
    
    end

end

set(gcf,'PaperPosition',[0,0,paper_size/100],'paperSize',paper_size/100);
saveas(gcf,'waveform_plot','pdf');
close
end

