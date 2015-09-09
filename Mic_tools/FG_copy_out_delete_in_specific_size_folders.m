function FG_copy_out_delete_in_specific_size_folders

    h_op=questdlg('What do you want to do?','Hi....','Move out...', 'Copy out...','Delete in...','Move out...') ;
    root_dir = FG_module_select_root('Select a root folder of the files/folders you want to deal with');
    
  % specify files you want to deal with   
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'*.*'};
%     def = {'*.nii'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    file_filter =aa{1};    
    
    prompt = {'Specify the file-size filter:(Unit: byte(b), 1024b=1kb,1024*1024b=1Mb, 1024*1024*1024=1Gb ...)'};
    num_lines = 1;
    def = {'bytes==0'};
  %  def = {'bytes>1024 & bytes<1048576'};
    dlg_title='Specify the file-size range to filter subfolders...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);   
    size_filter=deblank(aa{1});   
    
    [array_folders,cell_folders_tem,folder_bytes] = FG_list_allfolders_bigger_than_bytes(root_dir,file_filter,size_filter);
 
    % subfunction: sort the array elements by length

fprintf('\nRunning.........\n ');
 %% for file move out to new folders with a same folder structure
 if strcmp(h_op,'Move out...')  || strcmp(h_op,'Copy out...')
    if size(cell_folders_tem,1)>0    
        [cell_folders,length_array,idx]=FG_sort_vector_elements_by_length(cell_folders_tem,'descend');% for copy-out 
        out_dir = spm_select(1,'dir','Select a foder to hold the ouput foders', [],pwd);
        if FG_check_ifempty_return(root_dir), return; end;    

        if strcmp(h_op,'Move out...')             
            for j=1:size(cell_folders,1)
               % fprintf(' copying\n %s \n to \n %s \n',all_files{j},new_all_files{j});
                movefile (char(deblank(cell_folders(j))),out_dir);
            end    
        elseif strcmp(h_op,'Copy out...')
            for j=1:size(cell_folders,1)
               % fprintf(' copying\n %s \n to \n %s \n',all_files{j},new_all_files{j});
                copyfile (char(deblank(cell_folders(j))),out_dir);
            end   
        end
        fprintf('\n--------Moving/Copying out Folders is done !\n\n')
    else
        fprintf('\n--------No target found!\n\n')  
    end
 end
 

 %% for folder delete in original folders  
 if strcmp(h_op,'Delete in...') 
    % delete the files under the root folders
    if size(cell_folders_tem,1)>0
        [cell_folders,length_array,idx]=FG_sort_vector_elements_by_length(cell_folders_tem,'ascend'); % for delete-in
        for j=1:size(cell_folders,1)
           %      disp([' Deleting ' all_files{j}]);
           try
               rmdir(char(deblank(cell_folders(j))),'s'); % in order to delete folders that is not empty
           catch me
               me.message
               continue;
           end
        end
        fprintf('\n--------Deleting Folder is done!\n\n')
    else
        fprintf('\n--------No target found!\n\n')    
    end    
 end


