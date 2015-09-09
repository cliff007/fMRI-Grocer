function FG_keep_filtered_files_or_folders

    h_op=questdlg('Target: files or folder?','Hi....','files', 'folders','folders') ;
    root_dir = FG_module_select_root('Select a root folder of the files/folders you want to deal with');
    
 % enter the num of file filters
    prompt = {'How many filters do you want to specify:'};
    num_lines = 1;
    def = {'1'};
    dlg_title='filter num....';
    file_filter_n = inputdlg(prompt,dlg_title,num_lines,def);
    file_filter_n =str2num(file_filter_n{1});
 % enter the file filters   
    dlg_prompt={};
    dlg_prompt1={};
    dlg_prompt2={};  
    dlg_title='filter...';
    for i=1:file_filter_n       
        if strcmpi(h_op,'files')
            dlg_prompt1=[dlg_prompt1,['file filter',num2str(i),'----------------------------------']];
            dlg_prompt2=[dlg_prompt2,'CBF'];     
        elseif strcmpi(h_op,'folders')
            dlg_prompt1=[dlg_prompt1,['folder filter',num2str(i),'----------------------------------']];
            dlg_prompt2=[dlg_prompt2,'restASL'];
        end
        
    end  
    filters =inputdlg(dlg_prompt1,dlg_title,num_lines,dlg_prompt2);
    
    fprintf('\nRunning.........\n ');   
    pause(0.01)
    [full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(root_dir); % get all the subdirectories


 if strcmp(h_op,'files')  %% for file delete in original folders 
    % delete the files under the root folders
    for  j= size(full_name_output,1):-1:1  %  
        files=FG_list_one_level_files(deblank(full_name_output(j,:)),'*.*') ;  
        if isempty(files)
            continue
        end
        [b,a]=FG_separate_files_into_name_and_path(files);
        
        for k=1:size(a,1)
            t=0; % label of delete or not
            for i=1:size(filters,1) 
                t1=regexp(deblank(a(k,:)),regexptranslate('escape',filters{i}), 'once');
                if ~isempty(t1)
                    t=1;
                    break;
                end              
            end
            if t==0 % delete all the files that are not filtered
                delete(deblank(files(k,:)));
            end
        end
    end
    fprintf('\n--------Deleting files is done !\n\n')
 elseif strcmp(h_op,'folders')  %% for file delete in original folders  
    % delete the files under the root folders    
    for  j= size(full_name_output,1):-1:2  % :2 is to exclude the root folder 
        t=0; % label of delete or not        
        if j<size(full_name_output,1)  && exist('last_dir','var')% if the the current folder is a root folder of the last keeped one, keep it
            [pth,name]=FG_sep_group_and_path(deblank(last_dir));
            t1=FG_issame(FG_del_filesep_at_the_end(pth),deblank(full_name_output(j,:)));
            if t1
                last_dir=deblank(full_name_output(j,:)); % update 'last_dir'
                continue
            end
        end
        
        [a,b]=FG_sep_group_and_path(deblank(full_name_output(j,:)));    
        for i=1:size(filters,1) 
            t1=regexp(deblank(b),regexptranslate('escape',filters{i}), 'once');
            if ~isempty(t1)
                t=1;
                last_dir=deblank(full_name_output(j,:));
                break;
            end              
        end
        if t==0 % delete all the folders that are not filtered
            rmdir(deblank(full_name_output(j,:)),'s');
        end
    end
    fprintf('\n--------Deleting Folders is done !\n\n')
 end



