
function [FG_groups]=FG_file_group_labels
clear FG_groups

% just provide the labels (different numbers) for the files you will select
% 0 means the file you don't want to deal with, any other positive number
% are used as different label

% After you setting up this file, [save] it,
% and then select the file you saved in the next step.

%%% set up the FG_labels in a column as below
    %%%% Be careful: 
    %%%% 0 means the file you don't want to deal with,
    %%%% only the positive numbers are used as labels
%%%

%%%%%%%%%%%%%%%  edit area start!     %%%%%%%%%%%%%%%%%%%%%%%%%
    FG_labels=[
    1
    2
    1
    0
    3
    2
    0
    3
    2
    ];

%% the names will be corresponding to the label-order acquired in
%% "unique_unsorted" below (line 48)
    FG_label_names={
    'group1'
    'group2'
    'group3'
    };

%%%%%%%%%%%%%%%  edit area end!     %%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% generate label-names automatically
[unique_unsorted,unique_unsorted_occurances]=FG_unique_number(FG_labels);
if isempty(find(unique_unsorted==0))  % check 0
    n_left=0; 
    n_file_left=0;
else
    n_file_left=unique_unsorted_occurances(find(unique_unsorted==0)) ; 
    n_left=1; 
end

n_labeled=length(unique_unsorted) - n_left;
if size(FG_label_names,1)~=n_labeled   
  fprintf('\n----The number of groups is different from labels!\n\n')  
  return
end

YoN=questdlg(['You have ' num2str(n_labeled) ' labels while '  num2str(n_file_left) ' files were left without being dealed with.Totally ' num2str(length(FG_labels)) ' files!'],'Is this right?','Yes','No','Yes');
if strcmp(YoN,'No')
    display('--- canceled ---')
    return
end

FG_label_unique=unique_unsorted;
FG_groups.labels=FG_labels;
FG_groups.unique_labels=FG_label_unique;
FG_groups.label_names=FG_label_names;


fprintf('\n---Group indentifiers for files are all set!\n\n')
