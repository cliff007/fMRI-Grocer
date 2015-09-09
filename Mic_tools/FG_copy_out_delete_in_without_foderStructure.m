function FG_copy_out_delete_in_without_foderStructure(h_op,root_dir,file_filters,out_dir)
    if nargin==0
        h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...', 'Delete in...','Copy out...') ;
        if isempty(h_op), return; end
        root_dir = FG_module_select_root('Select a root folder of the files/folders you want to deal with');

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

        if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...') 
           out_dir = FG_module_select_root('Select a folders to hold the outputs','N');  
           if FG_check_ifempty_return(out_dir), return; end
        end            
    end     
         
    display('----Listing folder structure...')        
    pause(0.5)
    all_dirs=FG_genpath(root_dir);  %   FG_genpath      
    
    
    %% for file copy out to new folders with a same folder structure
 for i_dir=1:size(all_dirs,1)  
     
     if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...')   
         
        tem_root=deblank(all_dirs(i_dir,:)); 
        display(['----Dealing with ' tem_root])
        
            for i=1:size(file_filters,1)
                [a_all,all_files]=FG_list_all_files(tem_root,'*',file_filters{i});
                 if isempty(a_all), continue,end
                 [a,a_all]=FG_separate_files_into_name_and_path(a_all);               
                for j=1:length(all_files)
                    if strcmp(h_op,'Copy out...')
                        copyfile (deblank(all_files{j}),deblank(fullfile(out_dir,deblank(a_all(j,:)))));
                    else
                        movefile (deblank(all_files{j}),deblank(fullfile(out_dir,deblank(a_all(j,:)))));
                    end
                end
            end
     end

        fprintf('\n--------Copying/Moving out Folders is done !\n\n')
 end


     %% for file delete in original folders  
     if strcmp(h_op,'Delete in...') 
        % delete the files under the root folders
        tem_root=deblank(all_dirs(i_dir,:)); 
        display(['----Dealing with ' tem_root])
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(tem_root,'*',file_filters{i});
            if isempty(a_all), continue,end
            for j=1:length(all_files)
                delete(deblank(all_files{j}));
            end
        end
        fprintf('\n--------Deleting Folders is done !\n\n')
     end
 end