%only correlational results
%20190306, input EEGAVE, place of interest, and condition selected
%do paird sampled t tests of selected conditions at place of interest
%and make plots of the whole region
%poi.name, cluster, time
%EEGAVE data, chan x time x subj x cond

%20190402
%include a behavioral measurement and plot the correlation of both
%conditions
%eg, behavioral.ID, behaviroal.BFNE_total
%20191017, data chan x time x ncon x subj

function output_table = FH_story2_2(EEGAVE,poi,cond_selected,behavioral,measure_name)
 
    time_index = find_valid_pos(poi.time,EEGAVE.times);
    data = EEGAVE.data(poi.cluster,time_index(1):time_index(2),cond_selected,:);
    data_ttest = mean(mean(data,1),2);
    data_ttest = squeeze(data_ttest);
    data_ttest = data_ttest';
    
    res = get(0,'screensize');
    f = figure;
    set(f,'position',[0,0,res(3),res(4)*0.75]);
    
    color_lib = {'b','r','g','k','m','c'};

    nplot = length(cond_selected);
    output_data = [];
    for i= 1:nplot
        subplot(1,nplot,i);
        x = data_ttest(:,i);
        cbehavioral = behavioral.(measure_name);
        
        [common_id,data_id_newindex,cbehavioral] = select_IDs(EEGAVE.ID,behavioral.ID,cbehavioral);
        cdata = x(data_id_newindex,:);
        if i==1
            output_data = [EEGAVE.ID(data_id_newindex),cdata];
        else
            output_data = [output_data,cdata];
        end
        make_regression_line_modified(cdata,cbehavioral,color_lib{i});
%        ylim([min(cbehavioral),max(cbehavioral)]);
%        xlim([min(cdata),max(cdata)]);
        %xticks([-5:5]);
        %xticklabels({'0','20','40','60','80','100'});
        ylabel(measure_name,'fontweight','bold','interpreter','none');
        %yticks([50,100,150,200])
        %yticklabels({'50','100','150','200'});
        xlabel(EEGAVE.eventtypes{cond_selected(i)},'fontweight','bold');
        hold off
    end
    vnames = cell(1);
    vnames{1} = 'ID';
    for i = 2:length(cond_selected)+1
        vnames{i} = [EEGAVE.eventtypes{cond_selected(i-1)} '_' poi.name '_' int2str(poi.time(1)) '_to_' int2str(poi.time(2)) 'ms'];
    end
    output_table = array2table(output_data,'VariableNames',vnames);

end

function [items_pos, items_adjusted] = find_valid_pos(items,list)
    n = length(list);
    items_pos = round( (items-list(1))/(list(n)-list(1)) * (n-1))+1;
    items_pos(find(items_pos<1))=1;
    items_pos(find(items_pos>n))=n;
    items_adjusted = list(items_pos);
    
    for i = 1:size(items,1)
        for j = 1:size(items,2)
            if items(i,j)~=items_adjusted(i,j)
                fprintf('time %d adjusted to %d\n', items(i,j),items_adjusted(i,j));
            end
        end
    end
end


function print_t_result(h,p,stats)
    if h==0
        fprintf('not significant.\n');
    else
        fprintf('significant.\n');
    end
    fprintf('t(%d)=%.3f, p=%.3f\n',stats.df,stats.tstat,p);
end

function [common_id,data_id_newindex,behavioral_new] = select_IDs(data_id,behavioral_id,behavioral)
    fprintf('input data n = %d, behavioral n = %d\n',length(data_id),length(behavioral_id));
    nan_list = isnan(behavioral);
    if ~isempty(nan_list)
        fprintf('found %d nan case\n',sum(nan_list));
    end
    behavioral_id(nan_list) = [];
    behavioral(nan_list) = [];
    [C,IA,IB] = intersect(data_id,behavioral_id);
    data_id_newindex = IA;
    behavioral_new = behavioral(IB);
    common_id = C;
    fprintf('found %d common ids\n',length(common_id));
end
