function FG_multidirs_imgs_cal_avgIntoSeparateLength_gen_run
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
       
TimgP=inputdlg({'How many timepoints do you want to separate'},'Timepoints setting',1,{'4'});
h_avg=questdlg(['Same image-length for these ' TimgP ' time points?'],'Hi....','Yes','No','Yes') ;
if ~strcmp(h_avg,'Yes')
    img_series = FG_inputdlg_selfdefined(str2num(TimgP{1}),'Enter the image-number series for timepoint ');  
    for i=1:str2num(TimgP{1})
        tem{i}=eval(['[ ' img_series{i,:} ']']);
    end
    img_series=tem;
    clear tem
end
 
 pause(0.5)
  for g=1:size(groups,1)   
      
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);             
    
    for i_dir=1:size(dirs,1)
        write_name=['Multidirs_avgIntoSepLength_'  deblank(groups(g,:)) deblank(dirs(i_dir,:))  '_job.m'];
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i_dir,all_fun_imgs,file_filter,h_files,opts);        
       
        % build the batch header
        dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
        dlmwrite(write_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

        img_ii=1;
        for i=1:str2num(TimgP{1})

            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc');  

            % files writing
            if strcmp(h_files,opts.files.oper{1})
                
                if strcmp(h_avg,'Yes')
                    gaps= size(fun_imgs,1)/str2num(TimgP{1});
                    legth_i= floor(gaps);
                    if legth_i~=gaps
                        msgbox(['Your selected ' num2str(size(fun_imgs,1)) ' imgs can not be divided into groups with ' TimgP{1} ' imgs each. Please go back to select imgs again!'],'Warning','error')
                        return
                    end
                    img_i=1;
                    for ii = 1:str2num(TimgP{1})
                        img_series{ii}=[img_i:img_i+gaps-1];
                        img_i=img_i+gaps;
                    end
                end 
                
                for j=img_series{i}
                    dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i_dir,:)),filesep,deblank(fun_imgs(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end
            elseif strcmp(h_files,opts.files.oper{2})   
                
                if strcmp(h_avg,'Yes')
                    gaps= size(fun_imgs,1)/str2num(TimgP{1});
                    legth_i= floor(gaps);
                    if legth_i~=gaps
                        msgbox(['Your selected ' num2str(size(fun_imgs,1)) ' imgs can not be divided into groups with ' TimgP{1} ' imgs each. Please go back to select imgs again!'],'Warning','error')
                        return
                    end
                    img_i=1;
                    for ii = 1:str2num(TimgP{1})
                        img_series{ii}=[img_i:img_i+gaps-1];
                        img_i=img_i+gaps;
                    end
                end 
                
                for j=img_series{i}
                    dlmwrite(write_name,strcat('''', [root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i_dir,:)),filesep,deblank(fun_imgs{g}(j,:))], ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end  
            elseif strcmp(h_files,opts.files.oper{3})              
                fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i_dir,:))],file_filter);
                
                if strcmp(h_avg,'Yes')
                    gaps= size(fun_imgs,1)/str2num(TimgP{1});
                    legth_i= floor(gaps);
                    if legth_i~=gaps
                        msgbox(['Your selected ' num2str(size(fun_imgs,1)) ' imgs can not be divided into groups with ' TimgP{1} ' imgs each. Please go back to select imgs again!'],'Warning','error')
                        return
                    end
                    img_i=1;
                    for ii = 1:str2num(TimgP{1})
                        img_series{ii}=[img_i:img_i+gaps-1];
                        img_i=img_i+gaps;
                    end
                end 
                
                for j=img_series{i}
                    dlmwrite(write_name,strcat('''', deblank(fun_imgs(j,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end            
            end

            [Path, fileN, extn]=fileparts(fun_imgs(img_series{i}(1),:)); 
            step=size(img_series{i},2);
            dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');  

            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.output = ''', [deblank(dirs(i_dir,:)) '_avg_' num2str(i) '_of_' num2str(step) '_from_' fileN extn],''';'), '-append', 'delimiter', '', 'newline','pc');  
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.outdir = {''',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i_dir,:))],'''};'), '-append', 'delimiter', '', 'newline','pc');  

                                                                                     %% change the expression below on your own   
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.expression = ''sum(X)/size(X,1)'';'), '-append', 'delimiter', '', 'newline','pc'); 


            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dmtx = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.interp=1;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i), '}.spm.util.imcalc.options.dtype=4;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
            img_ii=img_ii+step;
        end
         fprintf('\nAll set! Strat to run...\n\n')
         spm_jobman('run',write_name)    
         delete(write_name);
    end

  end
 fprintf('\n-----All average-calculation are done! Output is in each subject''s folder!\n\n')
