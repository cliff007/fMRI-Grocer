function [varargout]=FG_list_one_level_files(rootdir,filter1)

if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
%     [dirNames,dirpath]=FG_get_groupfolder_names(rootdir);
    
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};

elseif nargin==1
%     [dirNames,dirpath]=FG_get_groupfolder_names(rootdir);    
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
end

if FG_check_ifempty_return(rootdir), return; end
rootdir=FG_add_filesep_at_the_end(rootdir);
root=[rootdir filter1];
all_files_tem=FG_list_allfiles_in_subdirs(root);
all_files={};

j=1;
for i=1:length(all_files_tem)
   % disp(all_files_tem(i).name)
   if exist(all_files_tem(i).name,'dir')~=7 % exclude the folders
        all_files{j}=all_files_tem(i).name;
        j=j+1;
   end
end;

all_cell_files=all_files';
all_files=char(all_cell_files); % use "char" function to convert the cell array into char array
all_file_names=spm_str_manip(all_files,'dt');

if nargout==1 || nargout==0
   varargout(1)={all_files}; 
elseif nargout==2
    varargout(1)={all_files};
    varargout(2)={all_cell_files};
elseif nargout==3
    varargout(1)={all_files};
    varargout(2)={all_cell_files};
    varargout(3)={all_file_names};
end
    
% fprintf('\n\n-----------listing done.............\n\n')

