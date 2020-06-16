%20200207 fixed a typo!!! may influence earlier results
%20200204
%select the condition for EEG_ave
%EEG_ave.data is chan*times*ncond*nsubj
function EEG_ave = FH_select_condition(EEG_ave,cond_selected)
EEG_ave.data = EEG_ave.data(:,:,cond_selected,:);
temp = {EEG_ave.eventtypes{:}};
EEG_ave.eventtypes = temp(cond_selected);
end