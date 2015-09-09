function dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts)

    % assigning the subfolders of groups
    if strcmp(h_folder,opts.folders.oper{1})
        dirs=dirs_tem;
    elseif strcmp(h_folder,opts.folders.oper{2}) 
        dirs=dirs_tem{g};
    elseif strcmp(h_folder,opts.folders.oper{3})
        dirs=char(FG_readsubfolders(fullfile(root_dir,deblank(groups(g,:))),folder_filter));
    end
    % assigning is done 