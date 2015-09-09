function FG_multiG_average_imgs_imgcal_gen

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

anyreturn=FG_modules_enhanced_selection('','','','^.*img$|^.*nii$','r','g','fo','fi');
if anyreturn, return;end


% % define the "mean" expression--------start  % this has substitude, just turn on the image matrix is much easier!
%     for i=1:size(fun_imgs,1)
%         if i==1
%             cal_expression=['('];
%         end
% 
%         cal_expression=[cal_expression 'i',num2str(i),'+'];
% 
%         if i==size(fun_imgs,1)
%             cal_expression=[cal_expression(1:end-1) ')/' num2str(size(fun_imgs,1))] ; 
%         end
% 
%     end
% % define the "mean" expression---------end


 for g=1:size(groups,1)   
     
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
    write_name=['mutilG_avg_imgcal_'  deblank(groups(g,:))  '_job.m'];    
     
         
    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 
    
    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);     

      for i=1:size(dirs,1)
          
        avg_name=fullfile(root_dir,deblank(groups(g,:)), ['avg_of_', deblank(groups(g,:)), '_', deblank(dirs(i,:)), '.img']);  
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc'); 
        
        % files writing
        FG_module_write_funImgs(root_dir,groups,dirs,g,i,fun_imgs,write_name,file_filter,h_files,opts);
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);
               
        dlmwrite(write_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc');    
                                                                                 %% change the output name below on your own  
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.output = ''', avg_name,''';'), '-append', 'delimiter', '', 'newline','pc');  
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');           
                                                                                 %% change the expression below on your own   
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.expression = ''',['sum(X)/' num2str(size(fun_imgs,1))],''';'), '-append', 'delimiter', '', 'newline','pc'); 

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dmtx = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
    
     end
 fprintf('\nAll set! Strat to run...\n\n')
 spm_jobman('run',write_name)
 delete(write_name);
end
fprintf('\n---------------All average-calculation are done!\n\n')

