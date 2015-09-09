function [varargout]=FG_module_select_root(def_indication,CD_or_not)
% select a root dir
if nargin==0
  def_indication='Select the root folder of fMRI_stduy';  
  CD_or_not='Y';  
elseif nargin==1
  CD_or_not='Y';  
end

root_dir = spm_select(1,'dir',def_indication, [],pwd);
if FG_check_ifempty_return(root_dir), root_dir='return'; varargout={root_dir}; return; end

if strcmp(CD_or_not,'Y')
    cd (root_dir)
end

if nargout==1
  varargout={root_dir};  
end