function FG_zip_files_as_gz(rootdir,filter1,h_del)
% this script list all subfolders under a dir no matter it contains
% files or not.
%% it can deal with either the .nii or .gz files
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the file filters(e.g. "*.nii"'};
    num_lines = 1;
    def = {'*.nii'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    
    h_del=questdlg('Do you want to delete the original image after zip it into .gz file?','Hi...','Delete','No','No');
    pause(0.1)    
end

full_name_output=FG_genpath(rootdir);
% [full_name_output1,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(rootdir);

for i=1:size(full_name_output,1)
    
    [all_files,all_cell_files,all_file_names]=FG_list_one_level_files(deblank(full_name_output(i,:)),filter1);
    if ~isempty(all_files)
        for j=1:size(all_file_names,1)
            PI=fullfile(deblank(full_name_output(i,:)),deblank(all_file_names(j,:)));
            fprintf('\n----Dealing with  ''%s''\n',PI)
            % deal with '.gz' files
            try
                gzip(PI);
                if strcmp(h_del,'Delete')
                    delete(PI);
                    fprintf('----Delete the original image...\n')
                end
            catch me
               fprintf(' %s \n',me.message)                    
            end       
        end 
    end
end


fprintf('\n-----------------ALL 4D-->3Ds under the root folder are Done!\n')