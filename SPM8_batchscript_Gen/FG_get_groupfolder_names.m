function [varargout]=FG_get_groupfolder_names(all_groups)
%% input must be a char array.
    clc
    if nargin==0
        all_groups = spm_select(inf,'dir','Select a group of folders', [],pwd);
        if isempty(all_groups)
            fprintf('\n.........Error:Please select a group of folders!\n') 
            return
        end
    end

    all_path={};
    all_name={};
 %   groups=spm_str_manip(all_groups,'dhc');  % take use of the "spm_str_manip" function
 for i=1:size(all_groups,1)
    [pth,g_name]=FG_sep_group_and_path(deblank(all_groups(i,:)));
    all_path=[all_path;{pth}];
    all_name=[all_name;{g_name}];
 end

 if nargout==1 || nargout==0
     varargout={char(all_name)};
 elseif nargout==2
     varargout(1)={char(all_name)};   % array names   
     varargout(2)={char(all_path)};   % array path  
 elseif nargout==3
     varargout(1)={char(all_name)};     
     varargout(2)={char(all_path)};       
     varargout(3)={all_name};  
 elseif nargout==4
     varargout(1)={char(all_name)};   % array names   
     varargout(2)={char(all_path)};   % array path   
     varargout(3)={all_name};  % cell name   
     varargout(4)={all_path};  % cell path         
 end
    
