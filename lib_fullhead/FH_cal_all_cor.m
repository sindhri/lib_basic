%20190301
%input EEGAVE.data chan x time x subj x cond
%input behavorial table, subj x dimension
%output p and r, chan x time for each cond and each dimension
%so the output is a table? [chan x time] side of each cond x dimen grid
%20190402, added nsubj in the grid
function corrintable = FH_cal_all_cor(EEGAVE,behavioral)
    data = EEGAVE.data;
    eventtypes = EEGAVE.eventtypes;
    ncond = size(data,4);
    ndim = size(behavioral,2);
    corr_grid = {};
    alldim = behavioral.Properties.VariableNames;
    for i = 1:ncond
        corr_per_cond = {eventtypes{i}};
        for j = 2:ndim
            fprintf('\n\ni=%d out of %d, j=%d out of %d\n',i,ncond,j,ndim);
            fprintf('calculating %s with %s\n',eventtypes{i},alldim{j});
            cdata = data(:,:,:,i);
            cbehavioral = table2array(behavioral(:,j));
 
            %match IDs, remove nan
            [common_id,data_id_newindex,cbehavioral] = select_IDs(EEGAVE.ID,behavioral.ID,cbehavioral);
             cdata = data(:,:,data_id_newindex,i);
            
            %pm, rm, pm_sign are all chan x time matrics, cgrid, current
            %grid cell
            fprintf('processing......\n')
            [cgrid.pm,cgrid.rm,cgrid.pm_sign] = get_corrcoef(cdata,cbehavioral);
            cgrid.nsubj = length(cbehavioral);
            cgrid.name1 = eventtypes{i};
            cgrid.name2 = alldim{j};
            cgrid.nbchan = EEGAVE.nbchan;
            cgrid.pnts = EEGAVE.pnts;
            cgrid.srate = EEGAVE.srate;
            cgrid.xmin = EEGAVE.xmin;
            cgrid.xmax = EEGAVE.xmax;
            cgrid.times = EEGAVE.times;
            cgrid.chanlocs = EEGAVE.chanlocs;
            
          
            corr_per_cond{end+1} = cgrid;
        end
        corr_grid = [corr_grid;corr_per_cond];
    end
    
    rowHeadings={'eventtype',alldim{2:end}};
    corrinstruct = cell2struct(corr_grid,rowHeadings,2);
    corrintable = struct2table(corrinstruct);
end

%assume that all data_id has data
%for behavioral_id, we need to check to remove 'NA' in behavioral
%then merge with data_id to create common_id
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

function [pm, rm, pm_sign] = get_corrcoef(data,rating)
    [nchan,ntimes,~] = size(data);
    pm = zeros(nchan,ntimes);
    rm = zeros(nchan,ntimes);
    pm_sign = zeros(nchan,ntimes);
    for i = 1:size(data,1)
        for j = 1:size(data,2)
            [r,p] = corrcoef(data(i,j,:),rating);
            rm(i,j) = r(1,2);
            pm(i,j) = p(1,2);
            
            if rm(i,j) > 0
                pm_sign(i,j) = pm(i,j);
            else
                pm_sign(i,j) = -pm(i,j);
            end
        end
    end
end