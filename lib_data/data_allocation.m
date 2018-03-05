%input fomat: cluster x factor x nsubject x ncond
%output format: nsubj x factor1cluster1cond1 + factor1cluster1cond2 +
%...factor2cluster1factor1

function [result,result_header] = data_allocation(data)

[ncluster, usable_factor, nsubj,ncond] = size(data);

result = zeros(nsubj,ncluster*usable_factor*ncond);
result_header = cell(size(result,2),1);

for i = 1:nsubj
    current_subject = i;
    for j = 1:size(result,2)
        temp = ncluster*ncond;
        current_factor = floor(j/temp)+1;
        if mod(j,temp)== 0
            current_factor = current_factor-1;
        end
        temp = j-(current_factor-1)*ncluster*ncond;
        current_cluster = floor(temp/ncond)+1;
        if mod(temp,ncond)==0
            current_cluster = current_cluster -1;
        end
        current_cond = j-(current_factor-1)*ncluster*ncond - (current_cluster-1)*ncond;
        result(i,j) = data(current_cluster, current_factor, current_subject,current_cond);
        result_header{j,1} =['factor' int2str(current_factor),...
            'cluster' int2str(current_cluster) 'cond' int2str(current_cond)];
    end
end
