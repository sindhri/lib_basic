%20190921, plot multiple r topoplots in a row, report_array is a cell,
%and each element is a report struct
%20190920, adjust it to take the struct report.
%20190920, only 1 time point, for plotting just pvalues for full head but 1
%time, only 1 condition, for SPR 2019
%corrintable is not an array, just a regular table, row is condition,
%column is behavioral that was correlated

function FH_plot_cor_1time_r_multiple(report_array,chan_locs_file)
    if nargin==1
        chan_locs_file = 'GSN-HydroCel-129minus3.sfp';
    end
    chan_locs = pop_readlocs(chan_locs_file);
    
    res = get(0,'screensize');

    f = figure;
    set(f,'position',[0,0,res(3),res(4)/3]);
    maplimits = [-0.25,0.25];
    
    for i = 1:length(report_array)
        subplot(1,length(report_array),i);
        report = report_array{i};
        data = report.r_list;
        topoplot(data,chan_locs,'maplimits',maplimits,'style','map',...
        'electrodes','on','whitebk','on','shading','interp');
        axcopy;
        title(report.name,'interpreter','none','FontSize', 20);
    end
    
    %b = colorbar;
             
%   set(b,'position',[pos(1)+0.1,pos(2),colorbar_width_param,0.5]);
%    set(b,'FontSize',15);
    %0.10 critical r value 0.138
    %0.05 critical r value 0.164
    %0.01 critical r value 0.215
        
       
%    pos = get(b,'Position');

%    b.Label.Position = [pos(1) 0.32]; % to change its position
%    b.Label.Rotation = 0;
%    b.Label.String = 'r value';
%    b.Label.FontSize = 20;
       
    set(gcf,'Position',[0 0 res(3) res(4)/3]);
        
    if ~exist('plot_fullhead/','dir')
       mkdir('plot_fullhead');
    end
    saveas(gcf,'plot_fullhead/correlations.png');
    close;
end