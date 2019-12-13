%20190926, added title name for the file
%20190921, plot multiple disks of different frequencies on the same screen
%only work for 1 condition for now

%20190920, plot log, simplified process by using power_ave from

%FFT_topoplot_step1
%20190918, add the line of calculating log back in
%20190918, removed 'plotrad', 0.51. it would remove the areas outside of
%the head area, instead of increasing the size of the head


%input power from step1, then eyeball the maplimits
%maplimits is a cell, each [] has a min and max for a particular frequency
%for example, if there are 2 freqs in power
%maplimits = {[-1,2],[1,3]} for two freqs respectively

%20151102, fixed a bug of data_plot total size
%20160414, removed the log transfer
%20180125, added exception for nan case, no plot skip

function maplimits=FFT_topoplot_step2_multiple(power,title_names,maplimits,title_name)

if nargin<4
    title_name = 'power_log';
end
frequency_range_cell = power.frequency_range_cell;
condition_names = power.condition_names;
nc = length(condition_names);
nf = length(frequency_range_cell);


freq_names=cell(1);
for i= 1:nf
    freq = frequency_range_cell{i};
    freq_names{i} = [num2str(freq(1)) ' to ' num2str(freq(2)) 'Hz'];
end


%power_ave = squeeze(mean(power.data,1));

%switch to plot log or raw
%power_to_plot = mean(power.power_ave,4);
power_to_plot = mean(power.power_ave_log,4);

%make plots
%nchan = nchan-1; %not plot 129

eloc = readlocs('GSN-HydroCel-129_removedtop3.sfp');
res = get(0,'screensize');
  %eloc = readlocs('GSN-HydroCel-128_removedtop3.sfp');
%maplimits = {[-4,4],[-3,3]};
m=1;

load('colormap_red_blue.mat');
cmap = red_blue;
for j = 1:nc
    f = figure;
    set(f,'position',[0,0,res(3),res(4)/3]);
    for i = 1:nf
        subplot(1,nf,i);
        data_plot = power_to_plot(:,i,j);
        if isnan(data_plot)
            continue
        end

%        if nargin==3 
%            if maplimits{i}(1)==0
%                cmap(1:31,:)=[];
%            end
%        else
%            datam = mean(data_plot);
%            datasd = std(data_plot);
%            maplimits{i} = [datam - datasd*3, datam+datasd*3];
%        end
%        topoplot(data_plot,eloc,'maplimits',maplimits{i},'colormap',cmap,...
%            'electrodes','on','emarker',{'o','k',[],1},'whitebk','on');
        topoplot(data_plot,eloc,'maplimits',maplimits{i},'colormap',cmap,...
            'electrodes','on','whitebk','on');
        
        if nargin==1
            title_names{m} = [freq_names{i} ' ' power.group_name ' ' condition_names{j}];
        end
        h=title(title_names{m});
        set(h,'interpreter','none','FontSize',20);
        cb = colorbar;
%        set(cb,'FontSize',15);
        pos = get(cb,'Position');
        set(cb,'Position',[pos(1)+0.03,pos(2),pos(3)*0.5,pos(4)]);
%        cb.Label.Position = [pos(1) maplimits{i}(2)*1.5]; % to change its position
 %       cb.Label.Rotation = 0;
 %       cb.Label.String = 'Poewr (Log)';
 %       cb.Label.FontSize = 15;

        m=m+1;
    end
    set(gcf,'Position',[0 0 res(3) res(4)/3]);
    if ~exist('plot_fullhead/','dir')
       mkdir('plot_fullhead');
    end
    saveas(gcf,['plot_fullhead/' title_name '.png']);
    close
end
end

%make the average plots across conditions
%for i = 1:nf
%    data_plot(:,nf*nc+i) = mean(data_plot(:,(i-1)*nc+1:i*nc),2);
%    figure;
%        if nargin==2
%%            topoplot(data_plot(:,nf*nc+i),eloc,'maplimits',maplimits{i},'plotrad',0.51);
%            topoplot(data_plot(:,nf*nc+i),eloc,'maplimits',maplimits{i});
%        else
% %           topoplot(data_plot(:,nf*nc+i),eloc,'plotrad',0.51);
%            topoplot(data_plot(:,nf*nc+i),eloc);
%%            topoplot(data_plot(:,nf*nc+i),eloc,'electrodes','numbers');
%        end            
%        title_names{m} = [freq_names{i} ' ' power.group_name];
%        h=title(title_names{m});
%        set(h,'interpreter','none');
%        colorbar;
%end
