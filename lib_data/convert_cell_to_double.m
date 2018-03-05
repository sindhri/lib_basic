function new_list = convert_cell_to_double(list)

new_list = zeros(length(list),1);

for i = 1:length(list)
    new_list(i) = str2double(list{i});
end