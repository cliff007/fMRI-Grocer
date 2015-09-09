function varargout=FG_subfix_name(filename,subfix)
% filename is the filename with the path
% newname is just the filename without path
[pth,name,ext,even]=FG_fileparts(deblank(filename));
newfilename=fullfile(pth,[name '_' subfix  ext]);
% movefile(filename,newfilename)

if nargout==1
    varargout={newfilename};
end
