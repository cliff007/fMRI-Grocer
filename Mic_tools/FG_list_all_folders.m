function [varargout]=FG_list_all_folders(rootdir,filter1,filter2)
% be careful: this script will ignore all the folders that doesn't contain
% files or specific files
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files in its directory and its sub directories', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)','Specify a file filters to search file-related folders(e.g."*.m", "CBF*")'};
    num_lines = 1;
    def = {'**','*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
elseif nargin==1
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)','Specify a file filters to search file-related folders(e.g."*.m", "CBF*")'};
    num_lines = 1;
    def = {'**','*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
end


root=[rootdir filter1 filesep filter2];
all_folders_tem=FG_list_allfolders_in_subdirs(root);

for i=1:length(all_folders_tem.folders)
    all_folders{i}=all_folders_tem.folders(i);
end;



% remove all the dirs that out of the specific root_dir
all_folders_cell=all_folders';
within_folders=cellfun(@(x) (length(rootdir)-1) <= length(x{:}),all_folders_cell);
all_folders=all_folders_cell(find(within_folders==1));
% removing done

all_folders=cellfun(@cell2mat,all_folders,'UniformOutput', false);  % caution: each element in the all_folders is still a cell array
all_folders=char(all_folders); % use "char" function to convert the cell array into char array

if nargout == 0 || nargout == 1
    varargout(1)={all_folders};
elseif nargout == 2
    varargout(1)={all_folders};
    varargout(2)={all_folders_cell};
end

fprintf('\n\n-----------listing done.............\n\n')