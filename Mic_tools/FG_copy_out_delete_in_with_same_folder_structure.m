function FG_copy_out_delete_in_with_same_folder_structure

    h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...', 'Delete in...','Copy out...') ;
    if isempty(h_op), return; end
    root_dir = FG_module_select_root('Select a root folder of the files/folders you want to deal with');
           
 % specify files you want to deal with
     % enter the num of file filters
        prompt = {'How many file filters do you want to specify:'};
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
            dlg_prompt1=[dlg_prompt1,['file filter',num2str(i),'----------------------------------']];
            dlg_prompt2=[dlg_prompt2,'CBF*.*'];
        end  
        file_filters =inputdlg(dlg_prompt1,dlg_title,num_lines,dlg_prompt2);

fprintf('\nRunning.........\n ');
 %% for file copy out to new folders with a same folder structure
 if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...') 
    out_dir = FG_module_select_root('Select a folders to hold the outputs','N');  
    if FG_check_ifempty_return(out_dir), return; end
    
    FG_copy_folder_structure(root_dir,out_dir,'Copy full folder structure') ; % build up the a whole folder structure to make the following direct copy possible
    
    if strcmp(h_op,'Copy out...')
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(root_dir,'**',file_filters{i});
            new_all_files=regexprep(all_files,regexptranslate('escape',root_dir),regexptranslate('escape',out_dir));  % this is a cell array
            for j=1:length(all_files)
    %             if any(strncmpi(deblank(all_files(j,:)),file_filters{i},4))
               %      fprintf(' copying\n %s \n to \n %s \n', all_files{j},new_all_files{j});
    %             end
                copyfile (deblank(all_files{j}),deblank(new_all_files{j}));
            end
        end
    
    elseif strcmp(h_op,'Move out...') 
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(root_dir,'**',file_filters{i});
            new_all_files=regexprep(all_files,regexptranslate('escape',root_dir),regexptranslate('escape',out_dir));  % this is a cell array
            for j=1:length(all_files)
    %             if any(strncmpi(deblank(all_files(j,:)),file_filters{i},4))
               %      fprintf(' copying\n %s \n to \n %s \n', all_files{j},new_all_files{j});
    %             end
                movefile (deblank(all_files{j}),deblank(new_all_files{j}));
            end
        end
        
    end
    
    
    fprintf('\n--------Copying/Moving out Folders is done !\n\n')
 end
 

 %% for file delete in original folders  
 if strcmp(h_op,'Delete in...') 
    % delete the files under the root folders
    for i=1:size(file_filters,1)
        [a_all,all_files]=FG_list_all_files(root_dir,'**',file_filters{i});
        for j=1:length(all_files)
%             if any(strncmpi(deblank(all_files(j,:)),file_filters{i},4))
           %      disp([' Deleting ' all_files{j}]);
%             end
            delete(deblank(all_files{j}));
        end
    end
    fprintf('\n--------Deleting Folders is done !\n\n')
 end


