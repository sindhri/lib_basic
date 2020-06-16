%calculate one cond with one behavioral and plot
function corrintable = FH_plot_cond1_behavioral1(EEG_ave,behavioral,...
    cond_selected,behavioral_selected)
%cond_selected = 6;
%behavioral_selected = 26;
corrintable = FH_cal_all_cor_2(EEG_ave,behavioral,cond_selected,...
    behavioral_selected);

cond_to_plot = 1; 
column_to_plot = 2; 
%split into two plots so can have finer resolution
items = 50:50:250;
FH_plot_cor2(corrintable,cond_to_plot,column_to_plot,items);
items = 300:50:500;
FH_plot_cor2(corrintable,cond_to_plot,column_to_plot,items);
items = 550:50:750;
FH_plot_cor2(corrintable,cond_to_plot,column_to_plot,items);
items = 800:50:1000;
FH_plot_cor2(corrintable,cond_to_plot,column_to_plot,items);
end