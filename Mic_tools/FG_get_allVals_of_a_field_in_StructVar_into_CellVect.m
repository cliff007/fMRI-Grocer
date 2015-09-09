function FieldVal_cell=FG_get_allVals_of_a_field_in_StructVar_into_CellVect(StructVar,Fieldname)
if ~isstruct(StructVar)
    return
end

% % tem=StructVar(:);
% for i=1:size(StructVar,1)
%     for j=1:size(StructVar,2)
%         FieldVal_cell{i,j}=getfield(StructVar(i,j), Fieldname);
%     end
% end

 
%% much faster algorithm
if ~isfield(StructVar, Fieldname)
    return
else
    all_fieldnames=fieldnames(StructVar);
    field_pos=find(ismember(all_fieldnames,Fieldname));
end

tem=struct2cell(StructVar);
FieldVal_cell=squeeze( tem(field_pos,:,:));
FieldVal_cell=reshape(FieldVal_cell,size(StructVar,1),size(StructVar,2));
fprintf('')
