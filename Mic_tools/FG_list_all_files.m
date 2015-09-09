function [all_files,all_cell_files]=FG_list_all_files(rootdir,filter1,filter2)
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files in its directory and its sub directories', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)','Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'**','*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
elseif nargin==1
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)','Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
    def = {'**','*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
end

if strcmpi(filter1,'**')
    root=fullfile(rootdir, filter1, filter2);
elseif strcmpi(filter1,'*')
    if ~strcmpi(rootdir,'./')
        rootdir=FG_del_filesep_at_the_end(rootdir);
    end
    root=fullfile(rootdir, filter2);    
end
all_files_tem=FG_list_allfiles_in_subdirs(root,'bytes~=0');  %% use  'bytes~=0' to filter the empty folders (or folders that has no specific files)
all_files={};

for i=1:length(all_files_tem)
   % disp(all_files_tem(i).name)
    all_files{i}=all_files_tem(i).name;
end;

all_cell_files=all_files';
all_files=char(all_cell_files); % use "char" function to convert the cell array into char array


fprintf('\n\n-----------listing done.............\n\n')