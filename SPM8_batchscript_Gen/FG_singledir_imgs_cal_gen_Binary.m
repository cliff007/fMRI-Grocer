function FG_singledir_imgs_cal_gen_Binary
   
imgs =  spm_select(inf,'any','Select all the imgs you want to binary into 1 & 0 (1 for all voxels>0) ', [],pwd,'.*img$|.*nii$');
     if isempty(imgs), return; end
     
prompt = {'Specify the binarization expression(e.g. i1>0, i1<1, 0<i1<1)'};
dlg_title = 'Apply for each input img...';
num_lines = 1;
def = {'i1>=1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
expression=deblank(answer{1})   ;
pause(0.5)

    % build the batch header
    dlmwrite('singledir_img_binary_job.m','%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite('singledir_img_binary_job.m', '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite('singledir_img_binary_job.m','%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 


    for i=1:size(imgs,1)
        [Path, fileN, extn]=fileparts(imgs(i,:));
        
        
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.input = {''', deblank(imgs(i,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.output = ''', ['Binary_' fileN extn],''';'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  
         
                                                                                 %% change the expression below on your own   
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.expression = ''',expression,''';'), '-append', 'delimiter', '', 'newline','pc'); 


        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_binary_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_binary_job.m','%%', '-append', 'delimiter', '', 'newline','pc');
    end
fprintf('\nAll set! Strat to run...\n\n')
spm_jobman('run','singledir_img_binary_job.m')

delete ('singledir_img_binary_job.m');