function FG_move_subfolders_up_a_level_with_parent_folder_name
    rootdir = spm_select(1,'dir','Select the root folder you want to lists all sub-directories', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify a folder name filter to select specific subfolders-----'};
    dlg_title='folder name filter...';
    def={'sub'};
    folder_name = inputdlg(prompt,dlg_title,1,def,'on');   
    h_opt=questdlg('Do you want to prefix or subfix the subdir''s parent folder name?','Hi...','prefix','subfix','subfix');
    
    name_way = questdlg('one-level: just pre/sub-fix target folder''s parent folder name; two-level: pre/sub-fix target folder''s two-level parent folder name', ...
                    'Select pre/sub-fix naming way...','one-level','two-level','one-level') ;
    pause(0.5)
    
    [full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(rootdir);
    full_name_output=full_name_output(2:end,:);% start from 2, because of wanting to remove the root folder
    
    labeled_dir=[];
    for i=1:size(full_name_output,1)  
        tem=[];
        [a,b]=FG_sep_group_and_path(full_name_output(i,:));
        tem=regexp(b,folder_name{1}, 'once');
        if ~isempty(tem)
            labeled_dir=[labeled_dir,i];
        end
    end
    
    for i=1:length(labeled_dir)
        [root_dir_path,root_dir_name]=FG_sep_group_and_path(full_name_output(labeled_dir(i),:));
        [root_dir_path1,root_dir_name1]=FG_sep_group_and_path(root_dir_path);
        [root_dir_path2,root_dir_name2]=FG_sep_group_and_path(root_dir_path1);
        if strcmp(h_opt,'prefix')
            if strcmpi(name_way,'two-level')
                movefile(deblank(full_name_output(labeled_dir(i),:)),fullfile(root_dir_path1,[deblank(root_dir_name2) '_' deblank(root_dir_name1) '_' deblank(root_dir_name)]));
            elseif strcmpi(name_way,'one-level')
                movefile(deblank(full_name_output(labeled_dir(i),:)),fullfile(root_dir_path1,[deblank(root_dir_name1) '_' deblank(root_dir_name)]));              
            end
        elseif strcmp(h_opt,'subfix')
            if strcmpi(name_way,'two-level')
                movefile(deblank(full_name_output(labeled_dir(i),:)),fullfile(root_dir_path1,[deblank(root_dir_name) '_' deblank(root_dir_name2) '_' deblank(root_dir_name1)])); 
            elseif strcmpi(name_way,'one-level')
                movefile(deblank(full_name_output(labeled_dir(i),:)),fullfile(root_dir_path1,[deblank(root_dir_name) '_' deblank(root_dir_name1)]));                 
            end
        end
    end
    
    fprintf('\n--------Moving subfolders up with folder name is done !\n\n')