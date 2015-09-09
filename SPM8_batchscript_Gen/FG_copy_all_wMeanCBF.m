function FG_copy_all_wMeanCBF(root_dir,groups,dirs,prefix_c,destination)
% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');

if nargin~=5

    anyreturn=FG_modules_selection('','','','','r','g','fo');
    if anyreturn, return;end

        dlg_prompt={'Specify the prefix characters of the img/hdr you want to move'};
        dlg_name='prefix characters...';
        dlg_def={'wMean_CBF'};
        prefix_c=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
        prefix_c=prefix_c{1};
        destination = spm_select(1,'dir','Select the folder where all the (w)Mean_CBF imgs will be moved to', [],pwd);
        if isempty(destination) ,  return;  end     
end
 
	prefix_c=deblank(prefix_c);
%%%%%% start
    
        for g=1:size(groups,1) 
            
           if nargin~=5
               % assigning the subfolders of groups
                dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);
           end
           
           for j=1:size(dirs,1)   
               % test the file extention
                ext_test1 = spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(j,:)),filesep],['^' prefix_c '.*img$']);  
                ext_test2 = spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(j,:)),filesep],['^' prefix_c '.*nii$']); 

                 if ~isempty(ext_test1) % for hdr/img
                     if size(ext_test1,1)>1
                         fprintf('\n---Warning: more than one %s files under %s \n',['^' prefix_c '.*img$'],dirs(j,:))
                     end
                     hdrname = spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(j,:)),filesep],['^' prefix_c '.*hdr$']);  
                     imgname = spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(j,:)),filesep],['^' prefix_c '.*img$']); 
                     for k=1:size(imgname,1)
                         [pathes, names,new_names1,tem_hdrname]=FG_separate_files_into_name_and_path(deblank(hdrname(k,:)),[deblank(dirs(j,:)) '_' deblank(groups(g,:))  '_'],'prefix');
                         [pathes, names,new_names2,tem_imgname]=FG_separate_files_into_name_and_path(deblank(imgname(k,:)),[deblank(dirs(j,:)) '_' deblank(groups(g,:))  '_'],'prefix');
                         new_hdrname=fullfile(destination,new_names1);
                         new_imgname=fullfile(destination,new_names2);
                         copyfile (hdrname,new_hdrname);
                         copyfile (imgname,new_imgname); 
                     end
                 elseif ~isempty(ext_test2)  % for nii
                     if size(ext_test1,1)>1
                         fprintf('\n---Warning: more than one %s files under %s \n',['^' prefix_c '.*img$'],dirs(j,:))
                     end
                     niiname = spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(j,:)),filesep],['^' prefix_c '.*nii$']);
                     for k=1:size(niiname,1)
                         [pathes, names,new_names,tem_niiname]=FG_separate_files_into_name_and_path(deblank(niiname(k,:)),[deblank(dirs(j,:)) '_' deblank(groups(g,:))  '_'],'prefix');
                         new_niiname=fullfile(destination, new_names);
                         copyfile (niiname,new_niiname);
                     end
                 else
                     fprintf('\n---Warning: No filtered files under %s \n',dirs(j,:))
                 end
           end
        end

fprintf('\n--------(w)Mean_CBF images coping is done!\n')
