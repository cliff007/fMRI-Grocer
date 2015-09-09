function mean_fun_imgs=FG_module_assign_mean_Img(mean_fun_imgs_tem,g,h_mean,opts)

    % assigning the mean* img of groups
    if strcmp(h_mean,opts.mean.oper{1})
        mean_fun_imgs=mean_fun_imgs_tem;
    elseif strcmp(h_mean,opts.mean.oper{2})
        mean_fun_imgs=mean_fun_imgs_tem(g);
    elseif FG_check_ifempty_return(mean_fun_imgs_tem)
        mean_fun_imgs=[];
    end
