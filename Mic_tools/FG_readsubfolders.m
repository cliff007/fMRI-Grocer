%%%%%%%%%%%%%%%%%%%%%
function [varargout]=FG_readsubfolders(path,filter)
    % readsubfolders: read all the subdirs under the rootpath
    %    'path' is the rootpath you want to access, this must be some characters (string)
clc
if nargin==0
    rootdir = spm_select(1,'dir','Select the folder you want to list all his first-level sub-directories', [],pwd);
    if isempty(rootdir)
        fprintf('\n.........Error:Please select a vaild folder!\n') 
        return
    end
    path=rootdir;
    filter='*';
elseif nargin==1
    filter='*';
end


    full_path=fullfile(path,filter);
    folders={};
    sizes={};
    subfolders = dir(full_path);
    
    subdirs=subfolders([subfolders.isdir]==1);
        
    i=1;
    for p = 1:length(subdirs) 
        folders{i}=subdirs(p).name;
        sizes{i}=subdirs(p).bytes;
        i=i+1;
    end
    
 subdir_names=folders';
 subdir_sizes=sizes';
 
 if size(subdir_names,1)>2
     if strcmp(subdir_names{1},'.') && strcmp(subdir_names{2},'..') % fprintf('\n-----------Find "." and ".." and exclud them from the output.............\n')         
         subdir_names=subdir_names(3:end);
         subdir_sizes=subdir_sizes(3:end);
     end
    full_subdir_names=cellfun(@(x) fullfile(path,x), subdir_names,'UniformOutput',false); 
%  elseif size(subdir_names,1)<=2
%      subdir_names=[];  full_subdir_names=[];   subdir_sizes=[];
 end
 
 

 
 if nargout==1 || nargout==0
     varargout(1) = {subdir_names};
 elseif nargout==2
     varargout(1) = {subdir_names};
     varargout(2) = {full_subdir_names};
 elseif nargout==3
     varargout(1) = {subdir_names};
     varargout(2) = {full_subdir_names};    
     varargout(3) = {subdir_sizes};  
 end
 
% fprintf('\n\n-----------list all subdir_names below.............\n\n') 
%%%%%%%%%%%%%%%
