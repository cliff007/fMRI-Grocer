function sortParameters=icatb_displayGUI(paramFile)
% Purpose: Display GUI is used to switch between different visualization
% methods. There are four visualization methods like Component Explorer,
% Subect Explorer, Orthogonal Viewer, Composite Viewer.
% These visualization methods except Subject Explorer can be called
% independently of Display GUI by
% clicking on the buttons like Composite Viewer, Component Explorer,
% Orthogonal Viewer

icatb_defaults;

global BG_COLOR;
global BG2_COLOR;
global BUTTON_COLOR;
global FG_COLOR;
global AXES_COLOR;
global FONT_COLOR;
global BUTTON_FONT_COLOR;
global COMPONENT_EXPLORER_PIC;
global COMPOSITE_VIEWER_PIC;
global ORTHOGONAL_VIEWER_PIC;
global UI_FONTNAME;
global UI_FONTUNITS;
global UI_FS;
global SORT_COMPONENTS;
global PARAMETER_INFO_MAT_FILE;
global ZIP_IMAGE_FILES;

% load parameters file
filterP = ['*', PARAMETER_INFO_MAT_FILE, '*.mat'];
if ~exist('paramFile', 'var')
    [paramFile] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Parameter File', ...
        'filter', filterP);
end

drawnow;

[pathstr, fileName] = fileparts(paramFile);

cd(pathstr); % Cd to parameter file location
load(paramFile);

if ~exist('sesInfo', 'var')
    error('Please select the ICA parameter file');
end

if ~sesInfo.isInitialized
    error('Please run the analysis to display the results');
end


[modalityType, dataTitle, compSetFields] = icatb_get_modality;


if isfield(sesInfo, 'modality')
    if ~strcmpi(sesInfo.modality, modalityType)
        if strcmpi(sesInfo.modality, 'fmri')
            error('You have selected the fMRI parameter file. Use GIFT toolbox to display results.');
        elseif strcmpi(sesInfo.modality, 'smri')
            error('You have selected the sMRI parameter file. Use SBM toolbox to display results.');
        else
            error('You have selected the EEG parameter file. Use EEGIFT toolbox to display results.');
        end
    end
else
    sesInfo.modality = 'fmri';
end


