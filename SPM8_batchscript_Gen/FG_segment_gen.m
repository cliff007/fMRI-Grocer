function FG_segment_gen
% root_dir = spm_select(1,'dir','Select the root folder of T1 imgs', [],pwd);
% if FG_check_ifempty_return(root_dir), return; end
% cd (root_dir)

% select T1 imgs
t1_imgs =  spm_select(inf,'any','Select all the T1 imgs ', [],pwd,'.*nii$|.*img$'); 
if FG_check_ifempty_return(t1_imgs) , return; end

    a=which('spm.m');
    [b,c,d,e]=fileparts(a);
    grey_template =  spm_select(1,'.nii','Select your grey matter template', [],[b filesep 'tpm'],'grey.nii');
    if FG_check_ifempty_return(grey_template), return; end 
    white_template =  spm_select(1,'.nii','Select your white matter template', [],[b filesep 'tpm'],'white.nii');
    if FG_check_ifempty_return(white_template) , return; end
    csf_template =  spm_select(1,'.nii','Select your CSF matter template', [],[b filesep 'tpm'],'csf.nii');
    if FG_check_ifempty_return(csf_template) , return; end
    
    write_name='T1_segment_job.m';
    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
        
        % specify the T1 imgs         
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.data = {'), '-append', 'delimiter', '', 'newline','pc');         
        % files writing
            for j=1:size(t1_imgs,1)
                dlmwrite(write_name,strcat('''', deblank(t1_imgs(j,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
            end        
            
        dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.output.biascor = 0;'), '-append', 'delimiter', '', 'newline','pc');         
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.output.cleanup = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
        
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.tpm = {'), '-append', 'delimiter', '', 'newline','pc');         
        dlmwrite(write_name,strcat('''', deblank(grey_template), ''''), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('''', deblank(white_template), ''''), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('''', deblank(csf_template), ''''), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc'); 
        
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('2'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('2'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('4];'), '-append', 'delimiter', '', 'newline','pc');  
        
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.regtype = ''mni'';'), '-append', 'delimiter', '', 'newline','pc');    
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;'), '-append', 'delimiter', '', 'newline','pc');    
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;'), '-append', 'delimiter', '', 'newline','pc');          
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.spatial.preproc.opts.msk = {''''};'), '-append', 'delimiter', '', 'newline','pc'); 

fprintf('\n------Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
