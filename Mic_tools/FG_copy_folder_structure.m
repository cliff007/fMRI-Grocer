function [varargout]=FG_copy_folder_structure(root_dir,out_dir,h_op)

if nargin <3
    h_op=questdlg('What do you want to do?','Hi....','Copy full folder structure','Copy file-related folder structure','Copy full folder structure') ;
end
    
switch h_op
    case 'Copy full folder structure'

        if nargin==0
            root_dir = spm_select(1,'dir','Select the root folder that you want to copy', [],pwd);
            if FG_check_ifempty_return(root_dir), return; end
            out_dir =  spm_select(1,'dir','Select a folders to hold the outputs', [],pwd);
            if FG_check_ifempty_return(out_dir), return; end
        end

        [full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(root_dir);
        new_dirs=cellfun(@(x) [deblank(out_dir) x],relative_cell_name,'UniformOutput',false);

        % optional method to rename~~
            %  new_dirs=regexprep(full_cell_name,root_dir,out_dir)  % this is a cell array

        for i=2:size(new_dirs,1)  % srart from 2 to avoid the first root out_dir
            fprintf(' \n----creating: \n %s \n ',new_dirs{i,:});
            mkdir(deblank(new_dirs{i,:}))    
        end

        if nargout==1
           varargout={new_dirs};   % varargout must be a cell
        elseif nargout==0
            return
        end

        fprintf('\n\n-------Folders have been copied into the specific dir!---------\n')
    
    case 'Copy file-related folder structure'
        if nargin==0
            root_dir = spm_select(1,'dir','Select the root folder that you want to copy', [],pwd);
            if FG_check_ifempty_return(root_dir), return; end
            
            prompt = {'Specify the folder level filters(spm* for special one-level matched-folder, ** for multiple-level of the rootdir)','Specify a file filters to search file-related folders(e.g."*.m", "CBF*")'};
            num_lines = 1;
            def = {'**','*.*'};
            dlg_title='filters...';
            aa = inputdlg(prompt,dlg_title,num_lines,def);
            filter1 =aa{1};
            filter2 =aa{2};
            
            out_dir =  spm_select(1,'dir','Select a folders to hold the outputs', [],pwd);
            if FG_check_ifempty_return(out_dir), return; end
        end
        
        [all_name,all_cell_name]=FG_list_all_folders(root_dir,filter1,filter2);
        all_dirs=cellfun(@cell2mat,all_cell_name,'UniformOutput', false);
        new_dirs=regexprep(all_dirs,regexptranslate('escape',root_dir),out_dir);  % this is a cell array
        
        % optional method to rename~~
            %  new_dirs=regexprep(full_cell_name,root_dir,out_dir)  % this is a cell array

        for i=2:size(new_dirs,1)  % srart from 2 to avoid the first root out_dir
            fprintf(' \n----creating: \n %s \n ',new_dirs{i,:});
            mkdir(deblank(new_dirs{i,:}))    
        end

        if nargout==1
           varargout={new_dirs};   % varargout must be a cell
        elseif nargout==0
            return
        end

        fprintf('\n\n-------Folders have been copied into the specific dir!---------\n')    
end

