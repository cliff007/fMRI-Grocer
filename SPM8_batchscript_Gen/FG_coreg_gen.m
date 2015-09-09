function FG_coreg_gen
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

%         opts=FG_module_settings_of_questdlg;
% 
%         root_dir = FG_module_select_root;
% 
%         groups = FG_module_select_groups;    
% 
%         [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
% 
%         [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'^sr.*img$|^sr.*nii$');
% 
%         [h_mean,mean_fun_imgs_tem,mean_file_filter]=FG_module_select_mean_Img(groups,opts,'^mean.*img$|^mean.*nii$');
% 
%         [h_t1,t1_imgs_tem]=FG_module_select_T1_Img(groups,opts);

anyreturn=FG_modules_selection('','','','^r.*img$|^r.*nii$','r','g','fo','fi','me','t');
if anyreturn, return;end

for g=1:size(groups,1)
    write_name=FG_check_and_rename_existed_file(['coreg_'  deblank(groups(g,:))  '_job.m'])   ;
            
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
        % specify the name of reference img(t1)
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.ref = {''',deblank(t1_imgs(i,:)) , ',1''};'), '-append', 'delimiter', '', 'newline','pc');  

        % files writing
        
        if strcmp(h_mean,opts.mean.oper{1})
           dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.source = {''',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(mean_fun_imgs(1,:))], ',1''};'), '-append', 'delimiter', '', 'newline','pc');                
        elseif strcmp(h_mean,opts.mean.oper{2})            
           dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.source = {''',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(mean_fun_imgs{g}(1,:))], ',1''};'), '-append', 'delimiter', '', 'newline','pc');                
        elseif strcmp(h_mean,opts.mean.oper{3})              
            mean_fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:))],mean_file_filter);
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.source = {''',deblank(mean_fun_imgs(1,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
        end 
        
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.other = {'), '-append', 'delimiter', '', 'newline','pc'); 

        % files writing
        if strcmp(h_files,opts.files.oper{1})
            for j=1:size(fun_imgs,1)
                dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(fun_imgs(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end
        elseif strcmp(h_files,opts.files.oper{2})            
            for j=1:size(fun_imgs{g},1)
                dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)),filesep,deblank(fun_imgs{g}(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end  
        elseif strcmp(h_files,opts.files.oper{3})              
            fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:))],file_filter);
            for j=1:size(fun_imgs,1)
                dlmwrite(write_name,strcat('''', deblank(fun_imgs(j,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end            
        end 
        
        dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.eoptions.cost_fun = ''nmi'';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.eoptions.tol=[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.spatial.coreg.estimate.eoptions.fwhm=[7 7];'), '-append', 'delimiter', '', 'newline','pc'); 

    end

end

fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
