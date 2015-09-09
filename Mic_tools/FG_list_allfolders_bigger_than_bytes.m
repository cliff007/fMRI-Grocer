function [varargout] = FG_list_allfolders_bigger_than_bytes(rootdir,file_filter,size_filter)
if nargin ==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
   % def = {'*.nii'};
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    file_filter =aa{1};
    
    
    prompt = {'Specify the file-size filter:(Unit: byte(b), 1024b=1kb,1024*1024b=1Mb, 1024*1024*1024=1Gb ...)'};
    num_lines = 1;
    def = {'bytes>1024 & bytes<1048576'};
    dlg_title='Specify the file-size range to filter subfolders...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);   
    size_filter=deblank(aa{1});
end


fprintf('\n-----------Searching..........\n')
[subdirs,subdir_tot_size]=FG_get_allsubdirs_and_foldersize(rootdir,file_filter);
S.folders=cellstr(subdirs);
S.bytes=subdir_tot_size;

S=FG_evaluate(S,size_filter);

if nargout~=0
    varargout(1)={char(S.folders)};  % array folder output
    varargout(2)={S.folders};  % cell folder output
    varargout(3)={S.bytes};
elseif nargout==0
    all_specific_subfolders=S.folders
    all_specific_subfolder_sizes=S.bytes
end

%% ----subfunction---------------------------------------------------
function S_filtered = FG_evaluate(S, expr)
% True for item where evaluated expression is correct or return a non empty
% cell.

% Get fields that can be used
folders = S.folders; %ok
bytes = S.bytes; %ok

tf = eval(expr);
S_filtered.folders=folders(tf);
S_filtered.bytes=bytes(tf);


% % Convert cell outputs returned by "strfind" or "regexp" filters to a
% % logical.
% if iscell(tf)
%   tf = not( cellfun(@isempty, tf) );
% end

%---------------------------- end of subfunction --------------------------
