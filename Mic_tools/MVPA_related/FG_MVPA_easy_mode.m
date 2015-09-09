function FG_MVPA_easy_mode(imgs,mask,regressors,selectors)

% First of all, Check to make sure the Neuralnetwork toolbox is in the path or this won't work.

if ~exist('newff') %#ok<EXIST> cliff: used in function [cross_validation]
    error('This tutorial requires the neural networking toolbox, if it is unavailable this will not execute');
end


%% Prepare inputs
if nargin==0   
  
   %% patterns, i.e. the images of the entire scan trail
   %% the matrix should be  [ nmasked-Voxels x nTRs]
   imgs =  spm_select(inf,'.img|.nii','Select all the imgs making the pattern', [],pwd,'^haxby8.*');
  
   %% whole brain mask
   %% the matrix should be  [ X  x  Y  x  Z ]
   mask =  spm_select(1,'.img|.nii','Select a whole brain mask', [],pwd,'^mask.*');
  
end


% MVPA data preparation
%%%% refer to http://code.google.com/p/princeton-mvpa-toolbox/wiki/TutorialIntro

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULTS
% Before we get started we need to setup a single default.
[pathstr, name, ext, versn] = fileparts(imgs(1,:)); % choose one for all
clear pathstr name versn
defaults.fextension = ext; %   '.nii'   or    '.img'

args = propval({},defaults);

if (isfield(args,'fextension'))
    fextension=args.fextension;
else
    fextension=defaults.fextension;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZING THE SUBJ STRUCTURE

% start by creating an empty subj structure
subj = init_subj('MVPA_cliff','Subj_cliff');
summarize(subj);

%%% create the mask that will be used when loading in the data
subj = load_spm_mask(subj,'wholebrain_mask',mask);
summarize(subj);

% now, read and set up the actual data. load_spm_pattern reads in the
% EPI data from a nifti file, keeping only the voxels active in the
% mask (see above)
cell_imgs=FG_convert_strmat_2_cell_basedon_row(imgs);
subj = load_spm_pattern(subj,'epi','wholebrain_mask',cell_imgs);
summarize(subj);

mask_size=get_objfield(subj,'mask','wholebrain_mask','matsize');
epi_size=get_objfield(subj,'pattern','epi','matsize');
nTRs=epi_size(1,2);


%% load the condition labels that used to identify each volume's condition
%% the matrix should be [nConditions x nTRs], called [regressors] or [conditons]
%%%%%%% 1. load the condition names
    h=questdlg('Do you have a [condition_names.txt] file?','Hi....','Yes','No','Yes') ;
    if strcmp('No',h)        
        dlg_prompt={'How many conditions do you have in your data(at least 2):'};
        dlg_name='Conditions number...';
        dlg_def={'2'};
        conds_num=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on'); 
        conds_num=str2num(conds_num{1});
        if exist('conds_num','var') && conds_num>=2
          
            dlg_prompt1={};
            dlg_prompt2={};     
            for i=1:conds_num
                dlg_prompt1=[dlg_prompt1,['Condition_name ',num2str(i),'----------------------------------']];
                dlg_prompt2=[dlg_prompt2,['condition_',num2str(i)]];
            end

            dlg_name='Condition names setting...';
            cond_names=inputdlg(dlg_prompt1,dlg_name,1,dlg_prompt2,'on');  %%  [conds] is a cell      
        else
            return  
        end
        
    elseif strcmp('Yes',h)  
        conds_file = spm_select(1,'.txt','Select a condition/regressor name file', [],pwd,'.*');
        cond_names=FG_read_txt_one_column_conditions(conds_file);  %%  [conds] is a cell        
    end
    
    nConditions=size(cond_names,1);
    
