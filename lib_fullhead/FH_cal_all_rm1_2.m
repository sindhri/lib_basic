%EEGAVE, difference between every condition contrast
%20190402, added nsubj in the grid
%20191017, data structures change to nchan xdatapoint x ncond x nsubj
%20191111, repeated measure anova with 1 between subject variable
%pretreat between_var to match the sequence in EEGAVE
%between_var can be a nx1 cell, eg, ['exposed';'exposed';...'control';'control']
%or it can just be an array of numbers
function rmintable = FH_cal_all_rm1_2(EEGAVE,group_match)
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
                [within,between] = get_rm(data1,...
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
    rmintable = struct2table(rminstruct);
end

function [within,between] = get_rm(data1,data2,between_var)
    
    [nchan,ndpt,~] = size(data1);

    for m = 1:nchan
        fprintf('\nchan %d dpt ',m);
        for n = 1:ndpt
            if mod(n,ndpt/10)==0
                fprintf('%d ',n);
            end
            cdata1 = squeeze(data1(m,n,:));
            cdata2 = squeeze(data2(m,n,:));
            t = table(between_var,cdata1,cdata2,...
            'VariableNames',{'group','meas1','meas2'});
            Meas = table([1 2]','VariableNames',{'Measurements'});
            rm2 = fitrm(t,'meas1-meas2~group','WithinDesign',Meas);
            [ranovatbl] = ranova(rm2);
                 anovatbl = anova(rm2);
                 %validated with SPSS 26, the effect for the within factor
                 %is slightly different, rest of the factors have the exact
                 %number

            within.F(m,n) = ranovatbl.F(2);
            within.p(m,n)= ranovatbl.pValueGG(2);
            within.df{m,n} = ranovatbl.DF(2:3);
            between.F(m,n) = anovatbl.F(2);
            between.p(m,n) = anovatbl.pValue(2);
            between.df{m,n} = anovatbl.DF(2:3);
            
        end
    end
end