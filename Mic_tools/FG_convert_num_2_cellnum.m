function cell_num_mat=FG_convert_num_2_cellnum(num_mat)
for i=1:size(num_mat,1)
    for j=1:size(num_mat,2)
        cell_num_mat(i,j)={num_mat(i,j)};
    end
end