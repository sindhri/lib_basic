%20171114, combine two data_ave, just add up the data and id
%remove the name, rename, 
function ave = combine_data_ave(ave1,ave2,new_name)
n1 = ave1.nsubject;
n2 = ave2.nsubject;
ave = ave1;
for i = n1+1:n1+n2
    ave.data(:,:,:,i) = ave2.data(:,:,:,i-n1);
    ave.id{i} = ave2.id{i-n1};
end
if isfield(ave,'group_name');
    ave = rmfield(ave,'group_name');
end
ave.name = new_name;