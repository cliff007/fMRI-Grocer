function FG_convert_DICOM_to_NIFTI(dicom_tem,OutputDir,DelorNo,out_format)
%% make sure the pathes of the file/folder names don't include space(s)
%  In matlab command window, Enter:  !dcm2nii.exe to see the options below:
%     Either drag and drop or specify command line options:  dcm2nii <options> <sourcenames> 
%     OPTIONS: (= Y / = N is the default value)
%         -a Anonymize [remove identifying information]: Y,N = Y 
%         -b load settings from specified inifile, e.g. '-b C:\set\t1.ini'   
%         -c Collapse input folders: Y,N = N 
%         -d Date in filename [filename.dcm -> 20061230122032.nii]: Y,N = Y 
%         -e events (series/acq) in filename [filename.dcm -> s002a003.nii]: Y,N = Y 
%         -f Source filename [e.g. filename.par -> filename.nii]: Y,N = N 
%         -g gzip output, filename.nii.gz [ignored if '-n n']: Y,N = N 
%         -i ID  in filename [filename.dcm -> johndoe.nii]: Y,N = Y 
%         -n output .nii file [if no, create .hdr/.img pair]: Y,N = N 
%         -o Output Directory, e.g. 'C:\TEMP' (if unspecified, source directory is used) 
%         -p Protocol in filename [filename.dcm -> TFE_T1.nii]: Y,N = Y 
%         -r Reorient image to nearest orthogonal: Y,N  
%         -s SPM2/Analyze not SPM5/NIfTI [ignored if '-n y']: Y,N = N 
%         -v Convert every image in the directory: Y,N = Y 
%         -x Reorient and crop 3D NIfTI images: Y,N = N 
%%%%%%%
%     HINTS
%       the combination '-d n -p n -i n -e n' will be ignored.
%       You can also set defaults by editing C:\lazarus\mricron\dcm2nii\dcm2nii.ini
%     EXAMPLE: dcm2nii -a y -o C:\TEMP C:\DICOM\input1.par C:\input2.par
%%%%%%%
if nargin==0
    uiwait(msgbox('Please make sure that the pathes of the files you select have no space(s)!!','Attention...','modal'));
    dicom_tem = spm_select(inf,'any','Select the Dicom images', [],pwd,'.*');
    if isempty(dicom_tem),return, end
    OutputDir = spm_select(1,'dir','Select a dir for the outputs (skip this to output in the original dir)', [],pwd);    
    out_format = questdlg('Select a output file format...','Hi...','nii','img','nii') ;
    DelorNo = questdlg('Do you want to delete original Dicom files?','Hi...','Del','No','No') ;
    
end
if isempty(dicom_tem),return, end
% record the current directory

[pwd_dir,name]=FG_separate_files_into_name_and_path(dicom_tem(1,:));
path=FG_whereisfun('fmri_grocer');
root_dcm2nii=fullfile(path,'dcm2nii');


%%% obsolete method: concatenating the columns into one row; it may cause the problem of
    % "The command line is too long" 
       % dicom=FG_string_ColVector_2_RowVector(dicom_tem);
%%%% actually, in order to import a series of .dcm images,
    %  we only need one .dcm file of a series of *.dcm file, so we can use this:   
        dicom=deblank(dicom_tem(1,:));
        
        
        
%Convert Functional DICOM files to NIFTI images
if ispc
    %% go to the dcm2nii.exe folder to execute dcm2nii.exe
    cd (root_dcm2nii)
%     eval(['!dcm2nii.exe -b dcm2nii.ini -o ',OutputDir,' ',dicom]);  
    if isempty(OutputDir)
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii.exe -a Y -d Y -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii.exe -a Y -d Y -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N ',dicom])
        end
    else
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii.exe -a Y -d Y -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii.exe -a Y -d Y -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        end        
    end
    %% change back to the previous directory
    cd (pwd_dir)
elseif ismac
    %% go to the dcm2nii.exe folder to execute dcm2nii.exe
    cd (root_dcm2nii)
    if isempty(OutputDir)
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N ',dicom])
        end
    else
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        end        
    end
    
    %% change back to the previous directory
    cd (pwd_dir)
else
    % Changed to use MRIcroN's dcm2nii since its linux bug has been fixed.
    %% go to the dcm2nii.exe folder to execute dcm2nii.exe
    cd (root_dcm2nii)
    eval(['!chmod +x  dcm2nii_linux']);
%     eval(['!' dcm2nii_linux ' -b ' dcm2nii_linux.ini ' -o ',OutputDir,' ',dicom]); 
    if isempty(OutputDir)
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii -a Y -d Y -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii -a Y -d Y -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N ',dicom])
        end
    else
        if strcmpi(out_format,'nii')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n Y -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        elseif strcmpi(out_format,'img')
            eval(['!dcm2nii -a Y -d N -e Y -f N -g N -i N -n N -p Y -r N -s N -v Y -x N -o ',OutputDir,' ',dicom])
        end        
    end

    %% change back to the previous directory
    cd (pwd_dir)
end

if isempty(OutputDir)
   OutputDir=FG_separate_files_into_name_and_path(dicom_tem(1,:)); 
end
tem=spm_select('FPList',OutputDir,['.*' out_format]);
tem1=spm_select('FPList',OutputDir,['.*bval']);  % for some folders of DTI images
if ~isempty(tem) ||  ~isempty(tem1) %% only do deleting when there are some outputed files detected in the output dir
    if strcmpi(DelorNo,'Del')
        for i=1:size(dicom_tem,1)
            delete(deblank(dicom_tem(i,:)));
        end
    end
end


fprintf('======== Dicom ---> Nifti is done...\n');
