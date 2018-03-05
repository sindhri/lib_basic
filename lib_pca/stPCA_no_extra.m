%2011-08-08
%data_4d is 4dim: chan x datapoint x subject x condition
%which means all the subjects in one condition comes first
%then all the subjects in the next condition come next

%2013-05-03, modified the input data to make it easier for more recent
%dataset
%data_4d is chan x datapoint x condition x subject

%20141211, modified to fit wholehead spatial temporal pca for specific
%frequency ERSP or ITC
%input data has 4dimension chan x time x cond x subj. baseline already
%removed, conditions already selected

function [FactorResults_tpca, ...
    FactorResults_stpca] = stPCA_no_extra(data, ...
    n_tpca, n_spca)


%step 2: stacking data, converting 4d data to 3d
data = data_stacking(data);

%step4: temporal PCA
nFactor = n_tpca;
FactorResults_tpca = ep_doPCA('temp','PMAX',3,'COV',nFactor,data,'K');

%step5: spatial PCA
nFactor = n_spca;
FactorResults_stpca = ep_doPCAst(FactorResults_tpca,...
    'IMAX',1,'COV',nFactor,'K','spat');

%then wait to decide the number of factors and maybe need to run again
end

function data2 = data_stacking(data)
[~,~,nsubject,ncond] = size(data);
data2 = [];
for i=1:ncond
    data2(:,:,(i-1)*nsubject+1:i*nsubject) = data(:,:,:,i);
end

end