function [all_subdirs_pth,all_subdirs]=FG_list_one_level_folders(rootdir,filter1)
% be careful: this script will ignore all the folders that doesn't contain
% files or specific files
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the root folder you want to lists directories', [],pwd);
    filter1 ='*';
end

all_subdirs=[];
all_subdirs_pth=[];
all=dir(fullfile(rootdir,filter1));
for i=3:size(all,1)
   if all(i).isdir
       all_subdirs=strvcat(all_subdirs,all(i).name);
       all_subdirs_pth=strvcat(all_subdirs_pth,fullfile(rootdir,all(i).name));
   end
end

fprintf('\n\n-----------listing done.............\n\n')