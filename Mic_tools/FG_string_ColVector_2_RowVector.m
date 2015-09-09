function row_vect=FG_string_ColVector_2_RowVector(col_vect)
if ~ischar(col_vect), return, end

row_vect=[];
for i=1:size(col_vect,1)
    row_vect=[row_vect, [' ' deblank(col_vect(i,:))]];
end