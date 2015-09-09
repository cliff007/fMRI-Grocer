
function FG_twoSample_ttest_2nd_gen
% specify the num of imgs in each subject's dir

imgs_pair_1 = spm_select(inf,'any','Select all the normalized_imgs of the first group', [],pwd,'.*img$|.*nii$');
if isempty(imgs_pair_1)
    return
end
imgs_pair_2 = spm_select(inf,'any','Select all the normalized_imgs of the second group', [],pwd,'.*img$|.*nii$');
if isempty(imgs_pair_2)
    return
end

em = spm_select(1,'any','Select an explicit mask (or you can just close the window if you don''t want this)', [],pwd,'.*img$|.*nii$');
h_global=questdlg('Do you want to do the standard global calibration for CBF analysis?','Hi...','Yes','No','No');

root_dir = FG_module_select_root('Select the directory where to store the estimated files(*.mat/con*.img)')   ;

if strcmp(h_global,'No')    
    write_name=strcat(root_dir,'level2_TwoSample_ttest_noglobal_job.m');
elseif strcmp(h_global,'Yes')  
    write_name=strcat(root_dir,'level2_TwoSample_ttest_global_job.m');
else    
    fprintf('\nYour slection of global calibration is wrong!\n\n') 
    return;
end

    
    
% build the batch header
dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.dir = {''',root_dir,'''};'), '-append', 'delimiter', '', 'newline','pc'); 


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1={'), '-append', 'delimiter', '', 'newline','pc'); 
    for i=1:size(imgs_pair_1,1)
        dlmwrite(write_name,strcat('''',deblank(imgs_pair_1(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
    end
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');  
    
    
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2={'), '-append', 'delimiter', '', 'newline','pc'); 
    for i=1:size(imgs_pair_2,1)
        dlmwrite(write_name,strcat('''',deblank(imgs_pair_2(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
    end
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');    
%     dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');  
    
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;'), '-append', 'delimiter', '', 'newline','pc');     
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.cov = struct(''c'', {}, ''cname'', {}, ''iCFI'', {}, ''iCC'', {});'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.masking.em = {''',em,'''};'), '-append', 'delimiter', '', 'newline','pc');
    
    if strcmp(h_global,'No') 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;'), '-append', 'delimiter', '', 'newline','pc');
    elseif strcmp(h_global,'Yes') 
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalc.g_mean = 1;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_yes.gmscv = 50;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 2;'), '-append', 'delimiter', '', 'newline','pc');        
    end
   
fprintf('\n-----Check the created job file(.m): %s \n\n',write_name)