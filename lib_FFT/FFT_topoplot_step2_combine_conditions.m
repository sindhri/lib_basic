
%input power from step1, then eyeball the maplimits
%maplimits is a cell, each [] has a min and max for a particular frequency
%for example, if there are 2 freqs in power
%maplimits = {[-1,2],[1,3]} for two freqs respectively

%20151102, fixed a bug of data_plot total size
%20160414, removed the log transfer
%20160117, added input selected_conditions for plotting, 
%selected_conditions.conditions = {[1],[2:5],[7:10]};
%selected_conditions.condition_names = {'aaa','bbb'};

function [data_plot,title_names]=FFT_topoplot_step2_combine_conditions(power,...
    selected_conditions,maplimits,maplimits_diff)

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
power_ave = squeeze(mean(power.data,1)); %average across subjects

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

nc_new = length(selected_conditions.conditions);
data_new=zeros(nc_new,nchan,nf);
for i = 1:nc_new
    current_cond = selected_conditions.conditions{i};
    data_new(i,:,:) = mean(data(current_cond,:,:),1);
end

has_diff = 0;
if nc_new==2
    nc_new=3;
    has_diff = 1;
    selected_conditions.condition_names{3}=['diff_' selected_conditions.condition_names{1} '-' selected_conditions.condition_names{2}];
end
%data_converted = zeros(nf,nc,nchan);
data_converted = zeros(nf,nc_new,nchan);
for i = 1:nf
    for j = 1:nc_new
        for p = 1:nchan
            if j<3
                data_converted(i,j,p) = data_new(j,p,i);
            else
                data_converted(i,j,p) = data_new(1,p,i)-data_new(2,p,i);
            end
        end
    end
end


%make plots

eloc = readlocs('GSN-HydroCel-129_removedtop3.sfp');
%maplimits = {[-4,4],[-3,3]};

data_plot = zeros(nchan,nf*nc_new);

m=1;
title_names=cell(1);

for i = 1:nf
    for j = 1:nc_new
        %subplot(nf,nc_new,(i-1)*nc_new+j);
        figure;
        data_plot(:,m) = squeeze(data_converted(i,j,:));
        
        if has_diff==0
            if nargin>=3 
                cmap = colormap;
                if maplimits{i}(1)==0
                    cmap(1:31,:)=[];
                end
                topoplot(data_plot(:,m),eloc,'maplimits',maplimits{i},...
                'colormap',cmap,'plotrad',0.51,'electrodes','on',...
                'emarker',{'o','k',[],1});
            else
                topoplot(data_plot(:,m),eloc,'plotrad',0.51,'electrodes',...
                    'on','emarker',{'o','k',[],1});
            end
        else
            if j<3
                if nargin>=3 
                    cmap = colormap;
                    if maplimits{i}(1)==0
                        cmap(1:31,:)=[];
                    end
                    topoplot(data_plot(:,m),eloc,'maplimits',maplimits{i},...
                'colormap',cmap,'plotrad',0.51,'electrodes','on',...
                'emarker',{'o','k',[],1});
                else
                    topoplot(data_plot(:,m),eloc,'plotrad',0.51,...
                        'electrodes','on','emarker',{'o','k',[],1});
                end
            else
                if nargin==4
                    topoplot(data_plot(:,m),eloc,'maplimits',maplimits_diff{i},...
                'colormap',colormap,'plotrad',0.51,'electrodes','on',...
                'emarker',{'o','k',[],1});
                else
                    topoplot(data_plot(:,m),eloc,'plotrad',0.51,...
                        'electrodes','on','emarker',{'o','k',[],1});
                end
            end
        end
        title_names{m} = [freq_names{i} ' ' power.group_name ' ' selected_conditions.condition_names{j}];
        %h=title(title_names{m},'FontName','Arial','FontSize',18);
        %set(h,'interpreter','none');
        colorbar;
        
        set(gca,'FontName','Arial','FontSize',22);
        set(gcf, 'PaperPosition', [0 0 5 3.5]); %Position plot at left hand corner with width 5 and height 5.
        set(gcf, 'PaperSize', [5 3.5]); 
        saveas(gcf,['plot' title_names{m} '.pdf']);
        saveas(gcf,['plot' title_names{m} '.png']);
        close;
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