function fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts)

        % files writing
        if strcmp(h_files,opts.files.oper{1})
            fun_imgs=all_fun_imgs;
        elseif strcmp(h_files,opts.files.oper{2})            
%             fun_imgs=all_fun_imgs{g};
            fun_imgs=FG_add_characters_at_the_start(all_fun_imgs{g},[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:)), filesep]);
        elseif strcmp(h_files,opts.files.oper{3})              
            fun_imgs=spm_select('FPList',[root_dir,deblank(groups(g,:)), filesep,deblank(dirs(i,:))],file_filter);                      
        end