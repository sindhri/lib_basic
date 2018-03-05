
%input power from step1, then eyeball the maplimits
%maplimits is a cell, each [] has a min and max for a particular frequency
%for example, if there are 2 freqs in power
%maplimits = {[-1,2],[1,3]} for two freqs respectively

%20151102, fixed a bug of data_plot total size
%20160414, removed the log transfer
%20180125, added exception for nan case, no plot skip

function [data_plot,title_names]=FFT_topoplot_step2(power,maplimits)

frequency_range_cell = power.frequency_range_cell;
condition_names = power.condition_names;
nchan = power.nchan;

nc = length(condition_names);
nf = length(frequency_range_cell);


freq_names=cell(1);
for i= 1:nf
    freq = frequency_range_cell{i};
    freq_names{i} = [num2str(freq(1)) ' to ' num2str(freq(2)) 'Hz'];
end


%prepare and convert data
%power_log = log(power.data);
power_ave = squeeze(mean(power.data,1));

data=zeros(nc,nchan,nf);
index=zeros(nc*nchan*nf,1);
m = 1;
for i = 1:nc
    for j = 1:nchan
        for p = 1:nf
            index(m) = (i-1)*nchan*nf+(j-1)*nf+p;
            data(i,j,p) = power_ave(index(m));
            m = m+1;
        end
    end
end

data_converted = zeros(nf,nc,nchan);
for i = 1:nf
    for j = 1:nc
        for p = 1:nchan
            data_converted(i,j,p) = data(j,p,i);
        end
    end
end


%make plots

eloc = readlocs('GSN-HydroCel-129_removedtop3.sfp');
%maplimits = {[-4,4],[-3,3]};
data_plot = zeros(nchan,nf*(nc+1));
m=1;
title_names=cell(1);
load('colormap_red_blue.mat');
cmap = red_blue;
for i = 1:nf
    for j = 1:nc
        data_temp = data_converted(i,j,:);
        if isnan(data_temp)
            continue
        end
        data_plot(:,m) = squeeze(data_temp);
        figure;

        if nargin==2 
            if maplimits{i}(1)==0
                cmap(1:31,:)=[];
            end
%            topoplot(data_plot(:,m),eloc,'maplimits',maplimits{i},'plotrad',0.51);
            topoplot(data_plot(:,m),eloc,'maplimits',maplimits{i},'colormap',cmap,'plotrad',0.51,'electrodes','on','emarker',{'o','k',[],1});
        else
%            topoplot(data_plot(:,m),eloc,'plotrad',0.51);
            topoplot(data_plot(:,m),eloc,'plotrad',0.51,'electrodes','on','emarker',{'o','k',[],1});
        end            
        title_names{m} = [freq_names{i} ' ' power.group_name ' ' condition_names{j}];
        h=title(title_names{m});
        set(h,'interpreter','none');
        colorbar;
        
        if ~exist('plot_fullhead/','dir')
            mkdir('plot_fullhead');
        end
        saveas(gcf,['plot_fullhead/' title_names{m} '.png']);
        close
        m=m+1;
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
end