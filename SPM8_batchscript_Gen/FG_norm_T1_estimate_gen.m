function FG_norm_T1_estimate_gen
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

write_name=FG_check_and_rename_existed_file('norm_estimate_T1_job.m') ;

    a=which('spm.m');
    [b,c,d,e]=fileparts(a);
    T1_template =  spm_select(1,'.nii','Select your T1 template', [],[b filesep 'templates'],'T1.*nii');

    % build the batch header
dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 


    for i=1:size(t1_imgs,1)
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.subj(',num2str(i),').source = {''', deblank(t1_imgs(i,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.subj(',num2str(i),').wtsrc='''';'), '-append', 'delimiter', '', 'newline','pc'); 
    end


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.template= {''',deblank(T1_template(1,:)),',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.weight ='''''), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.smosrc = 8;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.smoref = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.regtype = ''mni'';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.cutoff = 25;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.nits = 16;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = 1;'), '-append', 'delimiter', '', 'newline','pc'); 

    fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
