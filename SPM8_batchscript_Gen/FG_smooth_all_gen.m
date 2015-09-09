function FG_smooth_all_gen
%   Important: Your directory and filename  structure must be the same 
%   for all other subjects. Here's an example of a valid fMRI
%   directory and file structure:
%   - fMRI study root path
%     - functional_group1_Data
%       - subj_1                
%         - vol_001.nii    
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - subj_1
%         - vol_001.nii    
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - ... 
%     - anatomy_data
%       - t1_subj_001.nii      
%       - t1_subj_002.nii
%       - ...
%
% go to the working dir that is used to store the spm_job batch codes

% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
% 
% [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'^r.*img$|^r.*nii$');

anyreturn=FG_modules_selection('','','','^r.*img$|^r.*nii$','r','g','fo','fi');
if anyreturn, return;end
    
    dlg_prompt={'What is the kernel size you want to specify (spm_default:[8 8 8]) :'};
    dlg_name='smooth kernel size';
    dlg_def={'8 8 8'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
    

for g=1:size(groups,1)
        write_name=FG_check_and_rename_existed_file(['smooth_'  deblank(groups(g,:))  '_job.m'])

        % build the batch header
        dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.smooth.data = {'), '-append', 'delimiter', '', 'newline','pc');  

        % assigning the subfolders of groups
        dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);   
         
        
    for i=1:size(dirs,1)
        % files writing
        FG_module_write_funImgs(root_dir,groups,dirs,g,i,fun_imgs,write_name,file_filter,h_files,opts);
        
    end
   

    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.smooth.fwhm = [',Ans{1},'];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.smooth.dtype = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.smooth.im = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.smooth.prefix = ''s'';'), '-append', 'delimiter', '', 'newline','pc'); 
end

fprintf('\n-----Check the created job file(.m):  %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
