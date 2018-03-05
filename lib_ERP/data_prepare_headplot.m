%input an ave structure that has data and times
%data structure is nchan x ntime x ncond x nsubj
%input toi
%output the data for 3d-headplot
function data = data_prepare_headplot(ave,toi)
    [toi_index, toi_adjusted] = find_valid_pos(toi.time,ave.times);
    fprintf('time adjusted from %d-%d ms to %d-%d ms\n',...
        toi.time(1),toi.time(2),toi_adjusted(1), toi_adjusted(2));
    data = ave.data;
    data = mean(data,4);
    data =squeeze(mean(data(:,toi_index(1):toi_index(2),:),2));

end

function [items_pos, items_adjusted] = find_valid_pos(items,list)
    n = length(list);
    items_pos = round( (items-list(1))/(list(n)-list(1)) * (n-1))+1;
    items_pos(find(items_pos<1))=1;
    items_pos(find(items_pos>n))=n;
    items_adjusted = list(items_pos);
end