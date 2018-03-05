%input report, from an FDR approach, with t_list
%find significant datapoint/timepoint and corresponding channels
%do pca on it to find the converging window

function [factorResults,factor_time,score] = pca_after_FDR(report)

data = report.FDR_h;
[n_chan, n_dp] = size(data);

m = 1;
for i=1:n_chan
    if ~isempty(find(data(i,:)==1))
        pca_data(m,:) = data(i,:);
        pca_chan(m) = report.channel_list(i);
        m = m+1;
    end
end

nFactor = 2;

factorResults = ep_doPCA('temp','VMAX',1,'COV',nFactor,pca_data,'K');
factor_time = analyze_rotatedmatrix_tpca(factorResults);

score(:,1) = pca_chan';

nFactor = size(factor_time,1);
score(:,2:nFactor+1) = factorResults.FacScr(:,1:nFactor);

%then manually exam factorResults.FacScr to pick the channels