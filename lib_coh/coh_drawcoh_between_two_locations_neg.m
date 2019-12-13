%allow negative
function coh_drawcoh_between_two_locations_neg(chanlocs,num1,num2,coh_value)
    linewidth = floor(abs(coh_value) *10)+1;

if coh_value < 0
    colorname = [0,0,1]; %blue for negative
else
    colorname = [1,0,0];%red for positive
end
   linestyle = '-';
   coh_line_between_two_locations(chanlocs,num1,num2,linewidth,linestyle,colorname);
    
end