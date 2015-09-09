function varargout=FG_rename_selected_files_to_specified_names(files,newnames)
% both of files and newnames should be character matrix
if nargin==0
    files = spm_select(inf,'any','Select the files you want to rename ...');
    if isempty(files), return,end
    newname_file=spm_select(1,'any','Select the txt file written with new names(including the extensions) ...',[],pwd,'.*txt$');
    if isempty(newname_file), return,end
    newnames=FG_read_txt_row_by_row(newname_file);
end

if isempty(files), return,end
if isempty(newnames), return,end

if size(files,1) ~= size(newnames,1)
    fprintf('\n----No. of file names mismatch the No. of new names..........\n')
    return
end

for i=1:size(files,1)
   FG_simple_rename(deblank(files(i,:)),deblank(newnames(i,:))) ;   
end

if nargout==1
    varargout={newnames};
end

fprintf('\n.......Renaming is done...\n')