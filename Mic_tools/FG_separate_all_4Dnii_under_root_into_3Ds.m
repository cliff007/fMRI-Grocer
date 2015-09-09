function FG_separate_all_4Dnii_under_root_into_3Ds(rootdir,filter1,h_del)
% this script list all subfolders under a dir no matter it contains
% files or not.
%% it can deal with either the .nii or .gz files
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the file filters(e.g. "*.nii", "*.gz")'};
    num_lines = 1;
    def = {'*.nii'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    filter1 =aa{1};
    
    h_del=questdlg('Do you want to delete the 4D image(including the potential .gz files) after generating 3D image series?','Hi...','Delete','No','No');
    pause(0.1)
end

[full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(rootdir);
    
for i=1:size(full_name_output,1)
    
    [all_files,all_cell_files,all_file_names]=FG_list_one_level_files(deblank(full_name_output(i,:)),filter1);
    if ~isempty(all_files)
        for j=1:size(all_file_names,1)
            PI=fullfile(deblank(full_name_output(i,:)),deblank(all_file_names(j,:)));
            fprintf('\n----Dealing with  ''%s''\n',PI)
            % deal with '.gz' files
            if strcmpi(PI(end-2:end), '.gz')
                try
                    gunzip(PI);
                    if strcmp(h_del,'Delete')
                        delete(PI);
                        fprintf('----Delete the original .gz file...\n')
                    end
                    PI = PI(1:end-3);
                catch me
                   fprintf(' %s \n',me.message)     
                end
            end
            
            try
                FG_expand_nii_scan(PI)  
            catch me1
                fprintf(' %s \n',me1.message)    
            end                
            
            if strcmp(h_del,'Delete')
                delete(PI);
                fprintf('----Delete the 4D image...\n')
            end
            
        end 
    end
end


fprintf('\n-----------------ALL 4D-->3Ds under the root folder are Done!\n')