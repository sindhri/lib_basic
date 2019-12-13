category_names = {'neutralcue','neutralcuelose','neutralcuewin',...
    'punishcuelose','punishcuewin','punishment',...
    'rewardcue','rewardcuelose','rewardcuewin'};
ITC_count_trials(category_names,1);


path_result = [pwd filesep 'result' filesep];

items = [-200,0:100:700];
net_type = 1;

group_name = '';
selected_conditions = {[2,3],[4,5],[8,9],[1,6],[1,7],[6,7]};
selected_frequencies = {[4,7],[8,12],[14,27]};
for i = 1:length(selected_frequencies)
    for j = 1:length(selected_conditions)
        [foi_ERSP,foi_ITC] = ITC_recompose_to_fullheadmap(selected_frequencies{i},...
        [path_result group_name filesep],net_type,items,group_name,selected_conditions{j});
        ERSP_name = ['foi_struct/foi_ERSP_' num2str(selected_frequencies{i}(1)) '_' num2str(selected_frequencies{i}(2)) '_' category_names{selected_conditions{j}(1)} '_' category_names{selected_conditions{j}(2)}];
        save([ERSP_name '.mat'], 'foi_ERSP');
        ITC_name = ['foi_struct/foi_ITC_' num2str(selected_frequencies{i}(1)) '_' num2str(selected_frequencies{i}(2)) '_' category_names{selected_conditions{j}(1)} '_' category_names{selected_conditions{j}(2)}];
        save([ITC_name '.mat'], 'foi_ITC');
       
    end
end


%20190212, exporting values based on pre-calculated averaged frequency value
%through ITC_fullhead_recompose_individual
path_result = [pwd filesep 'result' filesep];
group_name = '';

%[4,7]
foi = [4,7];
foi_struct = ITC_fullhead_recompose_individual(foi,path_result,group_name);

toi = [100,300;400,600];
cluster.name = 'frontal';
cluster.channel = [11,12,5,6];
export_text = 'n';
doi_ERSP = ITC_fullhead_create_doi_from_foi(foi_struct,cluster,toi,...
    'ERSP',export_text);

toi = [100,300;400,600];
cluster.name = 'frontal';
cluster.channel = [11,12,5,6];
export_text = 'n';
doi_ITC = ITC_fullhead_create_doi_from_foi(foi_struct,cluster,toi,...
    'ITC',export_text);

doi = ITC_combine_export_2doi(doi_ERSP,doi_ITC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% limit = [-1.5,1.5];
% limit_diff = [-0.5,0.5];
% ITC_fullhead_heatmap_auto(foi_ERSP11,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP21,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP31,items,limit,limit_diff);
% 
% limit = [-2.9,2.9];
% limit_diff = [-0.5,0.5];
% ITC_fullhead_heatmap_auto(foi_ERSP12,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP22,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP32,items,limit,limit_diff);
% 
% limit = [-1.2,1.2];
% limit_diff = [-0.4,0.4];
% ITC_fullhead_heatmap_auto(foi_ERSP13,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP23,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP33,items,limit,limit_diff);
% 
% limit = [-0.8,0.8];
% limit_diff = [-0.5,0.5];
% ITC_fullhead_heatmap_auto(foi_ERSP14,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP24,items,limit,limit_diff);
% ITC_fullhead_heatmap_auto(foi_ERSP34,items,limit,limit_diff);