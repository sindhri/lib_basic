function table1 = str2double_col(table1,column_name)

    data = table1.(column_name);
    data_new = zeros(size(data));
    for i = 1:length(data)
        cdata = data{i};
        data_new(i) = str2double(cdata);
    end
    table1.(column_name) = data_new;
end