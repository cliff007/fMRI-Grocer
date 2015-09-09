function [varargout]=FG_check_ifempty_return(varargin)
% the original purpose of this function failed
% now it is just an enhanced "isempty" 
% it can be just used to examine a array and a cell array
out_val=[];
for i=1:nargin
    a_var=varargin{i};
    if iscell(a_var)
       a_var=char(a_var) ;
    end
    
    if isempty(a_var)
        fprintf('\n\n ----Warning: An expected variable: ''%s''  is empty!\n',inputname(i)); %% Caution: inputname  ~= FG_getVarName
        out_val=[out_val;1]; % means empty
    else
        out_val=[out_val;0]; % means not empty 
    end    
    
end

    varargout= {out_val};  % varargout must be a cell





