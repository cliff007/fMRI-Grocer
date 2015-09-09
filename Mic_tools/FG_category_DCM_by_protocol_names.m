function [all_protocol_names,all_protocol_pths]=FG_category_DCM_by_protocol_names(DCMs)
if nargin==0
    DCMs = spm_select(inf,'any','Please select the dicom files...');
end

all_protocol_names=[];
all_protocol_pths=[];

for i=1:size(DCMs,1)
    
    [pth,name]=FG_separate_files_into_name_and_path(deblank(DCMs(i,:)));
    
%     try
%         info = dicominfo(deblank(DCMs(i,:))); % header
%         P_name=info.ProtocolName;  % "ep2d_DTI_30dir_TR5s_1.7x1.7x4mm_3Avr 8 CHANNEL BRAIN"    
%         P_num=info.SeriesNumber;
%     catch me  % to deal with the case that the file is not DICOM image
%         me.message
%         continue
%     end

% to deal with the case that the file is not DICOM image
    
    tf = isdicom(deblank(DCMs(i,:)));
    if ~tf
       fprintf('\n%s is not a DICOM file...\n',deblank(DCMs(i,:))) 
       continue
    else
        try
            info = dicominfo(deblank(DCMs(i,:))); % header
            P_name=info.ProtocolName;  % "ep2d_DTI_30dir_TR5s_1.7x1.7x4mm_3Avr 8 CHANNEL BRAIN"    
            P_num=info.SeriesNumber;
        catch me  % to deal with the case that there is something wrong in the DICOM image
            me.message
            continue
        end
    end
        

    if i==1
        new_P_num=P_num;
        new_P_pth=fullfile(pth,[num2str(sprintf('%0.3d', P_num)) '_' P_name]);
        mkdir(new_P_pth);  
        all_protocol_names=strvcat(all_protocol_names,[num2str(sprintf('%0.3d', P_num)) '_' P_name]);
        all_protocol_pths=strvcat(all_protocol_pths,new_P_pth);
    end
    
    
    if strcmp(P_num,new_P_num)
        movefile(deblank(DCMs(i,:)),new_P_pth) 
    else
        new_P_num=P_num;
        new_P_pth=fullfile(pth,[num2str(sprintf('%0.3d', P_num)) '_' P_name]);
        mkdir(new_P_pth); 
        movefile(deblank(DCMs(i,:)),new_P_pth) 
        all_protocol_names=strvcat(all_protocol_names,[num2str(sprintf('%0.3d', P_num)) '_' P_name]);
        all_protocol_pths=strvcat(all_protocol_pths,new_P_pth);
    end
    
    
end

        all_protocol_names=unique(all_protocol_names,'rows');
        all_protocol_pths=unique(all_protocol_pths,'rows');
        
        
        
        
        
        
        
        
        
        
%         
% info = dicominfo('CT-MONO2-16-ankle.dcm'); % header
% I = dicomread(info); % data
% 
% info.ProtocolName  % "ep2d_DTI_30dir_TR5s_1.7x1.7x4mm_3Avr 8 CHANNEL BRAIN"
% info.InstanceCreationDate  % '20120515'
% info.InstanceCreationTime  % '075039.921000'
% info.InstitutionName  % 'HUP6'
% info.Manufacturer % 'SIEMENS'
% info.PatientName  % 'ANON'
% info.PatientID  % '0'
% info.AcquisitionMatrix
% info.SeriesNumber  % "15", this is the sequence number in the whole scan study (i.e. the order of the sequence)
% info.
% 
% 
% 
% info.SliceThickness   % "4"
% info.RepetitionTime   % "5500"
% info.EchoTime   % "99"
% info.NumberOfAverages   % "1"
% info.MagneticFieldStrength   % "3"
% info.SpacingBetweenSlices   % "4.0000"
% info.NumberOfPhaseEncodingSteps   % "96"
% info.EchoTrainLength   % "1"
% info.PercentSampling   % "100"
% info.PercentPhaseFieldOfView   % "100"
% info.PixelBandwidth   % "1860"
% info.FlipAngle   % "90"
% info.SAR  % "0.2636"
% 



