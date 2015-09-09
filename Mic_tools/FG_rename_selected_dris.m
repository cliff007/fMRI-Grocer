function FG_rename_selected_dris
% root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
% if FG_check_ifempty_return(root_dir), return; end
% cd (root_dir)

% select dirs
all_dirNames = spm_select(Inf,'dir','Select mutiple dirs you want to rename', [],pwd,'.*');
if FG_check_ifempty_return(all_dirNames), return; end

% enter dir rename function
FG_dir_rename_options(all_dirNames);

fprintf('\n------All are done!\n');
