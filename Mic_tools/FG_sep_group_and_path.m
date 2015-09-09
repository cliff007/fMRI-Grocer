%%%% subfunction, separate a folder's name and its path
function [groups_path,groups_name]=FG_sep_group_and_path(indirs)
tem1=[];tem2=[];
    for n_dir=1:size(indirs,1)
        group=deblank(indirs(n_dir,:));

        % input should be one-row char_array
            if strcmp(group(end),filesep)
                group=group(1:end-1);
            end  % delete the final "filesep"

         %% use [ispc��isunix��ismac] to judge [windows��unix/linux��mac] OS
          if ispc   % when it is PC, ther is not a "filesep" at the begining of the path
            if isempty(regexp(group,filesep, 'once'))  % to deal with the root folder of the system, e.g. f:/, e:/
               group_path=[group filesep];  % in this situation, path has a filesep
               group_name=group;            % in this situation, path has no filesep
            end
          elseif isunix  % when it is Unix, ther is a "filesep" at the begining of the path
             if length(regexp(group,filesep))==1  % to deal with the root folder of the system, e.g. /jet/
               group_path=[group filesep];  % in this situation, path has a filesep
               group_name=group;            % in this situation, path has no filesep
            end     
          end

          % common situation
          if ~exist('group_name')  % when this variable exist,this is a special situation
               i=size(group,2); 
               success=0;
               for j=i:-1:1
                   if group(j)==filesep
                       success=1;
                       break
                   end
               end
               if success==1
                   group_name=group(j+1:end);
                   group_path=group(1:j);
               end
          end
          
          if n_dir==1
              tem1=group_name;
              tem2=group_path;
          else
              tem1=strvcat(tem1,group_name);
              tem2=strvcat(tem2,group_path);             
          end
          clear group_name group_path
    end
    
    groups_name=tem1;
    groups_path=tem2;
    