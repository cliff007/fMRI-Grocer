function sesInfo = FG_icatb_runAnalysis(sesInfo, groupICAStep)
%% Run analysis consists of the following options:
% 1. All*** - Run all the steps involved in group ICA
% 2. Initialize Parameters - Parameters are intialized after the setup
% ICA analysis
% 3. Group Data Reduction - fMRI data is reduced using the data reduction
% step
% 4. Calculate ICA - Involves calculating ICA - Several Algorithms are
% available
% 5. Back Reconstruct - Performs back reconstruction step
% 6. Calibrate Components - Calibrates the arbitrary parameters to
% percent signal changes
% 7. Group Stats - Perform stats for a group of subjects. For one subject
% one session stats are not performed.
% 8. Resume - Resumes the interrupted analysis.
%

% Inputs:
% 1. sesInfo - structure containing all parameters for analysis
% 2. groupICAStep - Step no.
%   1 - All***
%   2 - Initialize parameters
%   3 - Data Reduction
%   4 - Calculate ICA
%   5 - Back Reconstruct
%   6 - Calibrate Components
%   7 - Group Stats
%   8 - Resume


try
    % defaults
    icatb_defaults;
    
    %Screen Color Defaults
    global BG_COLOR;
    global FONT_COLOR;
    global AXES_COLOR;
    global PARAMETER_INFO_MAT_FILE;
    global ZIP_IMAGE_FILES;
    global OPEN_DISPLAY_GUI;
    global SPM_STATS_WRITE_TAL;
    global SPM_STATS_AVG_RUNS;
    
    % Return modality type
    modalityType = icatb_get_modality;
    
    if strcmpi(modalityType, 'fmri')
        helpLabel = 'GIFT-Help';
        htmlFile = 'icatb_run_analysis.htm';
    else
        helpLabel = 'EEGIFT-Help';
        htmlFile = 'icatb_eeg_run_analysis.htm';
    end
    
    
    % load parameters file
    filterP = ['*', PARAMETER_INFO_MAT_FILE, '*.mat'];
    
    analysisType = 'batch';
    
    % load valid parameter file
    if ~exist('sesInfo', 'var')
        % show directions about run ica
        [P] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Parameter File', 'filter', filterP);
        if isempty(P)
            error('Parameter file is not selected for analysis');
        end
        [pathstr, file] = fileparts(P);
        outputDir = pathstr; % output directory
        cd(pathstr);
        load(P);
        if ~exist('sesInfo', 'var')
            error('Not a valid parameter file');
        else
            disp('Parameters file succesfully loaded');
        end
        %% output directory
        sesInfo.outputDir = outputDir; % set the output directory
    else
        outputDir = sesInfo.userInput.pwd;
    end
    
    drawnow;
    
    if isfield(sesInfo.userInput, 'modality')
        if ~strcmpi(modalityType, sesInfo.userInput.modality)
            if strcmpi(sesInfo.userInput.modality, 'fmri')
                error('Use GIFT toolbox to run the analysis on MRI data.');
            else
                error('Use EEGIFT toolbox to run the analysis on EEG data.');
            end
        end
    else
        sesInfo.userInput.modality = modalityType;
    end
    
    sesInfo.userInput.pwd = outputDir;
    sesInfo.outputDir = outputDir;
    
    %% Group PCA settings
    perfOptions = icatb_get_analysis_settings;
    perfType = 'user specified settings';
    if (isfield(sesInfo.userInput, 'perfType'))
        perfType = sesInfo.userInput.perfType;
    end
    
    if (isnumeric(perfType))
        perfType = perfOptions{perfType};
    end
    
    perfType = lower(perfType);
    
    
    allSteps = {'all', 'parameter_initialization', 'group_pca', 'calculate_ica', 'back_reconstruct', 'scale_components', 'group_stats', 'resume'};
    
    % choose which steps to preform for group ica
    if ~exist('groupICAStep', 'var')
        
        disp('Opening run analysis GUI. Please wait ...');
        
        run_analysis_settings = icatb_run_analysis_settings(sesInfo);
        
        perfType = run_analysis_settings.perfType;
        stepsToRun = run_analysis_settings.stepsToRun;
        
        analysisType = 'GUI';
        
    else
        
        stepsToRun = groupICAStep;
        
    end
    
    if (~isnumeric(stepsToRun))
        stepsToRun = lower(cellstr(stepsToRun));
        [dd, stepsToRun] = intersect(allSteps, stepsToRun);
    end
    
    stepsToRun = sort(unique(stepsToRun));
    
    if any(stepsToRun == 1)
        stepsToRun = (2:7);
        userInput = sesInfo.userInput;
        outputDir = sesInfo.outputDir;
        sesInfo = [];
        sesInfo.userInput = userInput;
        sesInfo.outputDir = outputDir;
        clear userInput;
    elseif any(stepsToRun == 8)
        [resume_info, sesInfo] = icatb_get_resume_info(sesInfo);
        if (isempty(resume_info))
            return;
        else
            stepsToRun = resume_info.stepsToRun;
            reductionStepNo = resume_info.groupNo;
            dataSetNo = resume_info.dataSetNo;
        end
        clear resume_info;
    end
    
    
    stepsToRun = stepsToRun(:)';
    
    % check the user input
    if (any(stepsToRun == 2))
        if isfield(sesInfo, 'reduction')
            sesInfo = rmfield(sesInfo, 'reduction');
        end
    end
    
    
    sesInfo.modality = sesInfo.userInput.modality;
    
    % performing batch analysis
    output_LogFile = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix, '_results.log']);
    
    % Print output to a file
    diary(output_LogFile);
    
    % Use GUI
    if strcmpi(analysisType, 'gui')
        
        waitbarTag = [sesInfo.userInput.prefix, 'waitbar'];
        waitbarCheckH = findobj('tag', waitbarTag);
        try
            delete(waitbarCheckH);
        catch
        end
        
        % Include a status bar that shows what percentage of analysis is
        % completed
        titleFig = 'System busy. Please wait...'; perCompleted = 0;
        statusHandle = waitbar(perCompleted, titleFig, 'name', [num2str(perCompleted*100), '% analysis done'], ...
            'DefaultTextColor', FONT_COLOR, 'DefaultAxesColor', AXES_COLOR, 'color', BG_COLOR, 'tag', waitbarTag);
        
        appDataName = 'gica_waitbar_app_data';
        if (isappdata(statusHandle, appDataName))
            rmappdata(statusHandle, appDataName);
        end
        
        % Number of calls per function where most of the time is spent in
        % analysis
        numberOfCalls_function = 3;
        
        unitPerCompleted = 1/(length(stepsToRun)*numberOfCalls_function);
        
        
        statusData.unitPerCompleted = unitPerCompleted;
        statusData.perCompleted = 0;
        
        setappdata(statusHandle, appDataName, statusData);
        
    else
        statusHandle = [];
        disp('Starting Analysis ');
        fprintf('\n');
    end
    
    
    sesInfo.userInput.perfType = perfType;
    
    % Use tic and toc instead of cputime
    tic;
    
    
    subjectFile = fullfile(sesInfo.outputDir, [sesInfo.userInput.prefix, 'Subject.mat']);
    
    if (~exist(subjectFile, 'file'))
        files = sesInfo.userInput.files;
        numOfSub = sesInfo.userInput.numOfSub;
        numOfSess = sesInfo.userInput.numOfSess;
        SPMFiles = sesInfo.userInput.designMatrix;
        icatb_save(subjectFile, 'files', 'numOfSub', 'numOfSess', 'SPMFiles', 'modalityType');
        clear files SPMFiles numOfSub numOfSess;
    end
    
    
    
    countStep = 0;
    for groupICAStep = stepsToRun
        
        countStep = countStep + 1;
        
        % parameter initialization
        if(groupICAStep == 1 || groupICAStep == 2)
            sesInfo = icatb_parameterInitialization(sesInfo, statusHandle);
        end
        
        if ((countStep == 1) && exist('dataSetNo', 'var'))
            sesInfo.dataSetNo = dataSetNo;
        end
        
        % Data reduction
        if(groupICAStep == 1 || groupICAStep == 3)                        
            
            if (exist('reductionStepNo', 'var'))
                reductionStepsToRun = (1:sesInfo.numReductionSteps);
                reductionStepsToRun(reductionStepsToRun < reductionStepNo) = [];
                sesInfo.reductionStepsToRun = reductionStepsToRun;
            end
            
            if ((strcmpi(perfType, 'maximize performance')) || (strcmpi(perfType, 'less memory usage')))
                
                % Get performance settings
                [max_mem, pcaType, pcaOpts] = icatb_get_analysis_settings(sesInfo, perfType);
                
                gpca_opts = cell(1, sesInfo.numReductionSteps);
                gpca_opts{1} = struct('pcaType', 'standard', 'pca_opts', icatb_pca_options('standard'));
                
                if (sesInfo.numReductionSteps > 1)
                    gpca_opts(2:sesInfo.numReductionSteps) = repmat({struct('pcaType', pcaType, 'pca_opts', pcaOpts)}, 1, sesInfo.numReductionSteps - 1);
                end
                
                sesInfo.pca_opts = gpca_opts;
                
            end
            
            sesInfo = icatb_dataReduction(sesInfo, statusHandle);
            
        end
        
        % Calculate ICA
        if(groupICAStep == 1 || groupICAStep == 4)
            sesInfo = icatb_calculateICA(sesInfo, statusHandle);
        end
        
        % Back Reconstruction
        if(groupICAStep == 1 || groupICAStep == 5)
            sesInfo = icatb_backReconstruct(sesInfo, statusHandle);
        end
        
        % Calibrate Components
        if(groupICAStep == 1 || groupICAStep == 6)
            sesInfo = icatb_calibrateComponents(sesInfo, statusHandle);
        end
        
        % Group Stats
        if(groupICAStep == 1 || groupICAStep == 7)
            sesInfo = icatb_groupStats(sesInfo, statusHandle);
        end
        
    end
    
    if strcmpi(analysisType, 'gui')
        % Analysis is complete
        waitbar(1, statusHandle, 'Analysis Complete.');
        close(statusHandle);
    end
    
    
    % Use tic and toc instead of cputime
    t_end = toc;
    
    % Suspend diary
    diary('off');
    
    disp(['Time taken to run the analysis is ', num2str(t_end), ' seconds']);
    
    fprintf('\n');
    
    disp(['All the analysis information is stored in the file ', output_LogFile]);
    
    disp('Finished with Analysis');
    fprintf('\n');
    
    % save the parameter file
    parameter_file = fullfile(sesInfo.outputDir, [sesInfo.param_file, '.mat']);
    icatb_save(parameter_file, 'sesInfo');
    
    
    doSPMStats = 0;
    
    if (strcmpi(modalityType, 'fmri'))
        if (sesInfo.numOfSub > 1)
            doSPMStats = 1;
        elseif ((sesInfo.numOfSub == 1) && (sesInfo.numOfSess > 1))
            if (~SPM_STATS_AVG_RUNS)
                doSPMStats = 1;
            end
        end
    end
    
    % DO SPM STATS
    if (doSPMStats)
        if (any(stepsToRun == 1) || any(stepsToRun == 7))
            if (SPM_STATS_WRITE_TAL)
                % Average runs
                icatb_spm_avg_runs(parameter_file);
                disp('Running one sample t-test on subject component maps ...');
                fprintf('\n');
                
                if SPM_STATS_AVG_RUNS
                    group = (1:sesInfo.numOfSub);
                else
                    group = (1:sesInfo.numOfSub*sesInfo.numOfSess);
                end
                
                % Compute one sample t-test on subject maps using SPM
                icatb_spm_stats(parameter_file, 1, 'Group 1', group, [], [], ...
                    (1:sesInfo.numComp), SPM_STATS_WRITE_TAL, SPM_STATS_AVG_RUNS);
                fprintf('\n');
                disp('Done running one sample t-test on subject component maps');
                fprintf('\n');
            end
        end
    end
    % END FOR DOING SPM STATS
    
    
    OPEN_DISPLAY_GUI =0;  %%  cliff: don't OPEN_DISPLAY_GUI
    if OPEN_DISPLAY_GUI
        if (any(stepsToRun == 1) || any(stepsToRun == 7))
            if strcmpi(modalityType, 'fmri')
                % Open fMRI GUI
                icatb_displayGUI(parameter_file);
            else
                % Open EEG display GUI
                icatb_eeg_displayGUI(parameter_file);
            end
            
        end
    end
    
catch
    
    if exist('sesInfo', 'var')
        % display information to the user
        diary('off');
        if ~strcmpi(analysisType, 'batch')
            % close the status bar
            if (exist('statusHandle', 'var') && ishandle(statusHandle))
                delete(statusHandle);
            end
        end
    end
    
    % Display error message
    icatb_displayErrorMsg;
    
end