try
    displayGUIMsg = 'Opening display GUI. Please wait ...';
    disp(displayGUIMsg);
    helpHandle = helpdlg(displayGUIMsg, 'Opening Display GUI');
    [sesInfo, complexInfoRead] = icatb_name_complex_images(sesInfo, 'read');
    [sesInfo, complexInfoWrite] = icatb_name_complex_images(sesInfo, 'write');
    
    
    zipContents.zipFiles = {};
    zipContents.files_in_zip(1).name = {};
    if isfield(sesInfo, 'zipContents')
        zipContents = sesInfo.zipContents;
    end
    
    %%%%%%%% Test if the data sets have different number of time points %%%
    % Count the number of files in each of the datasets
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    varCount = 0;
    countFiles = zeros(1, sesInfo.numOfSub*sesInfo.numOfSess);
    
    % check the time points information
    if isfield(sesInfo, 'diffTimePoints')
        
        for numSubjects = 1:sesInfo.numOfSub
            for numSessions = 1:sesInfo.numOfSess
                varCount = varCount + 1;
                % get the time points information
                countFiles(varCount) = sesInfo.diffTimePoints(varCount);
                % end for getting the count for time points
                countTimePoints.sub(numSubjects).sess(numSessions) = countFiles(varCount);
            end
        end
        
    else
        for numSubjects = 1:sesInfo.numOfSub
            for numSessions = 1:sesInfo.numOfSess
                varCount = varCount + 1;
                % get the time points information
                countFiles(varCount) = icatb_get_countTimePoints(sesInfo.userInput.files(varCount).name);
                % end for getting the count for time points
                countTimePoints.sub(numSubjects).sess(numSessions) = countFiles(varCount);
            end
        end
        % set the time points info to sesInfo
        sesInfo.userInput.diffTimePoints = countFiles;
        sesInfo.diffTimePoints = countFiles;
    end
    % end for checking time points information
    
    % check for same number of time points or different
    checkTimePoints = find(countFiles ~= countFiles(1));
    
    if ~isempty(checkTimePoints)
        flagTimePoints = 'different_time_points';
    else
        flagTimePoints = 'same_time_points';
    end
    
    modalityType = sesInfo.modality;
    
    %get results from sesInfo file
    dispParameters.icaOutputFiles = sesInfo.icaOutputFiles;
    dispParameters.numOfSess = sesInfo.numOfSess;
    dispParameters.numOfSub = sesInfo.numOfSub;
    dispParameters.numOfComp = sesInfo.numComp;
    dispParameters.inputFiles = sesInfo.inputFiles;
    dispParameters.spmMatrices = sesInfo.userInput.designMatrix;
    dispParameters.outputDir = pathstr; % save the output directory
    dispParameters.paramFile = paramFile; % parameter file
    dispParameters.inputPrefix = sesInfo.userInput.prefix;
    dispParameters.complexInfoRead = complexInfoRead;
    dispParameters.complexInfoWrite = complexInfoWrite;
    dispParameters.zipContents = zipContents;
    dispParameters.mask_ind = sesInfo.mask_ind;
    dispParameters.button_original_font_color = BUTTON_FONT_COLOR;
    dispParameters.button_new_font_color = [0 1 0];
    if (isfield(sesInfo, 'conserve_disk_space'))
        dispParameters.conserve_disk_space = sesInfo.conserve_disk_space;
    else
        dispParameters.conserve_disk_space = 0;
    end
    
    if isfield(sesInfo, 'flip_analyze_images')
        dispParameters.flip_analyze_images = sesInfo.flip_analyze_images;
    end
    
    
    maskImage = fullfile(dispParameters.outputDir, [dispParameters.inputPrefix, 'Mask.img']);
    % save mask image
    dispParameters.mask_file = maskImage;
    
    %%%%%%%%% Construct a mask Image for dealing with z scores%%%%%%%%%%%%%%%
    % get voxel dimensions
    voxelDim = sesInfo.HInfo.DIM;
    % Initialise mask data
    maskData = zeros(1, prod(voxelDim));
    % use indices in the mask as one
    maskData(sesInfo.mask_ind) = 1;
    % convert to 3D data
    maskData = reshape(maskData, voxelDim);
    
    % first scan of the functional data
    firstScan = deblank(sesInfo.inputFiles(1).name(1, :));
    
    [firstScan, fileNum] = icatb_parseExtn(firstScan);
    
    if ~exist(firstScan, 'file')
        disp(['file: ', firstScan, ' is missing.']);
        firstScan = icatb_selectEntry('typeEntity', 'file', 'typeSelection', 'single', 'filter', '*.img;*.nii', ...
            'title', 'Select first scan of functional data', 'fileType', 'image', 'fileNumbers', 1);
        if isempty(firstScan)
            error('file is not selected');
        end
        % update the files information
        sesInfo.inputFiles(1).name = str2mat(firstScan, sesInfo.inputFiles(1).name(2:end, :));
        sesInfo.userInput.files = sesInfo.inputFiles;
        dispParameters.inputFiles = sesInfo.inputFiles;
    end
    
    if (~isa(sesInfo.HInfo.V(1).private, 'icatb_nifti'))
        [dd, sesInfo.HInfo] = icatb_returnHInfo(deblank(dispParameters.inputFiles(1).name(1, :)));
    end
    
    dispParameters.HInfo = sesInfo.HInfo;
    % get the first image volume
    V = dispParameters.HInfo.V(1);
    V.fname = maskImage;
    V.n(1) = 1;
    icatb_write_vol(V, maskData);
    %%%%%%%%%%%%% end for creating mask %%%%%%%%%%%
    
    % include spm mat flag
    if isfield(sesInfo.userInput, 'spmMatFlag')
        dispParameters.spmMatFlag = sesInfo.userInput.spmMatFlag;
    else
        dispParameters.spmMatFlag = 'not_specified';
    end
    
    % include data type
    if isfield(sesInfo.userInput, 'dataType')
        dispParameters.dataType = lower(sesInfo.userInput.dataType);
    else
        dispParameters.dataType = 'real';
    end
    
    % include data type
    if isfield(sesInfo.userInput, 'write_complex_images')
        dispParameters.write_complex_images = lower(sesInfo.userInput.write_complex_images);
    else
        dispParameters.write_complex_images = 'real&imaginary';
    end
    
    % sorting text file (optional way to enter the regressors)
    if isfield(sesInfo.userInput, 'sortingTextFile')
        dispParameters.sortingTextFile = sesInfo.userInput.sortingTextFile;
    else
        dispParameters.sortingTextFile = [];
    end
    
    try
        icatb_save(paramFile, 'sesInfo');
    catch
    end
    
    clear sesInfo;
    
    % store the information about the structural file
    [dispParameters] = icatb_getStructuralFile(dispParameters);
    
    dispParameters.flagTimePoints = flagTimePoints;
    dispParameters.countTimePoints = countTimePoints;
    
    % delete a previous figure of display GUI
    checkDispGUI = findobj('tag', 'displaywindow');
    
    if ~isempty(checkDispGUI)
        for ii = 1:length(checkDispGUI)
            delete(checkDispGUI(ii));
        end
    end
    
    % display figure
    graphicsHandle = icatb_getGraphics('Display GUI', 'displayGUI', 'displaywindow', 'off');
    
    set(graphicsHandle, 'CloseRequestFcn', @figCloseCallback);
    
    % set graphics handle menu none
    set(graphicsHandle, 'menubar', 'none');
    
    dispParameters.diffTimePoints = countFiles; % store the count for the images
    
    % plot display defaults
    display_defaultsMenu = uimenu('parent', graphicsHandle, 'label', 'Display Defaults', 'callback', ...
        {@display_defaults_callback, graphicsHandle});
    
    if (strcmpi(modalityType, 'fmri'))
        
        % Display GUI Options Menu
        dispGUIOptionsMenu = uimenu('parent', graphicsHandle, 'label', 'Display GUI Options');
        designMatrixMenu = uimenu(dispGUIOptionsMenu, 'label', 'Design Matrix', 'callback', ...
            {@designMatrixOptionsCallback, graphicsHandle});
        
        
        % IC navigator
        %icNavigatorMenuH = uimenu(dispGUIOptionsMenu, 'label', 'IC Navigator', 'callback', @icNavigatorCallback);
        
        %     % save display parameters using save option in options menu
        %     saveDataMenu = uimenu(dispGUIOptionsMenu, 'label', 'Save Display Parameters', 'callback', ...
        %         {@saveDispParametersCallback, graphicsHandle});
        %
        %
        %     % load display parmeters
        %     loadDataMenu = uimenu(dispGUIOptionsMenu, 'label', 'Load Display Parameters', 'callback', ...
        %         {@loadDispParametersCallback, graphicsHandle});
        %
        %     % enter sorting text file
        sortingTextFileMenu = uimenu(dispGUIOptionsMenu, 'label', 'Load file for temporal sorting', 'callback', ...
            {@sortingTextFileCallback, graphicsHandle});
        
    end
    
    if strcmpi(modalityType, 'fmri')
        helpLabel = 'GIFT-Help';
    else
        helpLabel = 'SBM-Help';
    end
    
    % Help Menu
    helpMenu = uimenu('parent', graphicsHandle, 'label', helpLabel);
    htmlHelpMenu = uimenu(helpMenu, 'label', 'Display GUI', 'callback', 'icatb_openHTMLHelpFile(''icatb_displayGUI.htm'');');
    
    
    % parameters to plot in a menu
    
    % offsets
    xOffset = 0.02; yOffset = 0.02;
    
    %%%%%%%%%%%%% Draw Title here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % title color
    titleColor = [0 0.9 0.9];
    % fonts
    titleFont = 13;
    axes('Parent', graphicsHandle, 'position', [0 0 1 1], 'visible', 'off');
    xPos = 0.5; yPos = 0.97;
    text(xPos, yPos, 'Visualization Methods', 'color', titleColor, 'FontAngle', 'italic', 'fontweight', 'bold', ...
        'fontsize', titleFont, 'HorizontalAlignment', 'center', 'FontName', UI_FONTNAME);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot controls in two frames
    % Upper frame: Images
    % Lower frame: UIcontrols
    
    % plot display button
    buttonWidth = 0.2; buttonHeight = 0.05;
    displayButtonPos = [0.75 yOffset buttonWidth buttonHeight];
    
    
    displayButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', displayButtonPos, 'string', 'Display', 'tag', 'display_button', 'callback', ...
        {@displayButtonCallback, graphicsHandle});
    %     extentPos = get(displayButtonH, 'extent'); % get the extent of the load anatomical button
    %     displayButtonPos(3) = extentPos(3) + 0.02; displayButtonPos(4) = extentPos(4) + 0.002;
    %     % get the new position for load anatomical position
    %     set(displayButtonH, 'position', displayButtonPos);
    
    % plot load anatomical
    buttonWidth = 0.26; buttonHeight = 0.05;
    loadAnatomicalPos = [0.05 yOffset buttonWidth buttonHeight];
    loadAnatomicalH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', loadAnatomicalPos, 'string', 'Load Anatomical', 'tag', 'load_anatomical_button', ...
        'callback', {@loadAnatomicalCallback, graphicsHandle});
    %     extentPos = get(loadAnatomicalH, 'extent'); % get the extent of the load anatomical button
    %     loadAnatomicalPos(3) = extentPos(3) + 0.01; loadAnatomicalPos(4) = extentPos(4) + 0.001;
    %     % get the new position for load anatomical position
    %     set(loadAnatomicalH, 'position', loadAnatomicalPos);
    
    paramFrameYOrigin = loadAnatomicalPos(2) + loadAnatomicalPos(4) + yOffset;
    availableSpace = yPos - paramFrameYOrigin - yOffset;
    
    paramHeight = 0.65*availableSpace;
    
    % define frame positions
    parameterFramePos = [xOffset paramFrameYOrigin 1 - 2*xOffset paramHeight];
    
    paramFrameYOrigin = parameterFramePos(2) + parameterFramePos(4) + yOffset;
    paramFrameWidth = 1 - 2*xOffset;
    paramFrameHeight = yPos - 2*yOffset - paramFrameYOrigin;
    
    buttonFramePos = [parameterFramePos(1) paramFrameYOrigin paramFrameWidth paramFrameHeight];
    
    parametersFrameH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'frame', 'position', ...
        parameterFramePos, 'tag', 'parameters-frame', 'visible', 'off');
    
    buttonsFrameH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'frame', 'position', ...
        buttonFramePos, 'tag', 'button-frame', 'visible', 'off');
    
    % component Button
    if (~strcmpi(modalityType, 'smri'))
        buttonWidth = (1 - 2*xOffset - 5*xOffset) / 4;
    else
        buttonWidth = (1 - 2*xOffset - 5*xOffset) / 3;
    end
    buttonHeight = 0.05;
    componentButtonPos = [buttonFramePos(1) + xOffset buttonFramePos(2) +  buttonFramePos(4) - yOffset - 0.5*buttonHeight ...
        buttonWidth buttonHeight];
    
    componentButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', componentButtonPos, 'string', 'Component', 'tag', 'component_button', ...
        'callback', {@componentExplorerCallback, graphicsHandle});
    % subject explorer button
    subjectButtonPos = componentButtonPos;
    
    if (~strcmpi(modalityType, 'smri'))
        subjectButtonPos(1) = subjectButtonPos(1) + subjectButtonPos(3) + xOffset;
        subjectButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
            'position', subjectButtonPos, 'string', 'Subject', 'tag', 'subject_button', 'callback', ...
            {@subjectExplorerCallback, graphicsHandle});
    end
    
    % Orthogonal Viewer button
    orthButtonPos = subjectButtonPos;
    orthButtonPos(1) = orthButtonPos(1) + orthButtonPos(3) + xOffset;
    orthoButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', orthButtonPos, 'string', 'Orthogonal', 'tag', 'ortho_button', ...
        'callback', {@orthoViewerCallback, graphicsHandle});
    
    % Orthogonal Viewer button
    compositeButtonPos = orthButtonPos;
    compositeButtonPos(1) = compositeButtonPos(1) + compositeButtonPos(3) + xOffset;
    compositeButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', compositeButtonPos, 'string', 'Composite', 'tag', 'composite_button', ...
        'callback', {@compositeViewerCallback, graphicsHandle});
    
    % Component Explorer Picture
    componentPicPos = componentButtonPos;
    componentPicPos(2) = buttonFramePos(2);
    componentPicPos(4) = componentButtonPos(2) - 0.5*componentButtonPos(4) - componentPicPos(2);
    componentPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', componentPicPos);
    pic1 = imread(COMPONENT_EXPLORER_PIC);
    ImageAxis1 = image(pic1, 'parent', componentPicture, 'CDataMapping', 'scaled');
    axis(componentPicture, 'off');
    
    if (~strcmpi(modalityType, 'smri'))
        % Subject Explorer Picture
        subjectPicPos = componentPicPos;
        subjectPicPos(1) = subjectButtonPos(1);
        subjectPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', subjectPicPos);
        pic2 = imread(COMPONENT_EXPLORER_PIC);
        ImageAxis2 = image(pic2, 'parent', subjectPicture, 'CDataMapping', 'scaled');
        axis(subjectPicture, 'off');
    end
    
    % Orthogonal Viewer Picture
    orthoPicPos = componentPicPos;
    orthoPicPos(1) = orthButtonPos(1);
    orthoPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', orthoPicPos);
    pic3 = imread(ORTHOGONAL_VIEWER_PIC);
    ImageAxis3 = image(pic3, 'parent', orthoPicture, 'CDataMapping', 'scaled');
    axis(orthoPicture, 'off');
    
    % Composite Viewer Picture
    compositePicPos = componentPicPos;
    compositePicPos(1) = compositeButtonPos(1);
    compositePicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', compositePicPos);
    pic4 = imread(COMPOSITE_VIEWER_PIC);
    ImageAxis4 = image(pic4, 'parent', compositePicture, 'CDataMapping', 'scaled');
    axis(compositePicture, 'off');
    
    dispParameters.slicePlane = 'axial';
    dispParameters.compList = zeros(dispParameters.numOfComp, 1);
    dispParameters.displayType = 'component explorer';
    
    % Plot sort components followed by listboxes for viewing set and
    % component number
    
    % plot sort components here
    textHeight = 0.05; textWidth = 0.35;
    control_width = 0.2; control_height = 0.05;
    % text origin
    textYOrigin = parameterFramePos(2) + parameterFramePos(4) - xOffset - textHeight;
    textPos = [parameterFramePos(1), textYOrigin, textWidth, textHeight];
    
    % draw listbox
    listWidth = 0.5; listHeight = 0.3;
    
    if (~strcmpi(modalityType, 'smri'))
        
        % plot text
        textH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
            textPos, 'string', 'Sort Components', 'HorizontalAlignment', 'center');
        
        % horizontal alignment - center, vertical alignment - middle
        align(textH,'center','middle');
        
        popupPos = [textPos(1) + textPos(3) + 2*xOffset, textPos(2), ...
            control_width, control_height];
        
        clear options;
        
        % Sort Options
        options(1).str =  SORT_COMPONENTS;
        sortOptions = {'No', 'Yes'};
        % Apply defaults from icatb_defaults
        sortOptions = checkDefaults_gui(options(1).str, sortOptions, 'exact');
        
        for jj = 1:length(sortOptions)
            options(jj).str = sortOptions{jj};
        end
        
        popupH = icatb_getUIPopUp(graphicsHandle, str2mat(options.str), popupPos, '', 'on', 'sort_components');
        
        clear options;
        
        % plot component listbox and viewing set listbox
        textPos(2) = textPos(2) - textHeight - yOffset;
        
    end
    
    textWidth = 0.25; textHeight = 0.05;
    
    textPos = [textPos(1) + 0.5*listWidth - 0.5*textWidth textPos(2) textWidth textHeight];
    
    % plot text
    textH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
        textPos, 'string', 'Viewing Set', 'HorizontalAlignment', 'center');
    
    % horizontal alignment - center, vertical alignment - middle
    align(textH,'center','middle');
    
    outputFiles = chkOutputFiles(dispParameters.icaOutputFiles, dispParameters.outputDir);
    counter = 1;
    numOfSets = length(outputFiles);
    % loop over number of sets
    for jj = 1 : numOfSets
        % loop over sessions
        for kk = 1 : length(outputFiles(jj).ses)
            str = deblank(outputFiles(jj).ses(kk).name(1, :));
            [pathstr fileName] = fileparts(str);
            underScoreIndex = icatb_findstr(fileName, '_');
            str = fileName(1:underScoreIndex(end) - 1);
            str = [num2str(jj),'-', num2str(kk), ' ', str];
            options(counter).str = str;
            counter = counter + 1;
        end
    end
    
    dispParameters.icaOutputFiles2 = outputFiles;
    
    listboxPos = [parameterFramePos(1) textPos(2) - listHeight - yOffset  listWidth listHeight];
    % list box position
    listH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'listbox', 'position', ...
        listboxPos, 'HorizontalAlignment', 'center', 'string', str2mat(options.str), 'value', 1, 'tag', ...
        'viewing_set', 'min', 0, 'max', 1);
    
    
    listWidth = 0.25;
    
    listboxPos = [parameterFramePos(1) + parameterFramePos(3) - 2*xOffset - listWidth, listboxPos(2), listWidth, ...
        listHeight];
    textPos = [listboxPos(1) + 0.5*listWidth - 0.5*textWidth textPos(2) textWidth textHeight];
    
    text2H = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
        textPos, 'string', 'Component No:', 'HorizontalAlignment', 'center');
    
    % horizontal alignment - center, vertical alignment - middle
    align(text2H, 'center', 'middle');
    
    % number of components
    numComp = dispParameters.numOfComp;
    
    clear options;
    
    % return component index
    for ii = 1:numComp
        options(ii).str = icatb_returnFileIndex(ii);
    end
    
    % list box position
    list2H = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'listbox', 'position', ...
        listboxPos, 'string', str2mat(options.str), 'HorizontalAlignment', 'center', ...
        'tag', 'component_number', 'min', 0, 'max', 2);
    
    clear options
    % store the data to handles data
    %handles_data.dispParameters = dispParameters;
    
    [dispParameters, inputText] = icatb_displayGUI_defaults('init', [], dispParameters, 'off');
    %dispParameters.visualizationmethods = 'component explorer';
    handles_data.dispParameters = dispParameters; handles_data.inputText = inputText;
    
    % set the figure data
    set(graphicsHandle, 'userdata', handles_data);
    
    clear handles_data;
    
