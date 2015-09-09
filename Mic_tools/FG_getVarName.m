function name=FG_getVarName(x)  
    % use "inputname to get the variable name"  
    name=inputname(1);  
end  

% more simple one£º 
  % define a function handle
    % vname=@(x) inputname(1);
  % then
    % toto=pi
    % s=vname(toto)
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/251347  