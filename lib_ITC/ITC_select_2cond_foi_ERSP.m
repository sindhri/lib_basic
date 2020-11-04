% select 2 conditions from the foi_ERSP
% and compute the difference
% to feed to future plots of the two conditions and the difference

% 20201104
% the structure of foi_ERSP: an array of several components
% each is a condition
% foi_ERSP was calcuated from recomposing fullhead oscillation results
% the extract only one frequency range, but for all the participants,
% channels and time points

% followed the algorithm in ITC_prepare_data_for_heatmap_individual
% to caculate parameters like range and limit

function foi_selected = ITC_select_2cond_foi_ERSP(foi_ERSP, selected_conditions)
    if length(selected_conditions) ~=2
        fprintf('requires selecting two conditions. Abort.\n');
        return
    end
    
    for i = 1:length(selected_conditions)
        selected_condition = selected_conditions(i);
        foi_selected(i) = foi_ERSP(selected_condition);
    end
    
    foi_selected(3) = foi_selected(1);
    foi_selected(3).data = foi_selected(1).data - foi_selected(2).data;
    foi_selected(3).data_avg = foi_selected(1).data_avg - foi_selected(2).data_avg;
    foi_selected(3).setname = [foi_selected(1).setname '_minus_' foi_selected(2).setname];
    foi_selected(3).range = [min(foi_selected(3).data_avg(:)),max(foi_selected(3).data_avg(:))];
    foi_selected(3).mean = mean(foi_selected(3).data_avg(:));
    foi_selected(3).std = std(foi_selected(3).data_avg(:));
    foi_selected(3).abs = max(abs(foi_selected(3).mean - 2*foi_selected(3).std),...
        abs(foi_selected(3).mean+2*foi_selected(3).std));

    if strcmp(foi_selected(3).oscillation_type,'ITC')==1
        foi_selected(3).limit = [0, foi_selected(3).abs];
    else
        foi_selected(3).limit = [-foi_selected(3).abs,foi_selected(3).abs];
    end
end