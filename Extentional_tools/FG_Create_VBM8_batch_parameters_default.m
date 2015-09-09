%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%% Read Me %%%%%
     % You can adjust the parameter setting below and then "Run" this script
     % Then you will get a 'VBM8_bathc_paras.mat' under the selected folder
     % Which can be imported into the VBM8 batch function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FG_Create_VBM8_batch_parameters_default
clear

%%%%%%%%%%%% Setup the important Estimation options
Affine_regulation='mni'; % ''/'mni'/'eastern'/'subj'/'none'

%%%%%%%%%%%% Setup the important Writing options 
    %%%%% native space output
native_gray='0';   % 0/1
native_white='0';
native_csf='0';
    %%%%% normalized space output
normalized_gray='1';  % 0/1 
normalized_white='1';
normalized_csf='0';
    %%%%% Modulated normalized space output
Modulated_Normalized_gray='2';  % 0/1/2
Modulated_Normalized_white='2';
Modulated_Normalized_csf='0';
    %%%%% Dartel Export output  
DartelExport_gray='0';  % 0/1 
DartelExport_white='0';
DartelExport_csf='0';
    %%%%% PVE label native and normalized output & PVE label Dartel export output 
PVELabel_native_space_val='0';  % 0/1 
PVELabel_normalized_space_val='1';
PVELabel_DartelExport_format='0';
    %%%%% Jacobian image output 
Jacobian_val='1';  % 0/1 



%%%%%%%%%%%% Save all the parameters into .mat file
VBM_para_rootdir =  spm_select(1,'dir','Select all a dir to save the parameter.mat file');
save (FG_check_and_rename_existed_file(fullfile(VBM_para_rootdir,'VBM8_bathc_paras.mat')))

