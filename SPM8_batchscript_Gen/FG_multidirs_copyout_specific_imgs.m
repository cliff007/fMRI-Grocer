function FG_multidirs_copyout_specific_imgs

anyreturn=FG_modules_enhanced_selection('','','','^.*img$|^.*nii$','r','g','fo','fi');
if anyreturn, return;end

TimgP=inputdlg({'How many timepoint groups do you want to separate?'},'Timepoint group setting',1,{'3'});
TimgP=str2num(TimgP{1});
img_series = FG_inputdlg_selfdefined(TimgP,'Please enter the image-number series for group ','Image series...');  
series_names = FG_inputdlg_selfdefined(TimgP,'Please enter the name of the group ','Group names...','Group');  
    
  pause(0.5)
  for g=1:size(groups,1)   
      
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);             
    
    for i_dir=1:size(dirs,1)
       fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i_dir,all_fun_imgs,file_filter,h_files,opts);        
       FG_singledir_copyout_specific_imgs(fun_imgs,TimgP,img_series,series_names);
    end

  end
 fprintf('\n-----Done!-----\n\n')
