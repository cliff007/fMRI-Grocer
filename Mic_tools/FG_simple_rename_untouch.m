function varargout=FG_simple_rename_untouch(filename,newname,new_folder_subfix)
% filename is the filename with the path
% newname is just the filename without path
[pth,name,ext,even]=FG_fileparts(deblank(filename));
[pth,name,ext,even]=FG_fileparts(deblank(filename));
if ~exist('new_folder_subfix','var')
    newfilename=fullfile(pth,newname);
elseif exist('new_folder_subfix','var')
    newfilename=fullfile([pth new_folder_subfix],newname);
    if ~exist([pth new_folder_subfix],'dir')
        mkdir ([pth new_folder_subfix]);
    end
end
% movefile(filename,newfilename)

if nargout==1
    varargout={newfilename};
end


