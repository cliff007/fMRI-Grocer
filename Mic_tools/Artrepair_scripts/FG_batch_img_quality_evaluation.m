function FG_batch_img_quality_evaluation
% batch_reset imgs' origin into the center of the img
clear;
warning off all
spm_figure('close',allchild(0));
anyreturn=FG_modules_selection('','','','','r','g','fo');
if anyreturn, return;end

 for g=1:size(groups,1) 
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
    write_name=[root_dir deblank(groups(g,:)) filesep deblank(groups(g,:)) '_subjects_info.txt']  ;   
    dlmwrite(write_name,[root_dir deblank(groups(g,:)) '---report'], 'delimiter', '', 'newline','pc');
   for j=1:size(dirs,1)
       tic
            fprintf('\n\n--Dealing with %s - %s...\n',deblank(groups(g,:)),deblank(dirs(j,:)))  
            P = spm_select('FPList', [root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))],'^p.*img$|^p.*nii$');    

            if isempty(P)
                fprintf('\n\n----No image is found under %s ',[root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))])  
                continue
            elseif rem(size(P,1),2)~=0
                P= P(1:end-1,:);
                fprintf('\n\n----image number is odd, abandon the last one...')  
                
            end
            
            try
                FG_image_quality_evaluation_ASL(P,write_name) ;  
                dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
            catch ME
                fprintf('\nThere must be something wrong on %s ',[root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))]);
                fprintf('\n----%s  \n',ME.message)
                dlmwrite(write_name,ME.message, '-append',  'delimiter', '', 'newline','pc');
                continue
            end
                
%             pause(0.01);       
%             if strcmpi(flag,'cancel')
%                fprintf('\n\n----Progress is terminated...')              
%                return
%             end
%             dlmwrite(write_name,[deblank(dirs(j,:)) '-----' flag], '-append',  'delimiter', '', 'newline','pc');         
      toc   
   end
 end

fprintf('\n\n-----------Artifact evaluation for all the subjects is done.....\n\n') 
    

