%20200208, select condition so it doesn't take too long
%added group_match being table situation
%20200208, added catch in case the last step didn't convert
%20200208, moved get_rm to be its own function FH_get_rm
%EEGAVE, difference between every condition contrast
%20190402, added nsubj in the grid
%20191017, data structures change to nchan xdatapoint x ncond x nsubj
%20191111, repeated measure anova with 1 between subject variable
%pretreat between_var to match the sequence in EEGAVE
%between_var can be a nx1 cell, eg, ['exposed';'exposed';...'control';'control']
%or it can just be an array of numbers
function [rmintable,rminstruct,Me] = FH_cal_all_rm1_2(EEGAVE,group_match,cond_selected)
if nargin==3
    EEGAVE = FH_select_condition(EEGAVE,cond_selected);
end

if istable(group_match)
    vname = group_match.Properties.VariableNames{2};   
    group_new.ID = group_match.ID;
    group_new.group = group_match.(vname);
    group_match = group_new;
end

eventtypes = EEGAVE.eventtypes;
[~,~,ncond,~] = size(EEGAVE.data);
subjects = EEGAVE.ID;
subjects2 = group_match.ID;
temp = subjects - subjects2;
if ~isempty(find(temp~=0))
    fprintf('subject list inconsistent, abort\n');
    return
end
rm_grid = {};
    for i = 1:ncond-1
        rm_per_row = {eventtypes{i}};

        for m = 1:i
            rm_per_row{end+1} =[];
        end
        for j = i+1:ncond
            cgrid = [];
                fprintf('\n\ni=%d out of %d, j=%d out of %d\n',i,ncond,j,ncond);
                fprintf('running ranova of %s and %s and group\n',eventtypes{i},eventtypes{j});
                data1 = squeeze(EEGAVE.data(:,:,i,:));
                data2 = squeeze(EEGAVE.data(:,:,j,:));
                fprintf('processing......\n');
                condname1 = eventtypes{i};
                condname2 = eventtypes{j};
                [within,between] = FH_get_rm(data1,...
                    data2,group_match.group);
                cgrid.within = within;
                cgrid.between = between;
                cgrid.nsubj = size(data1,3);
                cgrid.name1 = eventtypes{i};
                cgrid.name2 = eventtypes{j};
                cgrid.nbchan = EEGAVE.nbchan;
                cgrid.pnts = EEGAVE.pnts;
                cgrid.srate = EEGAVE.srate;
                cgrid.xmin = EEGAVE.xmin;
                cgrid.xmax = EEGAVE.xmax;
                cgrid.times = EEGAVE.times;
                cgrid.chanlocs = EEGAVE.chanlocs;
            rm_per_row{end+1} = cgrid;
        end
        rm_grid = [rm_grid;rm_per_row];
    end
    rowHeadings={'eventtype',eventtypes{:}};
    rminstruct = cell2struct(rm_grid,rowHeadings,2);
    try
        rmintable = struct2table(rminstruct);
    catch Me
    end
end
