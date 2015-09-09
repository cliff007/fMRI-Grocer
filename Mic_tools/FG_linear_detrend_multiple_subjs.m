function FG_linear_detrend_multiple_subjs

    anyreturn=FG_modules_enhanced_selection('','','','^.*img$|^.*nii$','r','g','fo','fi');
    if anyreturn, return;end
   
for g=1:size(groups,1)
    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
    
    for i=1:size(dirs,1)   
        
        % files reading     
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);       
        FG_linear_detrend_selected_imgs(fun_imgs)

    end
end

fprintf ('\n.................. All the linear detrend are done!......\n')

