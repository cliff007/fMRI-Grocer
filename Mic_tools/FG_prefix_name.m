function varargout=FG_prefix_name(filename,prefix)
% filename is the filename with the path
% newname is just the filename without path
[pth,name,ext,even]=FG_fileparts(deblank(filename));
newfilename=fullfile(pth,[prefix '_' name ext]);
% movefile(filename,newfilename)

if nargout==1
    varargout={newfilename};
end


