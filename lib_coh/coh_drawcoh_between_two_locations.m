function coh_drawcoh_between_two_locations(chanlocs,num1,num2,coh_value)

linewidth = floor(coh_value *10)+1;

    colorname = [1-coh_value,1-coh_value,1-coh_value]; %blue for negative
linestyle = '-';

coh_line_between_two_locations(chanlocs,num1,num2,linewidth,linestyle,colorname);

end