function FG_convert_DICOM_to_NIFTI_SPM(dicoms,out_format,DelorNo)
% use SPM function, the outoput names can't be flexibly defined
    if nargin==0
        dicoms = spm_select(inf,'any','Select the Dicom images', [],pwd,'.*');
        if isempty(dicoms),return, end
%         OutputDir = spm_select(1,'dir','Select a dir for the outputs', [],pwd);
%         if isempty(OutputDir),return, end
        out_format = questdlg('Select a output file format...','Hi...','nii','img','nii') ;
        DelorNo = questdlg('Do you want to delete original Dicom files?','Hi...','Del','No','No') ;
    end
    
    if isempty(dicoms)
        return
    else
        for i=1:size(dicoms,1)
            if isdicom (deblank((dicoms(i,:))))
               tem(i,:)=dicoms(i,:);
            end
        end
        dicoms=tem; clear tem  %% check whether the selected files are dicoms first
        if isempty(dicoms)
            return
        end
    end
%     if isempty(OutputDir),return, end
    pause(0.5)
    % 
    
    hdrs=spm_dicom_headers(dicoms); 
    for i=1:size(dicoms,1)
        hdrs{i}=dicominfo(dicoms(i,:));
    end
    %% by the default,the images created by [FG_spm_dicom_convert_RevisedRenameMethod]
    %% will be under the current path
    [output_pths,names]=FG_separate_files_into_name_and_path(dicoms); clear names;
    
    try
        out = FG_spm_dicom_convert_RevisedRenameMethod (hdrs,'all','date_time',out_format,output_pths);
    %     out = FG_spm_dicom_convert_RevisedRenameMethod(hdrs,'all','series',out_format); % move images into separate scanning series folders
    catch me
       me.message 
       fprintf('\n**** Something wrong for the %s\n',output_pths(1,:))
       return
    end

tem=spm_select('FPList',output_pths(1,:),['.*' out_format]);
tem1=spm_select('FPList',output_pths(1,:),['.*bval']);  % for some folders of DTI images
if ~isempty(tem) ||  ~isempty(tem1) %% only do deleting when there are some outputed files detected in the output dir
    if strcmpi(DelorNo,'Del')
        for i=1:size(dicoms,1)
            delete(deblank(dicoms(i,:)));
        end
    end
    fprintf('\n\n======== Dicom ---> Nifti is done...\n');
end

    
% Convert DICOM images into something that SPM can use
% FORMAT spm_dicom_convert(hdr,opts,root_dir,format)
% Inputs:
% hdr  - a cell array of DICOM headers from spm_dicom_headers
% opts - options
%        'all'      - all DICOM files [default]
%        'mosaic'   - the mosaic images
%        'standard' - standard DICOM files
%        'spect'    - SIEMENS Spectroscopy DICOMs (some formats only)
%                     This will write out a 5D NIFTI containing real and
%                     imaginary part of the spectroscopy time points at the
%                     position of spectroscopy voxel(s).
%        'raw'      - convert raw FIDs (not implemented)
% root_dir - 'flat' - do not produce file tree [default]
%            With all other options, files will be sorted into
%            directories according to their sequence/protocol names
%            'date_time'  - Place files under ./<StudyDate-StudyTime>
%            'patid'      - Place files under ./<PatID>
%            'patid_date' - Place files under ./<PatID-StudyDate>
%            'patname'    - Place files under ./<PatName>
%            'series'     - Place files in series folders, without
%                           creating patient folders
% format - output format
%          'img' Two file (hdr+img) NIfTI format [default]
%          'nii' Single file NIfTI format
%                All images will contain a single 3D dataset, 4D images
%                will not be created.
% Output:
% out - a struct with a single field .files. out.files contains a
%       cellstring with filenames of created files. If no files are
%       created, a cell with an empty string {''} is returned.