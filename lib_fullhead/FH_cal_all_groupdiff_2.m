%EEGAVE, difference between every condition contrast
%20190402, added nsubj in the grid
%20191017, data structures change to nchan xdatapoint x ncond x nsubj

function groupdiffintable = FH_cal_all_groupdiff_2(EEGAVE1,EEGAVE2)
eventtypes = EEGAVE1.eventtypes;
[~,~,ncond1,nsubj1] = size(EEGAVE1.data);
[~,~,ncond2,nsubj2] = size(EEGAVE2.data);
if ncond1 ~=ncond2
    fprintf('n of conditions inconsistent\n');
    return;
end
diff_grid = {};
    for i = 1:ncond1
        diff_per_row = {eventtypes{i}};
            cgrid = [];
                fprintf('\n\ni=%d out of %d, %s\n',i,ncond1, eventtypes{i});
                data1 = squeeze(EEGAVE1.data(:,:,i,:));
                data2 = squeeze(EEGAVE2.data(:,:,i,:));
                fprintf('processing......\n');
                [cgrid.pm,cgrid.tm,cgrid.pm_sign] = get_groupdiff(data1,data2); 
                cgrid.nsubj = nsubj1+nsubj2;
                cgrid.name1 = [EEGAVE1.group_name '_' eventtypes{i}];
                cgrid.name2 = [EEGAVE2.group_name '_' eventtypes{i}];
                cgrid.nbchan = EEGAVE1.nbchan;
                cgrid.pnts = EEGAVE1.pnts;
                cgrid.srate = EEGAVE1.srate;
                cgrid.xmin = EEGAVE1.xmin;
                cgrid.xmax = EEGAVE1.xmax;
                cgrid.times = EEGAVE1.times;
                cgrid.chanlocs = EEGAVE1.chanlocs;
            diff_per_row{end+1} = cgrid;
        diff_grid = [diff_grid;diff_per_row];
    end
    rowHeadings={'eventtype',[EEGAVE1.group_name '_' EEGAVE2.group_name]};
    diffinstruct = cell2struct(diff_grid,rowHeadings,2);
    groupdiffintable = struct2table(diffinstruct);
end

function [pm,tm,pm_sign] = get_groupdiff(data1,data2)
    
    [nchan,ndpt,~] = size(data1);
    tm = zeros(nchan,ndpt);
    pm = zeros(nchan,ndpt);
    pm_sign = zeros(nchan,ndpt);
    for m = 1:nchan
        for n = 1:ndpt
            cdata1 = squeeze(data1(m,n,:));
            cdata2 = squeeze(data2(m,n,:));
            [H,P,~, STATS] = ttest2(cdata1,cdata2);
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