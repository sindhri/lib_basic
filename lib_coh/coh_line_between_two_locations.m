function [x1,y1,x2,y2]=coh_line_between_two_locations(chanlocs,num1,...
    num2,linewidth,linestyle,colorname)

if nargin==3
    linewidth = 1;
    linestyle = '-';
    colorname = 'k';
end
    [x1,y1] = coh_getxy_from_chanlocs(chanlocs,num1);
    [x2,y2] = coh_getxy_from_chanlocs(chanlocs,num2);
    line([x1,x2],[y1,y2],'Color',colorname,...
 'LineWidth',linewidth,'LineStyle',linestyle);
end

