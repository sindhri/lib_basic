%20201113, added option for there was 1x1 struct in the cell, need to
%double check. 
% Adjusted items when the plotting time is 900ms
% Fixed another bug, input sequence of FH_plot_cor2
%20200208
%ptable is either correlation table or difference table
%it has p value but also other information

function FH_plot_pmap_alltimes(ptable,cond_to_plot,column_to_plot)
%cond_to_plot = 6; %high1-high2
%column_to_plot = 2; %group difference
%split into two plots so can have finer resolution
%plot_time(1) = round(ptable(1,2).times(1)/100)*100;
    ctable = ptable(cond_to_plot,column_to_plot);
    vname = ctable.Properties.VariableNames{1};
    if istable(ctable.(vname))
        plot_time_end_time = round(ctable.(vname).times(end)/100)*100;
    else
        struct_array = ctable.(vname);
        if length(struct_array)>1
            ccell = ctable.(vname){1};
        else
            ccell = ctable.(vname);
        end
        plot_time_end_time = round(ccell.times(end)/100)*100;
    end    
if plot_time_end_time==1000
    items = [50:50:250;300:50:500;550:50:750;800:50:1000];
else
    if plot_time_end_time == 900
    end
    items = [0:50:200;250:50:450;500:50:700;700:50:900];
end
for i = 1:size(items,1)
    FH_plot_cor2(ptable,items(i,:), cond_to_plot,column_to_plot);
end

end