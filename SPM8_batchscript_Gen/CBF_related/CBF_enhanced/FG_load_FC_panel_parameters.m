function FC_Paras=FG_load_FC_panel_parameters(para_file)
%% FG_load_ASL_parameters('ASL_paras.mat')
    if ~exist('para_file','var')
        para_file= spm_select(1,'.mat','Select a ASL-CBF calculation parameter file (ASL_paras.mat) to load','',pwd,'FC_Paras.mat');  
    end
load(para_file);
clear para_file
% tem=fieldnames(FC_Paras);
FC_Paras;
% for i=1:size(tem,1)
%     assignin('caller',tem{i},eval(['FC_Paras.' tem{i} ';']));
% end
fprintf('')
