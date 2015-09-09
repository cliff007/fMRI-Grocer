function [path, fname, extension,version] = fileparts(name)
%FILEPARTS Filename parts.
%   [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(FILE) returns the path, 
%   filename, extension and version for the specified file. 
%   FILEPARTS is platform dependent.
%
%   You can reconstruct the file from the parts using
%      fullfile(pathstr,[name ext versn])
%   
%   See also FULLFILE, PATHSEP, FILESEP.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.18.4.7 $ $Date: 2007/12/06 13:29:58 $

% Nothing but a row vector should be operated on.
if ~ischar(name) || size(name, 1) > 1
    error('MATLAB:fileparts:MustBeChar', 'Input must be a row vector of characters.');
end

path = '';
fname = '';
extension = '';
version = '';

if isempty(name)
    return;
end

if strncmp(name, xlate('built-in'), size(xlate('built-in'),2))
    fname = xlate('built-in');
    return;
end

if ispc
    orig_name = name;

    % Convert all / to \ on PC
    name = strrep(name,'/','\');
    ind = find(name == filesep | name == ':');
    if isempty(ind)
        fname = name;
    else
        %special case for drive
        if name(ind(end)) == ':'
            path = orig_name(1:ind(end));
        elseif isequal(ind,[1 2]) ...
                && name(ind(1)) == filesep && name(ind(2)) == filesep
            %special case for UNC server
            path =  orig_name;
            ind(end) = length(orig_name);
        else 
            path = orig_name(1:ind(end)-1);
        end
        if ~isempty(path) && path(end)==':' && ...
                (length(path)>2 || (length(name) >=3 && name(3) == '\'))
                %don't append to D: like which is volume path on windows
            path = [path '\'];
        elseif isempty(deblank(path))
            path = filesep;
        end
        fname = name(ind(end)+1:end);
    end
else    % UNIX
    ind = find(name == filesep);
    if isempty(ind)
        fname = name;
    else
        path = name(1:ind(end)-1); 

        % Do not forget to add filesep when in the root filesystem
        if isempty(deblank(path))
            path = filesep;
        end
        fname = name(ind(end)+1:end);
    end
end

if isempty(fname)
    return;
end

% Look for EXTENSION part
ind = find(fname == '.', 1, 'last');

if isempty(ind)
    return;
else
    extension = fname(ind:end);
    fname(ind:end) = [];
end
