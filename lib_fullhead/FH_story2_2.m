%20200207, used condition_selected in the first step
%20200203, added more colors, rearranged for nplot=8, added title
%20200203, used doi, can do amplitude if it's a peak
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

EEGAVE = FH_select_condition(EEGAVE,cond_selected);
ncond = length(EEGAVE.eventtypes);
    doi = calc_doi_simple(EEGAVE,poi);    
    
    res = get(0,'screensize');
    f = figure;
    set(f,'position',[0,0,res(3),res(4)*0.75]);
    
    color_lib = {'b','r','g','k','m','c','y','b'};

    nplot = ncond;
    output_data = [];
    for i= 1:nplot
        if nplot~=8
            subplot(1,nplot,i);
        else
            nrow = 2;
            ncol = 4;
            subplot(nrow,ncol,i);
        end
        if isfield(doi,'data_avg')
            x = doi.data_avg(:,i+1);
        else
            x = doi.data_amplitude(:,i+1);
        end
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
        xlabel(EEGAVE.eventtypes{i},'fontweight','bold','interpreter','none');
        title(poi.name,'interpreter','none');
        hold off
    end
    vnames = cell(1);
    vnames{1} = 'ID';
    for i = 2:ncond+1
        vnames{i} = [EEGAVE.eventtypes{i-1} '_' poi.name '_' int2str(poi.time(1)) '_to_' int2str(poi.time(2)) 'ms_' poi.stats_type];
    end
    output_table = array2table(output_data,'VariableNames',vnames);

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
