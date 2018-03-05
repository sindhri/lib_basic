%read single mat file one by one, build database chan x datapoint x cond x
%subject

function data = read_all_mat_files(categories)

[~,pathname] = uigetfile('.mat',pwd);
file_list = dir(pathname);

m = 0;
data = [];
nc = length(categories);

for i = 1:length(file_list)
    temp = file_list(i).name;
    if strcmp(temp(1),'.')==1
        continue;
    end
    [~,~,file_ext] = fileparts(temp);
    if strcmp(file_ext,'.mat')==1
        fprintf('loading %s\n',temp);
        load([pathname temp]);
        m = m + 1;
        for j = 1:nc
            data(:,:,j,m) = eval(categories{j});
        end
    end
end
end