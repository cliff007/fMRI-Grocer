function FG_list_file_num
clc
dirs=spm_select(inf,'dir','Select all folders you want to list');
for i=1:size(dirs,1)
    Dir=deblank(dirs(i,:));
    files = spm_select('FPList',Dir,'.*');
    n=size(files,1);
%     if n~=1577
        fprintf('%s     %d\n',dirs(i,:),n)
%     end

end