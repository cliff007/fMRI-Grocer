function FG_singledir_imgs_cal_avgIntoSeparateLength_gen_run
root_dir = pwd;
imgs =  spm_select(inf,'any','Select all the imgs you want to dealwith', [],pwd,'.*img$|.*nii$');
if FG_check_ifempty_return(imgs), return; end

       
TimgP=inputdlg({'How many timepoints do you want to separate'},'Timepoints setting',1,{'4'});
h_avg=questdlg(['Same image-length for these ' TimgP ' time points?'],'Hi....','Yes','No','Yes') ;
if strcmp(h_avg,'Yes')
    gaps= size(imgs,1)/str2num(TimgP{1});
    legth_i= floor(gaps);
    if legth_i~=gaps
        msgbox(['Your selected ' num2str(size(imgs,1)) ' imgs can not be divided into groups with ' TimgP{1} ' imgs each. Please go back to select imgs again!'],'Warning','error')
        return
    end
    img_i=1;
    for i = 1:str2num(TimgP{1})
        img_series{i}=[img_i:img_i+gaps-1];
        img_i=img_i+gaps;
    end
    
else
    img_series = FG_inputdlg_selfdefined(str2num(TimgP{1}),'Enter the image-number series for timepoint ');  
    for i=1:str2num(TimgP{1})
        tem{i}=eval(['[ ' img_series{i,:} ']']);
    end
    img_series=tem;
    clear tem
end




 pause(0.5) 
    % build the batch header
    dlmwrite('singledir_avgIntoSeparateLength_job.m','%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite('singledir_avgIntoSeparateLength_job.m', '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite('singledir_avgIntoSeparateLength_job.m','%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

    img_i=1;
    for i=1:str2num(TimgP{1})
        [Path, fileN, extn]=fileparts(imgs(img_series{i}(1),:));        
        
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc');  
        step=size(img_series{i},2);
        for j=img_series{i}
            dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('''',deblank(imgs(j,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
        end
        
        dlmwrite('singledir_avgIntoSeparateLength_job.m','};', '-append', 'delimiter', '', 'newline','pc');  

        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.output = ''', ['avg_' num2str(i) '_of_' num2str(step) '_from_' fileN extn],''';'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.outdir = {''',root_dir,'''};'), '-append', 'delimiter', '', 'newline','pc');  
         
                                                                                 %% change the expression below on your own   
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.expression = ''sum(X)/size(X,1)'';'), '-append', 'delimiter', '', 'newline','pc'); 
        % if you just have one image in one group, spm_imcalc_ui may be wrong for dealing with sum(X)/size(X,1)

        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dmtx = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_avgIntoSeparateLength_job.m',strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite('singledir_avgIntoSeparateLength_job.m','%%', '-append', 'delimiter', '', 'newline','pc');
        img_i=img_i+step;
    end
fprintf('\nAll set! Strat to run...\n\n')
spm_jobman('run','singledir_avgIntoSeparateLength_job.m')   % if you just have one image in one group, spm_imcalc_ui may be wrong for dealing with sum(X)/size(X,1)
fprintf('\n----Done! Output is in the current directory!\n\n')

delete('singledir_avgIntoSeparateLength_job.m');