%%%%%%% 2. load the condition labels    
%             h=questdlg('Do you have a [condition_label.mat] file?','Hi....','Yes','No','Yes') ;
%             if strcmp('No',h)        
%                 dlg_prompt={['Pleae enter a ' num2str(nConditions) '(nConditions) x ' num2str(nTRs) '(nTRs) matrix to label the conditions among the images:']};
%                 dlg_name='Condition labels setting...';
%                 dlg_def={'2'};
%                 cond_labels=inputdlg(dlg_prompt,dlg_name,5,dlg_def,'on');        
%             elseif strcmp('Yes',h)  
%                 conds_file = spm_select(1,'.mat','Select a condition/regressor label file', [],pwd,'.*');
%                 cond_labels=load(conds_file);  %%  [conds] is a cell        
%             end
    conds_file = spm_select(1,'.mat',['Select a ' num2str(nConditions) '(nConditions) x ' num2str(nTRs) '(nTRs) matrix condition/regressor label file'], [],pwd,'.*');
    cond_labels=load(conds_file);  %%  [conds] is a cell       %% tutorial_regs.mat
    con_field=fieldnames(cond_labels);
    if size(con_field,1)~=1
        return
    else
        regressors=eval(['cond_labels.' con_field{1}]);
    end
    
% initialize the regressors object in the subj structure, load in the
% contents from a file, set the contents into the object and add a
% cell array of condnames to the object for future reference
% Finally store the names of the regressor conditions
subj = init_object(subj,'regressors','conds');
%         load('tutorial_regs');
subj = set_mat(subj,'regressors','conds',regressors);
%     condnames = {'face','house','cat','bottle','scissors','shoe','chair','scramble'};
subj = set_objfield(subj,'regressors','conds','condnames',cond_names); 



  
%% the lables used to separate trainning and testing files
%% the matrix should be [nConditions x nTRs]
    selector_file =  spm_select(1,'.mat',['Select a ' num2str(nConditions) '(nConditions) x ' num2str(nTRs) '(nTRs) Row-vector Run-selector file'], [],pwd,'.*');
    select_tem=load(selector_file);  %%  [conds] is a cell    %% tutorial_runs.mat
    selector_field=fieldnames(select_tem);
    if size(selector_field,1)~=1
        return
    else
        run_selectors=eval(['select_tem.' selector_field{1}]);
    end


% initialize the selectors object, then read in the contents
% for it from a file, and set them into the object
subj = init_object(subj,'selector','runs');
%         load('tutorial_runs');
subj = set_mat(subj,'selector','runs',run_selectors);

summarize(subj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-PROCESSING - z-scoring in time and no-peeking anova

% we want to z-score the EPI data (called 'epi'),
% individually on each run (using the 'runs' selectors)
subj = zscore_runs(subj,'epi','runs');
summarize(subj,'objtype','pattern') ;

% now, create selector indices for the n different iterations of the
% n-minus-one cross validation
subj = create_xvalid_indices(subj,'runs');
summarize(subj)

% run the anova multiple times, separately for each iteration, using the selector indices created above
%%% Pattern statmap group: 'epi_z_anova'   and 
%%%            mask group: 'epi_z_thresh0.05' will be created by feature_select
subj = feature_select(subj,'epi_z','conds','runs_xval');
summarize(subj)
summarize(subj,'objtype','mask')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLASSIFICATION - n-minus-one cross-validation

% choose a backprop classifier and then
% set some basic arguments for a backprop classifier with no hidden layer
class_args.train_funct_name = 'train_bp';
class_args.test_funct_name = 'test_bp';
class_args.nHidden = 0;


%% Now, time for MVPA
% now, run the classification multiple times, training and testing
% on different subsets of the data on each iteration
[subj results] = cross_validation(subj,'epi_z','conds','runs_xval','epi_z_thresh0.05',class_args);
assignin('base','results',results)
assignin('base','subj',subj)

results.iterations(1)
results.iterations(1).perfmet  %% 'perfmet'' ('performance metric')


fprintf('\n===== done ====\n')








%%%%%%%%% cliff: subfunctin

function conds=FG_read_txt_one_column_conditions(conds_file)

        reading_format=['%s' '%*[^\n]'];  
        fid = fopen(conds_file, 'r'); % reopen the file to read the file from the beginning
        try
            conds = textscan(fid, reading_format);
        catch me
           me.message
           fprintf('\n ******* Make Sure your condtion names are stored in one column in the txt file........\n')
           return
        end
        conds=conds{1}; %%  [conds] is a cell
        
  