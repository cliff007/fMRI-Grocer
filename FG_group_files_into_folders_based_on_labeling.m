function FG_group_files_into_folders_based_on_labeling
% this script is used to group files under different groups (e.g. different
% 1st-level conditions) intto different groups with file identifiers (e.g. subject number)

pth=FG_rootDir('FG_file_group_labels.m');
ID_file = spm_select(1,'.m','Select the file identifier .m file:', [],pth,'^FG_file_group_labels*.*m');
addpath(FG_sep_group_and_path(ID_file));

if strcmp(ID_file,'')
   fprintf('\n---None a identifier file has been selected...\n')
   return               
else
   [a,b,c,d]=fileparts(ID_file);
   eval(['FG_groups=' b]);
end

files = spm_select(length(FG_groups.labels),'any',['Select ' num2str(length(FG_groups.labels)) ' files (Run this twice to deal with hdr/img files separately)'], [],pwd,'.*img');
if isempty(files), return; end
          
% if length(FG_groups.FG_labels)~=size(files,1)
%     fprintf('\n----The number of selected files is different from labels!\n\n')  
%     return
% end

root_dir = FG_module_select_root('Select a root folder to hold the ouputs');
if any(strcmpi('return',{root_dir})), return; end

FG_groups.labels
FG_groups.unique_labels
FG_groups.label_names
for i=1:size(FG_groups.label_names)
   mkdir(fullfile(root_dir,FG_groups.label_names{i})) 
end

FG_groups.unique_labels(find(FG_groups.unique_labels==0))=[]; % remove the 0 label that don't need to be cared!

for j=1:size(FG_groups.label_names)
    tem=find(FG_groups.labels==(FG_groups.unique_labels(j)));
    for i=1:size(tem)
        movefile (deblank(files(tem(i),:)),fullfile(root_dir,FG_groups.label_names{j}));
    end
end


fprintf('\n----File grouping is done!\n\n')  
    
    