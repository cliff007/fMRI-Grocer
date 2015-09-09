function FG_multiG_regress_out_TagControl(order)

% go to the working dir that is used to store the spm_job batch codes 

% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
% 
% [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'.*img$|.*nii$');

anyreturn=FG_modules_enhanced_selection('','','','^.*img$|^.*nii$','r','g','fo','fi');
if anyreturn, return;end
if nargin==0
    order = questdlg('Select a kind of label-control order for your perfusion imgs','label-control order selection...','Tag->Control','Control->Tag','Tag->Control') ;
end
pause(0.5)

 for g=1:size(groups,1)   
     
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 

    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);     

      for i=1:size(dirs,1)

        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);
               
        FG_singledir_regress_out_TagControl(fun_imgs,order)
    
     end
end
fprintf('\nAll Set!...\n\n')
