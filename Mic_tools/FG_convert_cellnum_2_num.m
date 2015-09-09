function num_mat=FG_convert_cellnum_2_num(cellnum_mat)
for i=1:size(cellnum_mat,1)
    for j=1:size(cellnum_mat,2)
        if ischar(cellnum_mat{i,j})
            num_mat(i,j)=str2num(cellnum_mat{i,j});
        elseif isnumeric(cellnum_mat{i,j})
            num_mat(i,j)=cellnum_mat{i,j};
        end
    end
end