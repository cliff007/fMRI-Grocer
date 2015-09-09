function p = FG_genpath(d)
%GENPATH Generate recursive toolbox path.
%   P = GENPATH returns a new path string by adding all the subdirectories 
%   of MATLABROOT/toolbox, including empty subdirectories. 
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively, 
%   all the subdirectories of D, including empty subdirectories.
%   
%   NOTE 1: GENPATH will not exactly recreate the original MATLAB path.
%
%   NOTE 2: GENPATH only includes subdirectories allowed on the MATLAB
%   path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.13.4.5 $ $Date: 2008/06/24 17:12:06 $
%   cliff revised
%------------------------------------------------------------------------------

if nargin==0,
  p = FG_genpath(pwd);  % cliff
  if length(p) > 1, p(:,end) = []; end % Remove trailing pathsep
  return
end

% initialise variables
% classsep = '-';  % qualifier for overloaded class directories
% packagesep = '+';  % qualifier for overloaded package directories
p = '';           % path to be returned

% Generate path based on given root directory
d=deblank(d);
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it is empty.
if strcmp(d(1,end),filesep),  
    d=d(1,1:end-1); 
end  % make sure their is not a filesep at the end of the output

p = [p d]; % cliff:  p = [p d pathsep]; 

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')          && ...
         ~strcmp( dirname,'..')   % && ~strncmp( dirname,classsep,1) &&  ~strncmp( dirname,packagesep,1)    &&  ~strcmp( dirname,'private')   % cliff
      p = strvcat(p, FG_genpath(fullfile(d,dirname))); % recursive calling of this function. % cliff
   end
end

% % cliff, sort the pathes by their path length
% p=FG_sort_vector_elements_by_length(p);


%------------------------------------------------------------------------------
