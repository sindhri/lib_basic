%20171004, outlier removal, 3 times std away
function [measure1,measure2,id1,id2] = remove_outlier(measure1,measure2,id1,id2)

excluded1 = find_outlier(measure1);
excluded2 = find_outlier(measure2);
excluded = [excluded1,excluded2];
measure1(excluded) = [];
measure2(excluded) = [];
id1(excluded) = [];
id2(excluded) = [];

end

function excluded_index = find_outlier(one_measure)
m = mean(one_measure);
s = std(one_measure);
lower_bound = m - 3*s;
upper_bound = m + 3*s;
excluded_index1 = find(one_measure<lower_bound);
excluded_index2 = find(one_measure>upper_bound);
excluded_index = [excluded_index1,excluded_index2];

if ~isempty(excluded_index)
    fprintf('outlier found.\n');
    for i = 1:length(excluded_index)
        fprintf('%.2f\t',one_measure(excluded_index(i)));
    end
end

end