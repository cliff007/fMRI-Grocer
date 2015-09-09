function [new_path,new_fullname]=FG_create_new_outputdir(old_fullname,new_group_subfix)
[pth,name]=FG_separate_files_into_name_and_path(deblank(old_fullname));
[pth1,group]=FG_sep_group_and_path(pth);
if strcmp(group,pth1(1,1:end-1))
    new_path=fullfile(pth1, new_group_subfix);
    new_fullname=fullfile(pth1, new_group_subfix,name);
else
    new_path=fullfile(pth1, [group '_' new_group_subfix]);
    new_fullname=fullfile(pth1, [group '_' new_group_subfix] ,name);
end