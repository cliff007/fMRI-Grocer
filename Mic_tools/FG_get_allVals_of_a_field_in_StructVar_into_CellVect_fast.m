function FieldVal_array=FG_get_allVals_of_a_field_in_StructVar_into_CellVect_fast(StructVar,Fieldname)
%% test�� something wrong。。。。。。。。
if ~isstruct(StructVar)
    return
end

%% much faster algorithm
if ~isfield(StructVar, Fieldname)
    return
end

 FieldVal_array=cat(1,eval(['StructVar.' Fieldname])); % something wrong。。。
 fprintf('')
