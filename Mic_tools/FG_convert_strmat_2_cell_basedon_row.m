function cell_mat=FG_convert_strmat_2_cell_basedon_row(str_mat)
% take advantage of mat2cell(X,m,n) to do this job
cell_mat=mat2cell(str_mat,ones(1,size(str_mat,1)),size(str_mat,2));