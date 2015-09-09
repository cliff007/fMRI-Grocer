function [varargout]=FG_module_select_groups(def_indication)
% select n-group sub-folders
if nargin==0
  def_indication='Select all the groups under the root folder of fMRI_stduy';  
end


all_groups = spm_select(inf,'dir',def_indication, [],pwd);
if FG_check_ifempty_return(all_groups),groups='return';all_groups='return';varargout={groups,all_groups}; return; end

groups=FG_get_groupfolder_names(all_groups);    


if nargout==1
    varargout(1)={groups};  
elseif nargout==2
    varargout(1)={groups}; 
    varargout(2)={all_groups}; 
end