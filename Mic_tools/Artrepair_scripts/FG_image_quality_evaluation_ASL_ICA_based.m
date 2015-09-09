function out_imgs=FG_image_quality_evaluation_ASL_ICA_based(fun_imgs)
% turn the warning of matlab off, and close all the figures and progress bars        
    spm_figure('close',allchild(0));    
    
    if nargin==0
        warning off all % turn the warning of matlab off, 
        fun_imgs=spm_select(inf,'image','Select a group of images you want to evaluate...',[],pwd,'^p.*');         
    end
    
    fun_imgs=FG_remove_potential_dot1_of_image_names(fun_imgs); % remove the potential ",1"
    
    if isempty(fun_imgs)
        return
    elseif size(fun_imgs,1)<2
        fprintf('\n----Are you kidding? ------Not more than 2 images!\n\n')
        return
    end

% reset images' origin
     FG_reset_origin_selectedImgs(fun_imgs);
     
% read the first image info and set its path as the default output path
    imgmat=spm_vol(deblank(fun_imgs(1,:)));
    [root_dir,b,c,d]=fileparts(deblank(fun_imgs(1,:))); 
    [root_pth,root_sub]=FG_sep_group_and_path(deblank(root_dir));    
        root_first=[root_pth,root_sub '_ICA_Output'];
    if ~exist(root_first,'dir')
        mkdir (root_first);
    end
    
  
     if nargin==0 || nargin==1 
        write_name=fullfile(root_first,'quality_control_report.txt');
     end
     
     dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
     dlmwrite(write_name,['---report for:' root_dir], '-append',  'delimiter', '', 'newline','pc'); 
     dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');

   
    
% manipulate the even and odd images
    OE_outs=FG_singledir_imgs_cal_avgODD_and_even_separately(fun_imgs,root_first);  %%% all outputs will be in the same folder as the first image
        % %     % files in the OE_outs:
        % %         % 1.avg_odd
        % %         % 2.avg_even
        % %         % 3.Difference_Odd_Even
        % %         % 4.Difference_Even_Odd
        % %         % 5.Average of all
        
%     for i=[3 4 5]
%         delete (deblank(OE_outs(i,:)))
%     end


   
    maskY2=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.55);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
    FG_write_vol(imgmat,maskY2,fullfile(root_first,'SPM_brain.nii'));
%     FG_fill_inside_Graymatter(fullfile(root_first,'SPM_brain.nii'),1)
    
    maskY3=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.5,0.8);   %% 0.45-0.8TMVV can be used to extract the skull of the brain
%     maskY3=imopen(smooth3(maskY3,'box',1),strel('square',1)); % erode the potential small parts within the skull
    maskY3=FG_delete_small_clusters(maskY3,0.30);
    FG_write_vol(imgmat,maskY3>0,fullfile(root_first,'SPM_skull.nii'));
    
    
    maskY2=FG_get_SPM_TMVV_and_TMVV_based_mask(FG_read_vols(OE_outs(1,:)),0.01,0.20);   % 0.55 TMVV is a quite good threshold to extract the whole brain with skull
    FG_write_vol(imgmat,maskY2,fullfile(root_first,'SPM_background.nii'));
%     FG_fill_inside_Graymatter(fullfile(root_first,'SPM_brain.nii'),1)
    
    FG_enhanced_spm_check_registration(strvcat( fullfile(root_first,'SPM_brain.nii') ,...
                                                fullfile(root_first,'SPM_background.nii') ,...
                                                fullfile(root_first,'SPM_skull.nii')));
                                            
    out_imgs=strvcat( fullfile(root_first,'SPM_brain.nii') ,...
                                                fullfile(root_first,'SPM_background.nii') ,...
                                                fullfile(root_first,'SPM_skull.nii'));                                        
                                            
    % save the SPM-dispaly picture
    saveas(gcf,fullfile(root_first,'2_Snap_artifact_relateds.jpg'))
    close gcf
 

   fprintf('\n.... All done......\n')   

