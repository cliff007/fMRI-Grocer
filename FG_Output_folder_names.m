
function [Out_group_name,Out_subj_name]=FG_Output_folder_names
clear Out_group_name Out_subj_name

% After you setting up this file, [save] it,
% and then select the file you saved in the next step.


%%% set up the Out_group_name in a column as below


% for your convinence sake, you'd better subfix some special characters to
% the output groups name. such as '_FG' here. This would make you to move
% all these folders eaisily in the next step.

% the size of this column must be exact the same as the groups you select
% during setuping

Out_group_name={
%'pcasl_FG'
'BOLD_rest'
'pcasl_rest1'
'pcasl_PVT'
'pcasl_rest2'
'BOLD_BART'
};


%             %%% set up the Out_subj_name in a column as below
% 
%             % the size of this column needn't to be exact the same as the group you select during the setup
%             % Only you have more subjects than the number of subjs list here, you need to add some more to this column
%             % Otherwise, it doesn't matter when the column size is bigger than your subject number
% 
% 
%             Out_subj_name={
%             'Sub01'
%             'Sub02'
%             'Sub03'
%             'Sub04'
%             'Sub05'
%             'Sub06'
%             'Sub07'
%             'Sub08'
%             'Sub09'
%             'Sub10'
%             'Sub11'
%             'Sub12'
%             'Sub13'
%             'Sub14'
%             'Sub15'
%             'Sub16'
%             'Sub17'
%             'Sub18'
%             'Sub19'
%             'Sub20'
%             'Sub21'
%             'Sub22'
%             'Sub23'
%             'Sub24'
%             'Sub25'
%             'Sub26'
%             'Sub27'
%             'Sub28'
%             'Sub29'
%             'Sub30'
%             'Sub31'
%             'Sub32'
%             'Sub33'
%             'Sub34'
%             'Sub35'
%             'Sub36'
%             'Sub37'
%             'Sub38'
%             'Sub39'
%             'Sub40'
%             };

fprintf('\n---------Output-functional-group-names is set!\n\n')
