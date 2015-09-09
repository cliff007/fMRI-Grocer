function FG_copy_out_delete_in_folders_with_same_folder_structure
    rootdir = spm_select(1,'dir','Select the root-folder in which you want to list all sub-directories', [],pwd);
    if isempty(rootdir) ,  return; end
    
    % specify files you want to deal with
     % enter the num of folder filters
        prompt = {'How many folder filters do you want to specify:'};
        num_lines = 1;
        def = {'1'};
        dlg_title='filter num....';
        file_filter_n = inputdlg(prompt,dlg_title,num_lines,def);
        file_filter_n =str2num(file_filter_n{1});
     % enter the folder filters   
        dlg_prompt={};
        dlg_prompt1={};
        dlg_prompt2={};  
        dlg_title='filter...';
        for i=1:file_filter_n
            dlg_prompt1=[dlg_prompt1,['folder filter',num2str(i),'----------------------------------']];
            dlg_prompt2=[dlg_prompt2,'test'];
        end  
        folder_filters =inputdlg(dlg_prompt1,dlg_title,num_lines,dlg_prompt2);
        
        
    h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...', 'Delete in...','Copy out...') ;
    if isempty(h_op)
        return;       
    end    
    
     if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...') 
         out_dir = FG_module_select_root('Select a folder to hold the outputs','No');
     end
    
    pause(0.5)
%     all_dirs=FG_genpath(rootdir);
    
        [full_name_output,relative_name_output,full_cell_name]=FG_list_all_dirs_recursively(rootdir);
        if isempty(full_name_output) ,  fprintf('\n------no subdirectory found---\n');return; end


fprintf('\nRunning.........\n ');
 %% for file copy out to new folders with a same folder structure
 if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...') 
%          out_dir = FG_module_select_root('Select a folder to hold the outputs','No');
         new_full_cell_name=cellfun(@(x) regexprep(deblank(x),regexptranslate('escape',rootdir),regexptranslate('escape',out_dir)) ,full_cell_name,'UniformOutput',false);
         new_full_names=char(new_full_cell_name);
         new_paths=FG_sep_group_and_path(new_full_names);
    
%     FG_copy_folder_structure(root_dir,out_dir,'Copy full folder structure') ; % build up the a whole folder structure to make the following direct copy possible
    
    if strcmp(h_op,'Copy out...')
        for i=1:size(folder_filters,1) 
            for j= size(full_name_output,1):-1:2 % exclude the root dir 
                [a,b]=FG_sep_group_and_path(deblank(full_name_output(j,:)));
                ttt=regexp(b,regexptranslate('escape',folder_filters{i}), 'once');
                if ~isempty(ttt)
                    mkdir(deblank(new_paths(j,:)));
                    copyfile (deblank(full_name_output(j,:)),deblank(new_full_names(j,:)),'f');
                end
            end
        end
    
    elseif strcmp(h_op,'Move out...') 
        for i=1:size(folder_filters,1) 
            for j= size(full_name_output,1):-1:2 % exclude the root dir  
                [a,b]=FG_sep_group_and_path(deblank(full_name_output(j,:)));
                ttt=regexp(b,regexptranslate('escape',folder_filters{i}), 'once');
                if ~isempty(ttt)
                    mkdir(deblank(new_paths(j,:)));
                    movefile (deblank(full_name_output(j,:)),deblank(new_full_names(j,:)),'f');
                end
            end
        end
        
    end
    
    
    fprintf('\n--------Copying/Moving out Folders is done !\n\n')
 end
 

 %% for file delete in original folders  
 if strcmp(h_op,'Delete in...') 
    % delete the files under the root folders
    for i=1:size(folder_filters,1) 
        for  j= size(full_name_output,1):-1:2 % exclude the root dir 
            [a,b]=FG_sep_group_and_path(deblank(full_name_output(j,:)));
            ttt=regexp(b,regexptranslate('escape',folder_filters{i}), 'once');
            if ~isempty(ttt)
                rmdir(deblank(full_name_output(j,:)),'s');
            end
        end
    end
    fprintf('\n--------Deleting Folders is done !\n\n')
 end


