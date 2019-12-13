%20190920, adjust it to take the struct report.
%20190920, only 1 time point, for plotting just pvalues for full head but 1
%time, only 1 condition, for SPR 2019
%corrintable is not an array, just a regular table, row is condition,
%column is behavioral that was correlated
function FH_plot_cor_1time(report,chan_locs_file)
    if nargin==1
        chan_locs_file = 'GSN-HydroCel-129minus3.sfp';
    end
    chan_locs = pop_readlocs(chan_locs_file);
    
    res = get(0,'screensize');

    f = figure;

    set(f,'position',[0,0,res(3),res(4)]);
       data = report.p_sign;
            %bmap= ones(40,3);
            %top to bottom
            %bmap(22,:)=[1,0.7,0]; %p is between 0.05 and 0.1, orange
            %bmap(21,:)=[1,0,0]; %p < .05, red
            %bmap(20,:)=[0,0,1]; %p <.05 negative, blue
            %bmap(19,:)=[0,0.7,1]; %p between 0.05 and 0.1, negative, light blue

            bmap= ones(200,3);
            %top to bottom
            for i = 106:110
                bmap(i,:)=[1,0.9,0]; %p is between 0.06 and 0.1, yellow
            end
            for i = 102:105
                bmap(i,:)=[1,0.5,0]; %p is between 0.01 and 0.05, orange
            end
            bmap(101,:)=[1,0,0]; %p < .01, red
            bmap(100,:)=[0,0,1]; %p <.01 negative, blue
            for i = 96:99
                bmap(i,:)=[0,0.5,1]; %p between 0.01 and 0.05, negative, light blue
            end
            for i = 91:94
                bmap(i,:)=[0,0.9,1]; %p between 0.06 and 0.1, negative, lighter blue
            end
           topoplot(data,chan_locs,...
                'maplimits',[-1,1],'style','map','colormap',...
                bmap,'electrodes','numbers','conv','on',...
                'whitebk','off','shading','interp');

            axcopy;
        b = colorbar;
%        set(b,'position',[pos(1)+0.1,pos(2),colorbar_width_param,0.5]);
        set(b,'position',[0.75,0.25,0.015,0.5]);
        set(b, 'YTick',[-1,-0.1,-0.05,-0.01,0,0.01,0.05,0.1,1], 'FontSize', 12);
        b.Limits = [-0.1,0.1];
        title(report.name,'interpreter','none','FontSize', 20);
        pos = get(b,'Position');
        
        b.Label.Position = [pos(1) 0.12]; % to change its position
        b.Label.Rotation = 0;
        b.Label.String = 'p value';
        b.Label.FontSize = 15;
       