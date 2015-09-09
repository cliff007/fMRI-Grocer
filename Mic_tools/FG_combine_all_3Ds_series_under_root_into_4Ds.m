function FG_combine_all_3Ds_series_under_root_into_4Ds(filter2, fileprefix, rootdir)
% this script list all subfolders under a dir no matter it contains
% files or not.
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files in its directory and its sub directories', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)',...
        'Specify a file filters to search file-related folders(e.g."*.m", "CBF*")', ...
        'Specify a filename of the output 4D images(e.g."Multi_4DScan")'};
    num_lines = 1;
    def = {'**','ALL*.nii','Multi_4DScan'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
    fileprefix=aa{3};
elseif nargin==1
    prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)',...
        'Specify a file filters to search file-related folders(e.g."*.m", "CBF*")', ...
        'Specify a filename of the output 4D images(e.g."Multi_4DScan")'};
    num_lines = 1;
    def = {'**','ALL*.nii','Multi_4DScan'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    filter2 =aa{2};
    fileprefix=aa{3};
end

[all_folders,all_folders_cell]=FG_list_all_folders(rootdir,filter1,filter2);
clear all_folders_cell
if FG_issame(deblank(all_folders(1,:)),rootdir) || FG_issame(deblank(all_folders(1,:)),rootdir(1,1:end-1)) 
    all_folders=all_folders(2:end,:);
end

for i=1:size(all_folders,1)

    fprintf('\n----Dealing with folder:  ''%s''\n',deblank(all_folders(i,:)))
    cd (deblank(all_folders(i,:)))
    FG_collapse_nii_scan(filter2, fileprefix, deblank(all_folders(i,:)))              

end
    cd (rootdir)

fprintf('\n-----------------ALL 3Ds-->4D under the root folder are Done!\n')