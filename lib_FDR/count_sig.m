%count the total number of significant tests in a p list
%p is 2d

function count = count_sig(p)

count = 0;

for i=1:size(p,1)
    for j = 1:size(p,2)
        if p(i,j)>0 && p(i,j)<.05
            count = count + 1;
        end
    end
end
