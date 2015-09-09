function FG_run_all_m_files(Ms)
% Ms shoud be a column name list or just a file name
clc
if nargin==0
    Ms=spm_select(inf,'.m','Select all the .m files...');
    if isempty(Ms), return,end
end

[pth,name]=FG_separate_files_into_name_and_path(Ms);

fprintf('\n---Running...\n')
for i=1:size(Ms,1)
    if nargin==0
        cd (deblank(pth(i,:)));
    end
    tem=deblank(name(i,:));
    tem=tem(1:end-2);% remove ".m"
    try
        eval([tem ';']); 
    catch me
        me.message
        continue 
%         rethrow(lasterror)                       
    end
end
fprintf('\n---Done!\n')    
