function mask_imgs=FG_module_assign_mask(mask_imgs_tem,g,h_mask,opts)

    % assigning the t1 of groups
    if strcmp(h_mask,opts.mask.oper{1})
        mask_imgs=mask_imgs_tem;
    elseif strcmp(h_mask,opts.mask.oper{2})
        mask_imgs=mask_imgs_tem{g};
    end