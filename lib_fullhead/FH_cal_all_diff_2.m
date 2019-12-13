%EEGAVE, difference between every condition contrast
%20190402, added nsubj in the grid
%20191017, data structures change to nchan xdatapoint x ncond x nsubj

function diffintable = FH_cal_all_diff_2(EEGAVE)
eventtypes = EEGAVE.eventtypes;
[~,~,ncond,~] = size(EEGAVE.data);
diff_grid = {};
    for i = 1:ncond
        diff_per_row = {eventtypes{i}};
        for j = 1:ncond
            cgrid = [];
            if i~=j               
                fprintf('\n\ni=%d out of %d, j=%d out of %d\n',i,ncond,j,ncond);
                fprintf('calculating difference of %s and %s\n',eventtypes{i},eventtypes{j});
                data1 = squeeze(EEGAVE.data(:,:,i,:));
                data2 = squeeze(EEGAVE.data(:,:,j,:));
                fprintf('processing......\n');
                [cgrid.pm,cgrid.tm,cgrid.pm_sign] = get_conddiff(data1,data2); 
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
            end
            diff_per_row{end+1} = cgrid;
        end
        diff_grid = [diff_grid;diff_per_row];
    end
    rowHeadings={'eventtype',eventtypes{:}};
    diffinstruct = cell2struct(diff_grid,rowHeadings,2);
    diffintable = struct2table(diffinstruct);
end

function [pm,tm,pm_sign] = get_conddiff(data1,data2)
    
    [nchan,ndpt,~] = size(data1);
    tm = zeros(nchan,ndpt);
    pm = zeros(nchan,ndpt);
    pm_sign = zeros(nchan,ndpt);
    for m = 1:nchan
        for n = 1:ndpt
            cdata1 = squeeze(data1(m,n,:));
            cdata2 = squeeze(data2(m,n,:));
            [H,P,~, STATS] = ttest(cdata1,cdata2);
            tm(m,n) = STATS.tstat;
            pm(m,n) = P;
            if STATS.tstat > 0
               pm_sign(m,n) = P;
            else
               pm_sign(m,n) = -P;
            end
        end
    end
end