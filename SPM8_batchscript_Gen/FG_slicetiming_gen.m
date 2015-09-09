function FG_slicetiming_gen
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
% [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'.*img$|.*nii$');
% 
% [h_SLTiming,Ans]=FG_module_select_slicetiming_paras(groups,opts);

anyreturn=FG_modules_selection('','','','^r.*img$|^r.*nii$','r','g','fo','fi','s');
if anyreturn, return;end

for g=1:size(groups,1)
    write_name=FG_check_and_rename_existed_file(['slicetiming_'  deblank(groups(g,:)) '_job.m']);
           
    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);
    
    
    for i=1:size(dirs,1)
        % specify the name of reference img(t1)
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.scans  = {'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,'{', '-append', 'delimiter', '', 'newline','pc');
        
        % files writing
        FG_module_write_funImgs(root_dir,groups,dirs,g,i,fun_imgs,write_name,file_filter,h_files,opts);
                
        dlmwrite(write_name,'}', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'}'';', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        
        if strcmp(h_SLTiming,opts.ST.oper{1})
            nslice=cell2mat(Ans{1}(1));
            tr=cell2mat(Ans{1}(2));
            ta=num2str(eval(cell2mat(Ans{1}(3))));
            sliceorder=num2str(eval(cell2mat(Ans{1}(4))));
            refslice=cell2mat(Ans{1}(5));              
        elseif strcmp(h_SLTiming,opts.ST.oper{2})
            nslice=cell2mat(Ans{g}(1));
            tr=cell2mat(Ans{g}(2));
            ta=num2str(eval(cell2mat(Ans{g}(3))));
            sliceorder=num2str(eval(cell2mat(Ans{g}(4))));
            refslice=cell2mat(Ans{g}(5)); 
        end  
        
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.nslices = ',nslice,';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.tr =  ',tr,';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.ta =  ',ta,';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.so = [ ',sliceorder,'];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.refslice =  ',refslice,';'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.temporal.st.prefix = ''a'';'), '-append', 'delimiter', '', 'newline','pc'); 

    end

end
fprintf('\n-----Check the created job file(.m):  %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
