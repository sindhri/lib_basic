%20140721, added 1-3 dim support
%20170914, added 4 dim
%20170918, if no change, do not make a new variable, otherwise very slow
%for some reason
function [data, rating, subject_list] = eliminate_zero(data, rating, subject_list)
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
if nargin==3
    subject_list = subject_list(non_empty_columns);
end

