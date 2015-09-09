function FG_copy_or_move_out_files_with_folder_name

    h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...','Copy out...') ;
    root_dir = spm_select(1,'dir','Select a root folder of the files/folders you want to deal with', [],pwd);
    if FG_check_ifempty_return(root_dir), return; end
    
%     prompt = {'1 for files''s parent folder names, 2 for files''s grandparent folder names -----'};
%     dlg_title='Specify the level of the folder name...';
%     def={'1'};
%     folder_level = inputdlg(prompt,dlg_title,1,def,'on');   
%     folder_level = str2num(folder_level{1});
%     
%     if  folder_level ==2
%         [root_dir_path,root_dir_name]=FG_sep_group_and_path(root_dir);
%     end
    
           
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
        
    out_dir =  spm_select(1,'dir','Select a folders to hold the output files', [],pwd); 
    if FG_check_ifempty_return(out_dir), return; end
    
fprintf('\nRunning.........\n ');
 %% for file copy out to new folders with a same folder structure
 if strcmp(h_op,'Copy out...') ||  strcmp(h_op,'Move out...') 
    if strcmp(h_op,'Copy out...')
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(root_dir,'**',file_filters{i});
            new_all_files=regexprep(all_files,regexptranslate('escape',root_dir),'');  % this is a cell array; remove the root_dir
            new_all_file_names=regexprep(new_all_files,filesep,'_'); % replace all the filesep into '_' to create new file names
            for j=1:length(all_files)
                tem=FG_check_and_rename_existed_file(fullfile(out_dir,deblank(new_all_file_names{j})));
                copyfile (deblank(all_files{j}),tem);
            end
        end    
    elseif strcmp(h_op,'Move out...') 
        for i=1:size(file_filters,1)
            [a_all,all_files]=FG_list_all_files(root_dir,'**',file_filters{i});
            new_all_files=regexprep(all_files,regexptranslate('escape',root_dir),'');  % this is a cell array; remove the root_dir
            new_all_file_names=regexprep(new_all_files,filesep,'_'); % replace all the filesep into '_' to create new file names
            for j=1:length(all_files)
                tem=FG_check_and_rename_existed_file(fullfile(out_dir,deblank(new_all_file_names{j})));
                movefile (deblank(all_files{j}),tem);
            end
        end  
    end
    
    
    fprintf('\n--------Copying/Moving out files with folder name is done !\n\n')
 end
 
