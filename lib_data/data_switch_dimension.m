%2014-07-01
%input data: chan x datapoint x cond x subj
%output data: chan x datapoint x subj x cond

function data2 = data_switch_dimension(data)

[chan,datapoint,cond,subj] = size(data);
data2 = zeros(chan,datapoint,subj,cond);

for i = 1:cond
    data2(:,:,:,i) = data(:,:,i,:);
end

end