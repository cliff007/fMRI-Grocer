function FG_dicom_convert(dicom_tem,DelorNo,out_format,OutputDir)

if nargin==0
    uiwait(msgbox('Please make sure that the pathes of the files you select have no space(s)!!','Attention...','modal'));
    dicom_tem = spm_select(inf,'any','Select the Dicom images', [],pwd,'.*');
    if isempty(dicom_tem),return, end
    OutputDir = spm_select(1,'dir','Select a dir for the outputs (skip this to output in the original dir)', [],pwd);    
    out_format = questdlg('Select a output file format...','Hi...','nii','img','nii') ;
    DelorNo = questdlg('Do you want to delete original Dicom files?','Hi...','Del','No','No') ;    
end

if isempty(dicom_tem),return, end
pause(0.5)

if nargin<4
    OutputDir='';
end

img_folder=FG_separate_files_into_name_and_path(dicom_tem(1,:));
try
    FG_convert_DICOM_to_NIFTI(dicom_tem,OutputDir,DelorNo,out_format) %% this is much more fast, but not error can be tracked
                                                                 %% it can handle whole volume missing problem, but may not for the slice missing problem   
catch me
    me.message
    fprintf('\n*************** Something wrong using dcm2nii.exe commands...')
    fprintf('\n*************** Make sure to check the image under %s ...',deblank(img_folder))
    fprintf('\n*************** Now switch to use SPM commands...\n')

    try
        FG_convert_DICOM_to_NIFTI_SPM(dicom_tem,out_format,DelorNo) %% cliff 2013.8.13 make a final choice
    catch me1
        me1.message
        fprintf('\n*************** Something wrong using SPM commands...')
        fprintf('\n*************** Make sure to check the image under %s ...',deblank(img_folder))
        fprintf('\n*************** Now switch to use SPM commands...\n')
    end
end

fprintf('======== Dicom ---> Nifti is done...\n');