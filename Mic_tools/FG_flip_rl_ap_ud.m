function FG_flip_rl_ap_ud(imgs,direction)
if nargin==0
    imgs=spm_select(inf,'any','Please select the images...',[],pwd,'.*img$|.*nii$');
    if isempty(imgs), return; end
    direction=questdlg('Which direction do you want to flip?','Flip over...','LeftRight','UpDown','AnteriorPosterior','LeftRight') ;    
end

for k=1:size(imgs,1)
        img=deblank(imgs(k,:));
        [v,mat]=FG_read_vols (img);
        
        %  [v,mat]=spm_flip_analyze_images ('resliced_lSCN_roi_roi_as_61x73x61.hdr');
        if strcmpi(direction,'AnteriorPosterior')
            for i=1:size(v,3)
                v1(:,:,i)=fliplr(squeeze( v(:,:,i))); 
            end
            flipped_img=FG_subfix_name(img,'AP');
        elseif strcmpi(direction,'UpDown')     
            for i=1:size(v,2)
                v1(:,i,:)=fliplr(squeeze( v(:,i,:))); 
            end    
            flipped_img=FG_subfix_name(img,'UD');
        elseif strcmpi(direction,'LeftRight')
            for i=1:size(v,3)
                v1(:,:,i)=flipud(squeeze( v(:,:,i)));  
            end    
            flipped_img=FG_subfix_name(img,'LR');
        end
        
        FG_write_vol(mat,v1,flipped_img)

        BGimg=fullfile(FG_rootDir('fmri_grocer'), 'Templates','colin2.img');
        FG_overlay_ROI_on_ChechReg(strvcat(img,flipped_img),BGimg)
        
        fprintf('\nThe top one is the original one, the bottom one is the flipped one...\n')
        
end

fprintf('\nAll set...\n')