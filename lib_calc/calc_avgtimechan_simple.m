%20191211, input data: nchan x ndpt x ncond x nsubj
%input only one poi
%poi.cluster is the channel cluster
%poi.time is the time period of interest
%input times, time index for the data

%output is the averaged amplitude at the poi: ncond x nsubj

function data_avgtimechan = calc_avgtimechan_simple(data,times,poi)

[~,~,ncond,nsubject] = size(data);

toi = poi.time;
choi = poi.cluster;
[toi_index,~] = adjust_toi(toi,times);
data_avgtime = mean(data(:,toi_index(1):toi_index(2),:,:),2);
data_avgtimechan = mean(data_avgtime(choi,:,:,:),1);

data_avgtimechan = reshape(data_avgtimechan,[ncond,nsubject]);

end

function [toi_index,toi_adjusted] = adjust_toi(toi,times)

    [toi_index,toi_adjusted,adjusted_boolean] = adjust_range(toi,times);

    if adjusted_boolean == 1
        fprintf('time of interest %d ms to %d ms adjusted to %d ms to %d ms:\n',...
            toi(1),toi(2),toi_adjusted(1),toi_adjusted(2));
    end
    
end


%internal function for adjust_poi
function [range_of_interest_index, ...
    range_of_interest_adjusted,adjusted]= adjust_range(range_of_interest,list)

range_of_interest_index = zeros(size(range_of_interest));

range_of_interest_adjusted = range_of_interest;

adjusted = 0;
for i = 1:size(range_of_interest,1) %rows
    for j = 1:size(range_of_interest,2) %columns
        target = range_of_interest(i,j);
        [index,target_adjusted] = find_index(target,list);
        range_of_interest_index(i,j)= index;
        range_of_interest_adjusted(i,j) = target_adjusted;
        if target ~= target_adjusted
            adjusted = 1;
        end
    end
end
end

%internal function for adjust_range
function [index, target_adjusted] = find_index(target, list)
index = 0;
for i = 1:length(list)-1
    diff = list(i)-target;
    if abs(list(i+1) - target) > abs(diff)
        index = i;
        target_adjusted = list(i);
        break;
    end
end
if index==0
    index = length(list);
    target_adjusted = list(length(list));
end
end