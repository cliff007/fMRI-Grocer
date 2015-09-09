
function [search_strs,replace_strs]=FG_example_search_and_replace_str()
clear search_strs replace_strs

% After you setting up this file, [save OR save as..] it,
% and then select the file you saved in the next step.

%%% set up the search strs in a column as below, Use "\" to deal with the special characters)
search_strs={
'1ststr'
'2ndstr'
'3rdstr'
}';

%%% set up the replace strs in a column as below, Use "\" to deal with the special characters
replace_strs={
'replace str1'
'replace str2'
'replace str3'
}';

fprintf('\nStrings are all set!\n\n')
