function FG_singledir_average_imgs_imgcal_gen
   
imgs =  spm_select(inf,'any','Select all the imgs you want to use to generate a mean_img', [],pwd,'.*img$|.*nii$');
    if isempty(imgs), return;   end

% name the output as the first several characters of the first img you selected
a=deblank(imgs(1,:));
[b,c,d,e]=fileparts(a);
if size(c,2)>13
    avg_name=['avg_of_' c(:,1:13) '_' num2str(size(imgs,1)) d];
else
    avg_name=['avg_of_' c '_' num2str(size(imgs,1)) d];
end
    
    % build the batch header
    dlmwrite('avg_imgs_job.m','%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite('avg_imgs_job.m', '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite('avg_imgs_job.m','%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

               
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc'); 
        
        for i=1:size(imgs,1)
            dlmwrite('avg_imgs_job.m',strcat('''', deblank(imgs(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
        end
        
        dlmwrite('avg_imgs_job.m',strcat('};'), '-append', 'delimiter', '', 'newline','pc');    
                                                                                 %% change the output name below on your own  
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.output = ''', avg_name,''';'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  
         
                                                                                 %% change the expression below on your own   
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.expression = ''sum(X)/',num2str(size(imgs,1)),''';'), '-append', 'delimiter', '', 'newline','pc'); 


        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('avg_imgs_job.m',strcat('matlabbatch{1}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('avg_imgs_job.m','%%', '-append', 'delimiter', '', 'newline','pc');

fprintf('\nAll set! Strat to run...\n\n')
spm_jobman('run','avg_imgs_job.m')

delete('avg_imgs_job.m');