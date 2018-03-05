function d = ERP_merge_data(ALLEEG)

times = ALLEEG(1).times;
nsubj = length(ALLEEG);
group_name = ALLEEG(1).group_name;
category_names = ALLEEG(1).category_names;
[nchan,ndpt,ncond] = size(ALLEEG(1).data);

data = zeros(nchan,ndpt,ncond,nsubj);
id=cell(1);
for i = 1:length(ALLEEG)
    data(:,:,:,i) = ALLEEG(i).data;
    id{i} = ALLEEG(i).id;
end

d.data = data;
d.group_name = group_name;
d.times = times;
d.id = id;
d.category_names = category_names;


end