%20190920, adjust it to take the struct report.
%20190920, only 1 time point, for plotting just pvalues for full head but 1
%time, only 1 condition, for SPR 2019
%corrintable is not an array, just a regular table, row is condition,
%column is behavioral that was correlated
function FH_plot_cor_1time_r(report,chan_locs_file)
    if nargin==1
        chan_locs_file = 'GSN-HydroCel-129minus3.sfp';
    end
    chan_locs = pop_readlocs(chan_locs_file);
    
    res = get(0,'screensize');

    f = figure;

    set(f,'position',[0,0,res(3),res(4)]);
       data = report.r_list;
    %maplimits = [-max(abs(data)),max(abs(data))];
    maplimits = [-0.25,0.25];
           topoplot(data,chan_locs,...
                'maplimits',maplimits,'style','map',...
                'electrodes','numbers',...
                'whitebk','on','shading','interp');

            axcopy;
        b = colorbar;
               
%        set(b,'position',[pos(1)+0.1,pos(2),colorbar_width_param,0.5]);
        set(b,'FontSize',15);
        %0.10 critical r value 0.138
        %0.05 critical r value 0.164
        %0.01 critical r value 0.215
        
       
        title(report.name,'interpreter','none','FontSize', 20);
        pos = get(b,'Position');

        
        b.Label.Position = [pos(1) 0.32]; % to change its position
        b.Label.Rotation = 0;
        b.Label.String = 'r value';
        b.Label.FontSize = 20;
       
        set(gcf,'Position',[100 100 500 500]);
        
        if ~exist('plot_fullhead/','dir')
            mkdir('plot_fullhead');
        end
        saveas(gcf,['plot_fullhead/' report.name '_r.png']);
        close;
end