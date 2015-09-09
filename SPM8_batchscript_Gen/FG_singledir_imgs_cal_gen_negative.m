function FG_singledir_imgs_cal_gen_negative

imgs =  spm_select(inf,'any','Select all the imgs you want to mutiply by (-1)', [],pwd,'.*img$|.*nii$');
 
if isempty(imgs), return; end

    prompt = {'Give a expression (e.g. i1*-1, i1*100, i1-100)...'};
    dlg_title = 'Apply expression for each selected image...';
    num_lines = 1;
    def = {'i1*-1'};
    expr = inputdlg(prompt,dlg_title,num_lines,def);
    expr=deblank(expr{1});
    
    tem=expr(3);
    switch tem
        case '*'
            tem='_x';
        case '/'
            tem='_div';
        case '+'
            tem='_plus';
        case '-'
            tem='_subst';
    end
    
    name_sub=[tem expr(4:end)];
           
    
    % build the batch header
    dlmwrite('singledir_img_neg_job.m','%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite('singledir_img_neg_job.m', '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite('singledir_img_neg_job.m','%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 


    for i=1:size(imgs,1)
        [Path, fileN, extn]=fileparts(imgs(i,:));
        
        
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.input = {''', deblank(imgs(i,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.output = ''', [fileN name_sub extn],''';'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  
         
                                                                                 %% change the expression below on your own   
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.expression = ''',expr,''';'), '-append', 'delimiter', '', 'newline','pc'); 


        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_neg_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_img_neg_job.m','%%', '-append', 'delimiter', '', 'newline','pc');
    end
fprintf('\nAll set! Strat to run...\n\n')
spm_jobman('run','singledir_img_neg_job.m')


delete ('singledir_img_neg_job.m');