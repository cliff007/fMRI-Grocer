function [full_name_output,relative_name_output,full_cell_name,relative_cell_name]=FG_list_all_dirs_recursively(rootdir)
% this script list all subfolders under a dir no matter it contains files or not.

if nargin==0
    rootdir = spm_select(1,'dir','Select the root-folder in which you want to list all sub-directories', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
end
full_name_output=FG_genpath(rootdir);
relative_name_output=FG_remove_paths(full_name_output);
full_cell_name=FG_convert_strmat_2_cell_basedon_row(full_name_output);
relative_cell_name=FG_convert_strmat_2_cell_basedon_row(relative_name_output);

fprintf('\n\n--------------------')

% 
%                 clc
%                 if nargin==0
%                     rootdir = spm_select(1,'dir','Select the root-folder in which you want to list all sub-directories', [],pwd);
%                     if FG_check_ifempty_return(rootdir), return; end
%                 end
% 
%                 [all_folders,sub_folders]=FG_read_root(rootdir); % read the root folder
%                 all_subfolders=sub_folders;
%                 sub3_folders=sub_folders;
% 
%                 %% Critical seesion: recursively read the subfolder until the subfolder list is empty~~~  
%                 while ~isempty(char(sub3_folders))
%                      [all3_folders, sub3_folders]=FG_read_sub(sub3_folders);
%                      all_subfolders=[all_subfolders;all3_folders];
%                 end
% 
% 
%                 % include the root dir % the first dir of the output is always the root dir
%                 all_of_them=[all_folders;all_subfolders];  
%                 full_cell_name=unique(all_of_them);% % find out the unique folders;   full name cell output
%                 full_name_output=char(full_cell_name) ;  % full name array output
% 
%                 L_1st=length(deblank(full_name_output(1,:)));
%                 relative_cell_name=cellfun(@(x) x(1,L_1st+1:end),full_cell_name,'UniformOutput',false);
%                 relative_name_output=full_name_output(:,L_1st+1:end);
% 
%                 fprintf('\n\n--------------------')
% 
% 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 % subfuntion: read root dir
%                 function [all_folders,sub_folders]=FG_read_root(rootdir) 
%                     %  "all_folders" && "sub_folders" are all cell output
%                     %  "all_folders" has the root folder and its subfolders
%                     %  "sub_folders" only has the subfolders under the rootfolder
%                         all_folders=[{rootdir}];
%                         tem=FG_readsubfolders(rootdir);  % add the rootdir into output
% 
%                         fprintf('\nSearching...................')
% 
%                         if isempty(char(tem))       
%                             sub_folders={};
%                         elseif ~isempty(char(tem))
%                             sub_folders=FG_path_recover(rootdir,tem);
%                             all_folders=[all_folders;sub_folders];
%                         end
% 
% 
%                 % subfuntion: read subdirs 
%                 function [all2_folders, sub2_folders]=FG_read_sub(sub_folders)
%                     % the input "sub_folders" should be a cell aray
%                     %  "all2_folders" && "sub2_folders" are all cell output
%                     %  "all2_folders" has the root sub_folders and their subfolders
%                     %  "sub2_folders" only has the subfolders of all the root sub_folders
%                         all2_folders=sub_folders;
%                         sub2_folders={};
%                         for i=1:size(sub_folders,1)
%                             % treat each sub_folder as a new root folder
%                             [alldir_tem,subdir_tem]=FG_read_root(deblank(sub_folders{i,:}));  
%                             sub2_folders=[sub2_folders;subdir_tem];
%                             all2_folders=[all2_folders;alldir_tem];
%                         end        
% 
% 
%                 % subfuntion: recover the full path of the subfolders
%                 function fullfolders=FG_path_recover(rootdir,subdirs)
%                     rootdir=deblank(rootdir);
%                     if strcmp(rootdir(end),filesep)     
%                         fullfolders=cellfun(@(x) [rootdir x],subdirs,'UniformOutput',false);
%                     else  % in case of no filesep at the end of the root dir
%                         fullfolders=cellfun(@(x) [rootdir filesep x],subdirs,'UniformOutput',false);
%                     end
% 

    
    
    