%2011-08-08
%data_4d is 4dim: chan x datapoint x subject x condition
%which means all the subjects in one condition comes first
%then all the subjects in the next condition come next

function [FactorResults_tpca, ...
    FactorResults_stpca] = stPCA_procedure_data_4d(data_4d, ...
    n_tpca, n_spca,condition_selected)

%step 1: from the 4th dimension, selected particular condition
if nargin==3
    condition_selected =1:size(data_4d,4);
end
data_4d = data_4d(:,:,:,condition_selected);

%step 2: stacking data, converting 4d data to 3d
data_3d = data_stacking(data_4d);

%step 3: remove baseline for preparing PCA. at the 2nd dimension
baseline = 25;
ndatapoint = size(data_4d,2);
data_blr = data_3d(:,baseline+1:ndatapoint,:);

%step4: temporal PCA
nFactor = n_tpca;
FactorResults_tpca = ep_doPCA('temp','PMAX',3,'COV',nFactor,data_blr,'K');

%step5: spatial PCA
nFactor = n_spca;
%FactorResults_stpca = ep_doPCAst(FactorResults_tpca,...
%    'IMAX',1,'COV',nFactor,'K');

FactorResults_stpca = ep_doPCAst(FactorResults_tpca,...
    'IMAX',1,'COV',nFactor,'K','spat');
