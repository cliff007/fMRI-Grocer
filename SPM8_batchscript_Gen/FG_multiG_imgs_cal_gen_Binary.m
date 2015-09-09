function FG_multiG_imgs_cal_gen_Binary

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

prompt = {'Specify the binarization expression(e.g. i1>0, i1<1, 0<i1<1)'};
dlg_title = 'Apply for each input img...';
num_lines = 1;
def = {'i1>=1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
expression=deblank(answer{1})   ;
pause(0.5)

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
%     k=0;
    
      for i=1:size(dirs,1)

        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);
        if isempty(fun_imgs), continue; end
        fprintf('\nRunning...\n\n')
        

               
            for j=1:size(fun_imgs,1)
              %% new soulution
                [Path, fileN, extn]=fileparts(fun_imgs(j,:));
                [V,mat]=FG_read_vols(fun_imgs(j,:)) ;
                V=FG_make_sure_NaN_to_zero_img(V);  
                
                expression=regexprep(expression,'i1','V');
                V(~eval(expression))=0;
                V(eval(expression))=1;
                
                new_fname=FG_simple_rename_untouch(mat.fname,['Binary_' fileN extn]);
                FG_write_vol(mat,V,new_fname);
                
                
                
%                 k=k+1;
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.input = {''', deblank(fun_imgs(j,:)), ',1''};'), '-append', 'delimiter', '', 'newline','pc');  
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.output = ''', ['Binary_' fileN extn],''';'), '-append', 'delimiter', '', 'newline','pc');  
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.outdir = {''', Path, '''};'), '-append', 'delimiter', '', 'newline','pc');  
% 
%                                                                                          %% change the expression below on your own   
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.expression = ''',expression,''';'), '-append', 'delimiter', '', 'newline','pc'); 
% 
% 
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
%                 dlmwrite(write_name,strcat('matlabbatch{', num2str(k), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
%                 dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
                
            end
    
     end
%  fprintf('\nAll set! Strat to run...\n\n')
%  spm_jobman('run',write_name)
%  delete(write_name);
 end

 
fprintf('\nAll set...\n\n')

