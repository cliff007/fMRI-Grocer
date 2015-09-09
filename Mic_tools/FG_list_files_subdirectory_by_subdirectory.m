function [varargout]=FG_list_files_subdirectory_by_subdirectory(rootdir,filter1)
% this script list all subfolders under a dir no matter it contains
% files or not.
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
end

[full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(rootdir);
    

for i=1:size(full_name_output,1)
    fprintf('\n %s :\n',deblank(full_name_output(i,:)))    
    [all_files,all_cell_files,all_file_names]=FG_list_one_level_files(deblank(full_name_output(i,:)),filter1);
    if ~isempty(all_files)
        for j=1:size(all_file_names,1)
            fprintf('\t%d. %s \n',j,deblank(all_file_names(j,:)))
        end    
    end
end

if nargout~=0
    varargout={full_name_output,relative_name_output,full_cell_name,relative_cell_name};
end