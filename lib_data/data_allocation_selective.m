%need work
%only grab the factorxcluster combination that was selected
%a safer algorithm for allocation
%20130515, modified the input structure to cond x subj to fit most data

%input fomat: cluster x factor x  ncond x nsubject
%output format: nsubj x (factor1cluster1cond1 + factor1cluster1cond2 +
%...factor1cluster2cond1 + ...factor1cluster3cond1)
%inner to outter, condition, cluster, factor

function [result,result_header] = data_allocation_selective(data,)

[ncluster, usable_factor, ncond,nsubj] = size(data);


result = zeros(nsubj,ncluster*usable_factor*ncond);
result_header = cell(size(result,2),1);

current_cond = 1;
current_cluster = 1;
current_factor = 1;

for j = 1:size(result,2)        
    result(:,j) = squeeze(data(current_cluster, ...
        current_factor, current_cond,:));
    result_header{j,1} =['factor' int2str(current_factor),...
        'cluster' int2str(current_cluster) 'cond' int2str(current_cond)];

    %iterate to the corrent level
    current_cond = current_cond + 1;
    if current_cond > ncond
        current_cond = 1;
        current_cluster = current_cluster + 1;
        if current_cluster > ncluster;
            current_cluster = 1;
            current_factor = current_factor +1;
        end
    end
    
end

