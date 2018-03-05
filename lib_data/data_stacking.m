%input 4dim, channel x datapoint x subject x condition
%output 3dim, channel x datapoint x nsubject*ncond

function data2 = data_stacking(data)

[~, ~, nsubject, ncond] = size(data);

data2 = [];

%stacking conditions together for pca
for i = 1:ncond
    data2(:,:,(i-1)*nsubject+1:i*nsubject) = data(:,:,:,i);
end
