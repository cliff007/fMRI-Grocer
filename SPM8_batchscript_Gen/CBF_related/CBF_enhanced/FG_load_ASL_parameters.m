function FG_load_ASL_parameters(para_file)
%% FG_load_ASL_parameters('ASL_paras.mat')
    if ~exist('para_file','var')
        para_file= spm_select(1,'.mat','Select a ASL-CBF calculation parameter file (ASL_paras.mat) to load','',pwd,'ASL_paras.mat');  
    end
load(para_file);
clear para_file
tem=fieldnames(ASL_paras);
for i=1:size(tem,1)
    assignin('caller',tem{i},eval(['ASL_paras.' tem{i} ';']));
    eval([tem{i} '=ASL_paras.' tem{i} ';']);
end
fprintf('\n---------------Parameters of ASL-CBF calculation have been loaded!\n')

   
%     vars_in={ 
%             'SelfmaskedorNo' ...
%         'Filename' ...
%         'self_maskimg' ...
%             'FieldStrength' ...
%             'ASLType' ...
%             'FirstimageType' ...
%             'SubtractionType' ...
%             'SubtractionOrder' ...                        
%             'Labeltime' ...
%             'Delaytime' ...
%             'Slicetime' ...            
%         'PASLMo','Timeshift', 'threshold','alp'           
%             };  % the last four variables are optional
%         
%      if any(~cellfun(@(x) exist(x,'var'),vars_in)), % if any vars_in is existed:  ANY: True if any element of a vector is a nonzero number
%          fprintf('\nNot enough critical inputs! Please check it out!\n'),
%          return;
%      end    
%      
%      if any(cellfun(@isempty,vars_in(1,4:11))), % if any critical vars_in is empty:  ANY: True if any element of a vector is a nonzero number
%          fprintf('\nSome of the critical input variables (e.g. the first 12 vars) that needs to be predefined is empty! Please check it out!\n'),
%          return;
%      end 