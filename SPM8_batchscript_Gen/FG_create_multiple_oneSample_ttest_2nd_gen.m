
function FG_create_multiple_oneSample_ttest_2nd_gen
all_cond_groups = spm_select(inf,'dir','Select conditon result groups', [],pwd);
if isempty(all_cond_groups)
    return
end

em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
h_global=questdlg('Do you want to do the standard global calibration for CBF analysis?','Hi...','Yes','No','No');
pause(0.2)
for i=1:size(all_cond_groups,1)
    sub_dir=deblank(all_cond_groups(i,:));sub_dir=sub_dir(1,1:end-1);
    imgs=spm_select('FPList',sub_dir,'.*img|.*nii');
    [pth,name]=FG_sep_group_and_path(all_cond_groups(i,:));
    root_dir = fullfile(pth, ['ttest_' name filesep]);
    FG_oneSample_ttest_2nd_gen(imgs,em,h_global,root_dir)
end

fprintf('\n-----done...')