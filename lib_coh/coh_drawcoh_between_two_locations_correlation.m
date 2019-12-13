%20190922, critical_values has three levels, p = .10, .05, .01, lindwidth
%1, 2, 3,
function coh_drawcoh_between_two_locations_correlation(chanlocs,...
    num1,num2,coh_value,critical_value)

    linewidth = 1;
    if coh_value < critical_value(1)
        linestyle = '-.';
        linewidth = 1;
        colorname = 'w';
    end

    if coh_value > critical_value(1) && coh_value < critical_value(2)
        linestyle = '-';
        colorname = [1,0.9,0]; %yellow
%        linewidth = 1;
        linewidth = 3;
    end

    if coh_value > critical_value(2) && coh_value < critical_value(3)
        linestyle = '-';
        colorname = [1,0.5,0]; %orange
 %       linewidth = 2;
        linewidth = 3;
    end

    if coh_value > critical_value(3)
        linestyle = '-';
        colorname = 'r';
        linewidth = 3;
    end

coh_line_between_two_locations(chanlocs,num1,num2,linewidth,linestyle,colorname);

end