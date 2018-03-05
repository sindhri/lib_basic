%20140721, added 1-3 dim support
%20170914, added 4 dim
%20170918, if no change, do not make a new variable, otherwise very slow
%for some reason
%20170926, removed subject_list
function [data, rating] = eliminate_zero_v2(data, rating)
if isempty(find(rating==0))
    return
end

non_empty_columns = rating~=0;
switch length(size(data))
    case 1
        data = data(non_empty_columns);
    case 2
        data = data(:,non_empty_columns);
    case 3
        data = data(:,:,non_empty_columns);
    case 4
        data = data(:,:,:,non_empty_columns);
    otherwise
        fprintf('not set up for dim over 4, abort\n');
        return
end
rating = rating(non_empty_columns);
