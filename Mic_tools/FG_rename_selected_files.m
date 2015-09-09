function FG_rename_selected_files
% root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
% if FG_check_ifempty_return(root_dir), return;  end 
% cd (root_dir)


% select files
 all_fileNames = spm_select(Inf,'.*','Select mutiple files you want to rename', [],pwd,'.*'); 
 if FG_check_ifempty_return(all_fileNames), return;  end 

%  enter file rename function
 FG_file_rename_options(all_fileNames);

 fprintf('\n------All are done!\n');