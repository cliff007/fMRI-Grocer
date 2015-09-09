function t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts)

    % assigning the t1 of groups
    if strcmp(h_t1,opts.t1.oper{1})
        t1_imgs=t1_imgs_tem;
    elseif strcmp(h_t1,opts.t1.oper{2})
        t1_imgs=t1_imgs_tem{g};
    end