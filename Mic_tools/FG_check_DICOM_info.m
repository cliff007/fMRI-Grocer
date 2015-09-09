function DCM_info=FG_check_DICOM_info(DCMs)
if nargin==0
    DCMs = spm_select(1,'any','Please select a dicom files...');
end

% to deal with the case that the file is not DICOM image
    
    tf = isdicom(deblank(DCMs(1,:)));
    if ~tf
       fprintf('\n%s is not a DICOM file...\n',deblank(DCMs(1,:))) 
    else
        try
            DCM_info = dicominfo(deblank(DCMs(1,:))); % header
        catch me  % to deal with the case that there is something wrong in the DICOM image
            me.message
        end
    end