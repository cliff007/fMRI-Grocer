function FG_norm_est_and_write_mean_T1_gen
%   Important: Your directory and filename  structure must be the same 
%   for all other subjects. Here's an example of a valid fMRI
%   directory and file structure:
%   - fMRI study root path
%     - functional_group1_Data
%       - subj_1
%         - vol_001.nii    ------ three digits' image number
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
%         - vol_001.nii    ------ three digits' image number
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
%       - t1_subj_001.nii      ------ t1 imgs' order must be the same as the subject folders'.
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
% [h_mean,mean_fun_imgs_tem,mean_file_filter]=FG_module_select_mean_Img(groups,opts,'^mean.*img$|^mean.*nii$');
% 
% [h_t1,t1_imgs_tem]=FG_module_select_T1_Img(groups,opts);
       
anyreturn=FG_modules_selection('','','','','r','g','fo','me','t');
if anyreturn, return;end

    a=which('spm.m');
    [b,c,d,e]=fileparts(a);
    T1_template =  spm_select(1,'.nii','Select your T1 template', [],[b filesep 'templates'],'T1.*nii');

    

for g=1:size(groups,1)
    write_name=FG_check_and_rename_existed_file(['norm_est_write_T1_mean_'  deblank(groups(g,:))  '_job.m'])      

    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

   
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);
    
    % assigning the mean* img of groups
    mean_fun_imgs=FG_module_assign_mean_Img(mean_fun_imgs_tem,g,h_mean,opts);    
    
    % assigning the t1 of groups
    t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts);
    

    for i=1:size(dirs,1)
        
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.subj(',num2str(i),').source = {''', deblank(t1_imgs(i,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
        
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.subj(',num2str(i),').wtsrc='''';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.subj(',num2str(i),').resample= {'), '-append', 'delimiter', '', 'newline','pc');

            % files writing
            FG_module_write_mean(root_dir,groups,dirs,g,i,mean_fun_imgs,write_name,mean_file_filter,h_mean,opts);
                        
            dlmwrite(write_name,strcat('''',deblank(t1_imgs(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');         
            dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    end


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template= {''',deblank(T1_template(1,:)),',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight ='''''), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = ''mni'';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;'), '-append','delimiter', '', 'newline','pc');
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve= 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb =[-78 -112 -50; 78 76 85];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = ''w'';'), '-append', 'delimiter', '', 'newline','pc'); 
end

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)