%             % by default execute the component explorer callback
%             componentExplorerCallback(componentButtonH, [], graphicsHandle);
    % by default execute the displayGUI callback
    displayButtonCallback(displayButtonH, [], graphicsHandle)
    
    try
        delete(helpHandle);
    catch
    end
    
    % Make the figure visible
    set(graphicsHandle, 'visible', 'on');
    
    
catch
    if exist('helpHandle', 'var')
        if ishandle(helpHandle)
            delete(helpHandle);
        end
    end
    icatb_displayErrorMsg;
end


%%%%%%%%%%%%%% Function Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%

function componentExplorerCallback(hObject, event_data, handles)
% Component explorer callback
% set the visualization methods field to component explorer


subjectH = findobj(handles, 'tag', 'subject_button');
orthoH = findobj(handles, 'tag', 'ortho_button');
compositeH = findobj(handles, 'tag', 'composite_button');

handles_data = get(handles, 'userdata');
dispParameters = handles_data.dispParameters;
dispParameters.visualizationmethods = 'component explorer';

% set all the other buttons normal font
set(hObject, 'fontweight', 'bold', 'ForegroundColor', dispParameters.button_new_font_color);
set(subjectH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(orthoH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(compositeH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);

% Viewing set listbox
viewingsetH = findobj(handles, 'tag', 'viewing_set');
set(viewingsetH, 'enable', 'on');

% component listbox
compListH = findobj(handles, 'tag', 'component_number');
set(compListH, 'enable', 'off');

handles_data.dispParameters = dispParameters;
% set the user data
set(handles, 'userdata', handles_data);

% sort parameters popup control
sortCompH = findobj(handles, 'tag', 'sort_components');
set(sortCompH, 'enable', 'on');


function subjectExplorerCallback(hObject, event_data, handles)
% Subject Component explorer callback
% set the visualization methods field to subject component explorer

componentH = findobj(handles, 'tag', 'component_button');
orthoH = findobj(handles, 'tag', 'ortho_button');
compositeH = findobj(handles, 'tag', 'composite_button');

handles_data = get(handles, 'userdata');
dispParameters = handles_data.dispParameters;
dispParameters.visualizationmethods = 'subject component explorer';


% set all the other buttons normal font
set(hObject, 'fontweight', 'bold', 'ForegroundColor', dispParameters.button_new_font_color);
set(componentH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(orthoH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(compositeH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);


% component listbox
compListH = findobj(handles, 'tag', 'component_number');
set(compListH, 'enable', 'on');

% viewing set listbox
viewingsetH = findobj(handles, 'tag', 'viewing_set');
set(viewingsetH, 'enable', 'off');

compVal = get(compListH, 'value');
if length(compVal) > 1
    set(compListH, 'value', compVal(1));
    % single selection listbox
end
% make the component listbox single selection
set(compListH, 'max', 1, 'min', 0);

% set the user data
handles_data.dispParameters = dispParameters;
set(handles, 'userdata', handles_data);

% sort parameters popup control
sortCompH = findobj(handles, 'tag', 'sort_components');
set(sortCompH, 'enable', 'off');

function orthoViewerCallback(hObject, event_data, handles)
% Orthogonal viewer callback
% set the visualization methods field to orthogonal viewer

componentH = findobj(handles, 'tag', 'component_button');
subjectH = findobj(handles, 'tag', 'subject_button');
compositeH = findobj(handles, 'tag', 'composite_button');


handles_data = get(handles, 'userdata');
dispParameters = handles_data.dispParameters;
dispParameters.visualizationmethods = 'orthogonal viewer';

% set all the other buttons normal font
set(hObject, 'fontweight', 'bold', 'ForegroundColor', dispParameters.button_new_font_color);
set(componentH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(subjectH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(compositeH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);

% Viewing set listbox
viewingsetH = findobj(handles, 'tag', 'viewing_set');
set(viewingsetH, 'enable', 'on');

% component listbox
compListH = findobj(handles, 'tag', 'component_number');
set(compListH, 'enable', 'on');

compVal = get(compListH, 'value');

if length(compVal) > 1
    set(compListH, 'value', compVal(1));
end

% make the component listbox single selection
set(compListH, 'min', 0, 'max', 1);

% set the figure data
handles_data.dispParameters = dispParameters;
set(handles, 'userdata', handles_data);

% sort parameters popup control
sortCompH = findobj(handles, 'tag', 'sort_components');
set(sortCompH, 'enable', 'off');

% case subject component explorer
function compositeViewerCallback(hObject, event_data, handles)
% Composite viewer callback
% set the visualization methods field to composite viewer


componentH = findobj(handles, 'tag', 'component_button');
subjectH = findobj(handles, 'tag', 'subject_button');
orthoH = findobj(handles, 'tag', 'ortho_button');

handles_data = get(handles, 'userdata');
dispParameters = handles_data.dispParameters;
dispParameters.visualizationmethods = 'composite viewer';

% set all the other buttons normal font
set(hObject, 'fontweight', 'bold', 'ForegroundColor', dispParameters.button_new_font_color);
set(componentH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(subjectH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);
set(orthoH, 'fontweight', 'normal', 'ForegroundColor', dispParameters.button_original_font_color);

% viewing set listbox
viewingsetH = findobj(handles, 'tag', 'viewing_set');
set(viewingsetH, 'enable', 'on');

% component listbox
compListH = findobj(handles, 'tag', 'component_number');
set(compListH, 'enable', 'on');

compVal = get(compListH, 'value');

if length(compVal) > 5
    disp('A maximum of five components can be plotted in Composite Viewer with different color bars');
    set(compListH, 'value', compVal(1:5));
    % single selection listbox
end

% make the component listbox multiple selection
set(compListH, 'min', 0, 'max', 2);

% set the figure data
handles_data.dispParameters = dispParameters;
set(handles, 'userdata', handles_data);

% sort parameters popup control
sortCompH = findobj(handles, 'tag', 'sort_components');
set(sortCompH, 'enable', 'off');

function loadAnatomicalCallback(hObject, event_data, handles)
% load structural image
% change the inputText structure array where index matches slice_range:
% set the structural file location to dispParameters

handles_data = get(handles, 'userdata');
% display parameters
dispParameters = handles_data.dispParameters;
% get the input text Structure
inputText = handles_data.inputText;

startPath = fileparts(which('gift.m'));
startPath = fullfile(startPath, 'icatb_templates');

oldDir = pwd;

if (~exist(startPath, 'dir'))
    startPath = pwd;
end

% get the structural file
structFile = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Structural File', 'filter', ...
    '*.img;*.nii', 'fileType', 'image', 'fileNumbers', 1, 'startpath', startPath);

drawnow;

cd(oldDir);

if ~isempty(structFile)
    dispParameters.structFile = structFile;
    
    % get the anatomical plane
    getIndex = strmatch('anatomical_plane', str2mat(inputText.tag), 'exact');
    % get the three views
    allStrs = inputText(getIndex).answerString;
    % get the current value
    selectVal = inputText(getIndex).value;
    
    if iscell(allStrs)
        selectStr = allStrs{selectVal};
    else
        selectStr = deblank(allStrs(selectVal, :));
    end
    % end for checking
    
    if isempty(selectStr)
        selectStr = 'axial';
    end
    
    selectStr = lower(selectStr);
    % find slice_range location
    getIndex = strmatch('slice_range', str2mat(inputText.tag), 'exact');
    % get structVol
    %imagVol = icatb_returnHInfo(structFile);
    imagVol = icatb_get_vol_nifti(structFile);
    % get the slices in mm for the corresponding plane
    [sliceParameters] = icatb_get_slice_def(imagVol, selectStr);
    % get the slices in mm
    slices_in_mm = sliceParameters.slices;
    clear sliceParameters;
    % construct string
    slices_in_mm = icatb_constructString(slices_in_mm);
    % set the slice range
    inputText(getIndex).answerString = slices_in_mm;
    % set display parameters
    [dispParameters, inputText] = icatb_displayGUI_defaults('no-init', inputText, dispParameters, 'off');
end

drawnow;

% set the user data to the figure
handles_data.dispParameters = dispParameters;
handles_data.inputText = inputText;
set(handles, 'userdata', handles_data);

function displayButtonCallback(hObject, event_data, handles)
% display button callback

try
    
    % get the figure data
    handles_data = get(handles, 'userdata');
    dispParameters = handles_data.dispParameters;
    % load parameter file
    load(dispParameters.paramFile);
    % indices in the mask
    dispParameters.mask_ind = sesInfo.mask_ind;
    mask_ind = sesInfo.mask_ind;
    zipContents.zipFiles = {};
    zipContents.files_in_zip(1).name = {};
    if isfield(sesInfo, 'zipContents')
        zipContents = sesInfo.zipContents;
    end
    % zip contents
    dispParameters.zipContents = zipContents;
    [sesInfo, complexInfoRead] = icatb_name_complex_images(sesInfo, 'read');
    [sesInfo, complexInfoWrite] = icatb_name_complex_images(sesInfo, 'write');
    % complex information
    dispParameters.complexInfoRead = complexInfoRead;
    dispParameters.complexInfoWrite = complexInfoWrite;
    clear sesInfo;
    
    % put a check for the visualization methods
    if isfield(dispParameters, 'visualizationmethods')
        displayMethod = dispParameters.visualizationmethods;
    else
        error('Visualization method is not selected');
    end
    
    % find viewing set listbox
    viewListH = findobj(handles, 'tag', 'viewing_set');
    viewingsetStr = get(viewListH, 'string');
    viewingsetVal = get(viewListH, 'value');
    
    % viewing set selected
    viewingset = deblank(viewingsetStr(viewingsetVal, :));
    
    % component listbox
    compListH = findobj(handles, 'tag', 'component_number');
    % get the component numbers
    component_numbers = get(compListH, 'value');
    
    if isempty(component_numbers)
        component_numbers = 1;
    end
    
    % checking display method
    if strcmpi(displayMethod, 'composite viewer')
        if length(component_numbers) > 5
            component_numbers = component_numbers(1:5);
            disp('A maximum of five components can be plotted in Composite Viewer with different color bars');
        end
    else
        if strcmpi(displayMethod, 'subject component explorer') | strcmpi(displayMethod, 'orthogonal viewer')
            if length(component_numbers) > 1
                component_numbers = component_numbers(1);
            end
        end
    end
    % end for checking display method
    
    dispParameters.componentnumber = component_numbers;
    
    % store viewing set
    dispParameters.viewingset = viewingset;
    returnValue = dispParameters.returnValue;
    convertToZ = dispParameters.convertToZ;
    threshValue = dispParameters.thresholdvalue;
    
    
    % sort parameters
    sortCompH = findobj(handles, 'tag', 'sort_components');
    
    if (~isempty(sortCompH))
        sortCompStr = get(sortCompH, 'string'); sortCompVal = get(sortCompH, 'value');
        sortcomponents = deblank(sortCompStr(sortCompVal, :));
    else
        sortcomponents = 'no';
    end
    
    dispParameters.sortcomponents = sortcomponents;
    
    handles_data.dispParameters = dispParameters;
    set(handles, 'userdata', handles_data);
    if isfield(handles_data.dispParameters, 'text_left_right')
        parameters.text_left_right = handles_data.dispParameters.text_left_right;
    end
    clear handles_data;
    
    
    % parameters or variables common to all the display methods
    
    % load structural file
    P = dispParameters.structFile; % structural file name
    pathstr = fileparts(P);
    if isempty(pathstr)
        P = fullfile(pwd, P);
    end
    
    icatb_defaults;
    global DETRENDNUMBER;
    global SMOOTHPARA;
    global SMOOTHINGVALUE;
    
    parameters.flip_analyze_images = [];
    if isfield(dispParameters, 'flip_analyze_images')
        parameters.flip_analyze_images = dispParameters.flip_analyze_images;
    end
    
    % parameter structure used to display components according to the
    % visualization selected
    parameters.structFile = dispParameters.structFile;
    parameters.imagevalues = returnValue;
    parameters.convertToZ = convertToZ;
    parameters.thresholdvalue = threshValue;
    % actual subjects, sessions and components
    parameters.numOfSub = dispParameters.numOfSub;
    parameters.numOfSess = dispParameters.numOfSess;
    parameters.numComp = dispParameters.numOfComp;
    parameters.filesOutputDir = dispParameters.outputDir;
    parameters.inputPrefix = dispParameters.inputPrefix;
    
    % initialise model time course
    modelTimecourse = [];
    % field required for detecting the type of complex images
    parameters.write_complex_images = dispParameters.write_complex_images;
    complexInfoWrite.complexInfoRead = complexInfoRead;
    % add complex type to the structure
    parameters.complexInfoRead = complexInfoRead;
    parameters.complexInfoWrite = complexInfoWrite;
    parameters.dataType = dispParameters.dataType;
    parameters.zipContents = dispParameters.zipContents;
    parameters.outputDir = dispParameters.outputDir;
    parameteres.mask_file = dispParameters.mask_file;
    
    switch lower(displayMethod)
        case 'component explorer'
            %icatb_defaults;
            global TMAP_AN3_FILE;
            global COMPLEXVIEWER; % get the viewer type (real&imaginary or magnitude&phase)
            
            % check the viewing set
            if ~isfield(dispParameters, 'viewingset')
                error('Viewing set is not selected');
            else
                if isempty(dispParameters.viewingset)
                    error('Viewing set is not selected');
                end
            end
            
            % load components
            dashIndex = icatb_findstr(dispParameters.viewingset, '-');
            spaceIndex = icatb_findstr(dispParameters.viewingset, ' ');
            a = dispParameters.viewingset(1 : dashIndex(1) - 1);
            b = dispParameters.viewingset(dashIndex(1) + 1 : spaceIndex(1));
            P = dispParameters.icaOutputFiles2(str2num(a)).ses(str2num(b)).name;
            
            compFiles = P;
            
            % get the files from the zip file
            [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfoWrite, ...
                dispParameters.dataType, zipContents);
            
            % component files
            compFiles = icatb_fullFile('directory', dispParameters.outputDir, 'files', compFiles);
            
            % number of components
            numOfComp = parameters.numComp;
            
            % end loop over component files
            figLabel = dispParameters.viewingset;
            
            % put a default spm flag
            if isfield(dispParameters, 'spmMatFlag')
                spmMatFlag = dispParameters.spmMatFlag;
            else
                spmMatFlag = 'not_specified';
            end
            
            % do interpolation of images separately for components that are
            % not sorted and sorted
            
            % when components are not sorted
            if strcmpi(dispParameters.sortcomponents, 'no')
                set(handles, 'pointer', 'watch');
                % resize the image and return header Info
                [icasig, icaTimecourse, structuralImage, coords, HInfo, text_left_right] = icatb_loadICAData('structFile', ...
                    dispParameters.structFile, 'compFiles', compFiles, 'slicePlane', dispParameters.anatomicalplane, ...
                    'sliceRange', dispParameters.slicerange, 'comp_numbers', [1:1:parameters.numComp], ...
                    'convertToZ', convertToZ, 'returnValue', returnValue, 'threshValue', threshValue, ...
                    'dataType', dispParameters.dataType, 'complexInfo', complexInfoWrite, ...
                    'zipfile', zipFileName, 'files_in_zip_file', files_in_zip, 'mask_file', parameteres.mask_file, 'flip_analyze_images', ...
                    parameters.flip_analyze_images);
                set(handles, 'pointer', 'arrow');
                
                % set up default labels and sorting Index
                for ii = 1:parameters.numComp
                    compLabels(ii).string = ['Component ', num2str(ii), ' Not Sorted'];
                end
                % smooth ica time course
                if strcmpi(SMOOTHPARA, 'yes')
                    icaTimecourse = icatb_gauss_smooth1D(icaTimecourse, SMOOTHINGVALUE);
                end
                spatialTemplate = [];
                parameters.compLabels = compLabels;
                parameters.undetrendICA = icaTimecourse;
                % linearly detrend ICA Timecourse
                parameters.icaTimecourse = icatb_detrend(icaTimecourse, 1, size(icaTimecourse, 1), DETRENDNUMBER);
                %detrend(icaTimecourse); % linearly detrended ica time course
                clear icaTimecourse;
                parameters.modelTimecourse = modelTimecourse;
                clear modelTimecourse;
                parameters.refInfo = [];
                parameters.icasig = icasig; % store component images
                clear icasig;
                parameters.figLabel = figLabel;
                parameters.htmlFile = 'icatb_component_explorer.htm';
            else
                % display GUI parameters
                dispGUI_Parameters = struct('returnValue', returnValue, 'convertToZ', convertToZ, 'threshValue', ...
                    threshValue, 'flagTimePoints', dispParameters.flagTimePoints, 'countTimePoints', ...
                    dispParameters.countTimePoints, 'icaOutputFiles', dispParameters.icaOutputFiles, 'numOfSub', ...
                    dispParameters.numOfSub, 'numOfSess', dispParameters.numOfSess, 'numOfComp', ...
                    dispParameters.numOfComp, 'spmMatrices', dispParameters.spmMatrices, 'outputDir', ...
                    dispParameters.outputDir, 'paramFile', dispParameters.paramFile, 'spmMatFlag', ...
                    spmMatFlag, 'sortingTextFile', dispParameters.sortingTextFile, 'structFile', ...
                    dispParameters.structFile, 'slicePlane', dispParameters.anatomicalplane, ...
                    'sliceRange', dispParameters.slicerange, 'dataType', dispParameters.dataType, ...
                    'complexInfo', complexInfoWrite, 'displayGUI', handles, 'inputPrefix', ...
                    dispParameters.inputPrefix, 'zipContents', zipContents);
                % Output contains the sorted parameters information
                [sortParameters] = icatb_sortComponentsGUI(dispGUI_Parameters);
                if isempty(sortParameters)
                    return; %error('error in getting data from sorting gui.');
                end
            end
    end
end
                
                

function designMatrixOptionsCallback(hObject, event_data, handles)
% design matrix menu callback
%
% Options menu for the design matrix:
% saves the selected design matrix information in the parameter file and
% subject file as well.
% Useful when many data sets are involved and if 'no' option is selected
% during the analysis.

% get the user data
designMatrixData = get(hObject, 'userdata');

% get the figure data
figureData = get(handles, 'userdata');

% set the spm matrices
icatb_selectDesignMatrix(handles);

function saveDispParametersCallback(hObject, event_data, handles)
% save display parameters menu callback

handles_data = get(handles, 'userdata');
% display parameters
dispParameters = handles_data.dispParameters;
% get outputDir information
outputDir = dispParameters.outputDir;
% open input dialog box
prompt = {'Enter Valid File Name:'};
dlg_title = 'Save Display Parameters as';
num_lines = 1;
def = {'dispParameters'};
% save the file with the file name specified
fileName = icatb_inputdlg2(prompt, dlg_title, num_lines, def);

if ~isempty(fileName)
    % make a full file
    fileName = fullfile(outputDir, [fileName{1}, '.mat']);
    icatb_save(fileName, 'dispParameters');
    disp(['Display parameters are saved in file: ', fileName]);
end

function loadDispParametersCallback(hObject, event_data, handles)
% load display parameters menu callback

global DISP_PARAMETERS
handles_data = get(handles, 'userdata');

dispParameters = handles_data.dispParameters;

% get outputDir information
outputDir = dispParameters.outputDir;

clear handles_data;

clear dispParameters;

% open file selection box
[P] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Display Parameter File', 'filter', '*.mat', ...
    'startPath', outputDir);
if ~isempty(P)
    load(P);
    if ~exist('dispParameters', 'var')
        error('Not a valid display parameter file');
    end
    DISP_PARAMETERS = dispParameters;
    D(1).string = 'Global DISP_PARAMETERS variable is created.';
    D(size(D, 2) + 1).string = '';
    D(size(D, 2) + 1).string = 'Type the following statements at the command prompt:';
    D(size(D, 2) + 1).string = '';
    D(size(D, 2) + 1).string = 'global DISP_PARAMETERS; DISP_PARAMETERS';
    disp(str2mat(D.string));
end


function openHelpDesignMatrix(hObject, event_data, handles)

% get the user data
helpDetails = get(hObject, 'userdata');
helpH = icatb_dialogBox('textType', 'large', 'textBody', helpDetails.str, 'title', helpDetails.title);
waitfor(helpH);

function sortingTextFileCallback(hObject, event_data, handles)
% function callback for sorting text file

% user data for the figure
handles_data = get(handles, 'userdata');

% disp parameters
dispParameters = handles_data.dispParameters;

% parameter file
paramFile = dispParameters.paramFile;

% load the parameter file
load(paramFile);

% sorting text file
sesInfo.userInput.sortingTextFile =  icatb_selectEntry('title', 'Select text file for regressors', 'typeSelection', ...
    'single', 'typeEntity', 'file', 'filter', '*.txt');

icatb_save(paramFile, 'sesInfo');

% set the file to display parameters
dispParameters.sortingTextFile = sesInfo.userInput.sortingTextFile;

clear sesInfo;

% set display parameters
handles_data.dispParameters = dispParameters;

% set the figure data
set(handles, 'userdata', handles_data);


function [dispParameters] = icatb_getStructuralFile(dispParameters)
% get the structural file for plotting component images

currentFile = dispParameters.inputFiles(1).name(1, :);

[currentFile] = icatb_parseExtn(currentFile);

% check the existence of the input file
if ~exist(currentFile, 'file')
    msgString = [deblank(dispParameters.inputFiles(1).name(1, :)), ' file doesn''t exist.' ...
        ' Do you want to select the structural file?'];
    [answerQuestion] = icatb_questionDialog('title', 'Select Structural File', 'textbody', msgString);
    if answerQuestion == 1
        % structural file
        [structuralFile] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Structural File', 'filter', ...
            '*.img;*.nii', 'fileType', 'image');
    else
        error(deblank(dispParameters.inputFiles(1).name(1, :)), ' file doesn''t exist.');
    end
else
    % structural file
    structuralFile = dispParameters.inputFiles(1).name(1, :);
    % create magnitude image for complex data type
    if ~strcmpi(dispParameters.dataType, 'real')
        complexFile = dispParameters.inputFiles(1).name(1, :);
        [data, HInfo] = icatb_loadData(complexFile, dispParameters.dataType, ...
            dispParameters.complexInfoRead, 'read', 1);
        data = abs(data);
        structuralFile = fullfile(dispParameters.outputDir, [dispParameters.inputPrefix, 'structFile.img']);
        V = HInfo.V(1);
        V.fname = structuralFile;
        icatb_write_vol(V, data);
        clear data; clear V;
    end
    % create magnitude image
end

% add structural file to the dispParameters structure
dispParameters.structFile = structuralFile;


function display_defaults_callback(hObject, event_data, handles)
% get the display defaults

handles_data = get(handles, 'userdata');

[parameters, inputText] = icatb_displayGUI_defaults('no-init', handles_data.inputText, handles_data.dispParameters);

handles_data.dispParameters = parameters;
handles_data.inputText = inputText;

set(handles, 'userdata', handles_data);

function optionsString = checkDefaults_gui(choiceString, optionsString, stringChar)
% put the defaults at the Top

temp = optionsString; % Assign options string to a temporary variable

if strcmp(stringChar, 'exact')
    matchIndex = strmatch(lower(choiceString), lower(temp), stringChar); % find the index of the choice string
else
    matchIndex = strmatch(lower(choiceString), lower(temp)); % find the index of the choice string
end

jj = 1; optionsString{1} = temp{matchIndex}; % choice string

for numOptions = 1:length(optionsString)
    if numOptions ~= matchIndex
        jj = jj + 1;
        optionsString{jj} = temp{numOptions}; % collect other options below the choice string
    end
end

function figCloseCallback(hObject, event_data, handles)
% figure close callback

delete(hObject);

function icNavigatorCallback(hObject, event_data, handles)

icatb_ic_navigator;

function status = chkFile(file)

[pathstr, fN, extn] = fileparts(deblank(file));

lastPos = icatb_findstr(fN, '_');
fN2 = fN(1:lastPos(end));

status = 0;
if (exist(fullfile(pathstr, [fN, extn]), 'file') || exist(fullfile(pathstr, [fN2, '.zip']), 'file'))
    status = 1;
end

function outputFiles = chkOutputFiles(outputFiles, outDir)
%% Truncate output files
%

setsToInclude = [];
for jj = 1:length(outputFiles)
    file = deblank(outputFiles(jj).ses(1).name(1, :));
    file = fullfile(outDir, file);
    if (~chkFile(file))
        continue;
    end
    setsToInclude = [setsToInclude, jj];
end

outputFiles = outputFiles(setsToInclude);
