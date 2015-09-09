
function [FG_groups]=FG_file_group_identifier
clear FG_groups


% usually we assume only two groups to be separate.
% if you have more than two groups, you can extend this script to as many
% groups as you want with the same setting requirement here (such as the noted scripts below the vaild rows below). 

% And the extention can be recognized by the next grouping script



% The length of each column can be different

% After you setting up this file, [save] it,
% and then select the file you saved in the next step.


%%% set up the FG_group1 in a column as below



FG_group1={
'sub02'
'sub03'
'sub06'
'sub08'
'sub09'
'sub16'
'sub17'
'sub19'
'sub20'
'sub21'
'sub22'
'sub24'
'sub25'
'sub28'
'sub30'
};


%%% set up the FG_group2 in a column as below


FG_group2={
'sub01'
'sub04'
'sub05'
'sub07'
'sub10'
'sub11'
'sub12'
'sub13'
'sub14'
'sub15'
'sub18'
'sub23'
'sub26'
'sub27'
'sub29'
};

FG_groups=[{FG_group1},{FG_group2}];



% 
% 
% 
% FG_group1={
% 'PVT_scan1'
% };
% 
% FG_group2={
% 'PVT_scan2'
% };
% 
% 
% FG_group3={
% 'PVT_scan3'
% };
% 
% FG_group4={
% 'rest1_scan1'
% };
% 
% FG_group5={
% 'rest1_scan2'
% };
% 
% FG_group6={
% 'rest1_scan3'
% };
% 
% FG_group7={
% 'rest2_scan1'
% };
% 
% FG_group8={
% 'rest2_scan2'
% };
% 
% 
% FG_group9={
% 'rest2_scan3'
% };
% 
% 
% FG_group10={
% 'IGT_scan1'
% };
% 
% 
% FG_group11={
% 'IGT_scan2'
% };
% 
% 
% FG_group12={
% 'IGT_scan3'
% };
% 
% 
% FG_group13={
% 'visual_scan1'
% };
% 
% 
% FG_group14={
% 'visual_scan2'
% };
% 
% 
% FG_group15={
% 'visual_scan3'
% };
% 
% FG_groups=[{FG_group1},{FG_group2},{FG_group3},{FG_group4},{FG_group5},{FG_group6},{FG_group7},{FG_group8},{FG_group9},{FG_group10},{FG_group11},{FG_group12},{FG_group13},{FG_group14},{FG_group15}];
% 
% 











fprintf('\n---Group indentifiers for files are all set!\n\n')
