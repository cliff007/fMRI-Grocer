function str_mat=FG_convert_cellVector_2_strVector_basedon_row(cell_str_mat)
str_mat=[];
for i=1:length(cell_str_mat)
    str_mat=strvcat(str_mat,cell_str_mat{i});
end