function varargout = FG_rmpath_of_specific_tb(tb_name)
% Recursively removes paths of specific toolbox from the MATLAB path
 % e.g. FG_rmpath_of_specific_tb('grocer')
%   See also PATH, ADDPATH, RMPATH, GENPATH, PATHTOOL, SAVEPATH.


varargout = {};
if nargin==0
   d = FG_rootDir('fmri_grocer'); 
else
   d = FG_rootDir(tb_name);     
end

% Recursively remove directories in the MATLAB path
p = textscan(path,'%s','delimiter',pathsep); p = p{1};
i = strncmp(d,p,length(d)); P = p(i); p(i) = [];
if ~nargin && ~isempty(P)
    fprintf('Removed %s paths starting from base path: "%s"\n',spm('ver','',1),d);
elseif ~isempty(P)
    fprintf('Removed paths starting from base path: "%s" from:\n',d);
else
    fprintf('No matching path strings found to remove\n')
end
if numel(P), fprintf('\t%s\n',P{:}); end

% Set the new MATLAB path
p = strcat(p,pathsep);
path(strcat(p{:}));

% Return the cleaned path if requested
if nargout
    varargout{1} = p;
end
