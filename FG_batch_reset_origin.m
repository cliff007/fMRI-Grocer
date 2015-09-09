function FG_batch_reset_origin
% batch_reset imgs' origin into the center of the img

%% modified from the SPM8 function : spm_image
% Just for SPM8/5

% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');

anyreturn=FG_modules_selection('','','','','r','g','fo');
if anyreturn, return;end
    
 for g=1:size(groups,1) 
    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts); 
     
   for j=1:size(dirs,1)
       
       % P = spm_select(Inf, 'image','Images to reset orientation of'); 
        P = spm_select('FPList', [root_dir deblank(groups(g,:)) filesep deblank(dirs(j,:))],'.*img$|.*nii$');    
        for i=1:size(P,1),
            V    = spm_vol(deblank(P(i,:)));
            M    = V.mat;
            vox  = sqrt(sum(M(1:3,1:3).^2));
            if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
            orig = (V.dim(1:3)+1)/2;
                    off  = -vox.*orig;
                    M    = [vox(1) 0      0      off(1)
                    0      vox(2) 0      off(2)
                    0      0      vox(3) off(3)
                    0      0      0      1];
            spm_get_space(P(i,:),M);

        end;
             
      fprintf('%s --- %s \n\n',groups(g,:),dirs(j,:))  
      fprintf('%s \n\n','reseting done~~')         
   end
 end

fprintf('%s \n\n','-----------All set~~') 
    
   % tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
   % if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
   %     spm_image('init',st.vols{1}.fname);
   % end;

