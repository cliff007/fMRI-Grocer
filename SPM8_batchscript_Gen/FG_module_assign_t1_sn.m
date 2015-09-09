function t1_imgs_sn=FG_module_assign_t1_sn(t1_imgs_sn_tem,g,h_t1_sn,opts)

  % assigning the t1_sn of groups
    if strcmp(h_t1_sn,opts.t1_sn.oper{1})
        t1_imgs_sn=t1_imgs_sn_tem;
    elseif strcmp(h_t1_sn,opts.t1_sn.oper{2})
        t1_imgs_sn=t1_imgs_sn_tem{g};
    end