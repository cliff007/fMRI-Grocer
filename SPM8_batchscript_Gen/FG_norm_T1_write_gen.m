function FG_norm_T1_write_gen
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

t1_imgs =  spm_select(inf,'any','Select all the T1 imgs', [],pwd,'.*img$|.*nii$');
if FG_check_ifempty_return(t1_imgs), return; end
 
t1_imgs_sn =  spm_select(inf,'.mat','Select all the T1 imgs'' *_sn mat files', [],pwd,'seg_sn.*mat');
if FG_check_ifempty_return(t1_imgs_sn), return; end

write_name=FG_check_and_rename_existed_file('norm_write_T1_job.m')   ;


    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 


    for i=1:size(t1_imgs,1)

            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.subj(',num2str(i),').matname = {''', deblank(t1_imgs_sn(i,:)), '''};'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.subj(',num2str(i),').resample= {'), '-append', 'delimiter', '', 'newline','pc');
            
            dlmwrite(write_name,strcat('''',deblank(t1_imgs(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
            
            dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
    end


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve= 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.bb =[-78 -112 -50; 78 76 85];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = ''w'';'), '-append', 'delimiter', '', 'newline','pc'); 

    fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
  