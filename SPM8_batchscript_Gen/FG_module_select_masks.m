function [h_mask,mask_imgs_tem]=FG_module_select_masks(groups,opts)
% select n-subject folders
if nargin==0
  groups = FG_module_select_groups;  
  opts=FG_module_settings_of_questdlg;
end


  % select mask imgs
    h_mask=questdlg(opts.mask.prom,opts.mask.title,opts.mask.oper{1},opts.mask.oper{2},opts.mask.oper{1}) ;
    if strcmp(h_mask,opts.mask.oper{1})
       mask_imgs_tem =  spm_select(inf,'any','Select all the individual mask imgs ', [],pwd,'.*nii$|.*img$'); 
       if FG_check_ifempty_return(mask_imgs_tem) , mask_imgs_tem='return'; return; end
    elseif strcmp(h_mask,opts.mask.oper{2})
        for g=1:size(groups,1)
            mask_imgs_tem{g} =  spm_select(inf,'any',['Select all the individual mask imgs for the group:' groups(g)], [],pwd,'.*nii$|.*img$');
            if FG_check_ifempty_return(mask_imgs_tem{g}), mask_imgs_tem='return'; return; end              
        end
    end 

