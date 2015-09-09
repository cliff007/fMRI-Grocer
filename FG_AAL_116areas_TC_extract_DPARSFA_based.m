function FG_AAL_116areas_TC_extract_DPARSFA_based
%%%% based on DPARSFA_run.m

a=which('fmri_grocer.m');
[DPARSF_path,b,c,d]=fileparts(a);
   ProgramPath = DPARSF_path;

  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       subjdir = spm_select(1,'dir','Select the subject''s directory where all the img/hdr Img. are:', [],pwd);
  else  
       subjdir = spm_get(1,'dir','Select the subject''s directory:'); 
  end
  
 if isempty(subjdir)
     return
 end
 
    cd(subjdir); 
    
  dirs=spm_str_manip(spm_str_manip(subjdir,'dh'),'dc');  % take use of the "spm_str_manip" function
 
    if size(dirs,1)==1   % in this condition, [spm_str_manip(spm_str_manip(dirs,'dh'),'dc')] can't get the subject dirctories
       i=size(dirs,2); 
       success=0;
       for j=i:-1:1
           if dirs(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           dirs=dirs(j+1:end);
       end
    end
    
  
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       files = spm_select(Inf,'any','Select the all the img/hdr Img. you want to draw AAL regions timecourse:', [],pwd,'.img$|.nii$');
  end
  
 if isempty(files)
     return
 end
 
 files=spm_str_manip(files,'dc');  % take use of the "spm_str_manip" function

    if size(files,1)==1   % in this condition, [spm_str_manip(spm_str_manip(files,'dh'),'dc')] can't get the group dirctories
       i=size(files,2); 
       success=0;
       for j=i:-1:1
           if files(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           files=files(j+1:end);
       end
    end 
  
 %   dlg_prompt={'How many imgs in the subject''s diretory:'};
  %  dlg_name='Timepoints';
  %  TimePoints=inputdlg(dlg_prompt,dlg_name);
  %  TimePoints=str2num(cell2mat(TimePoints));
    

%Extract AAL Time Cources (116 areas) for one subject

 
  %  mkdir(['..',filesep, dirs,'_AALTC',filesep])

        % Check if the mask is appropriate
        AMaskFilename=spm_select(1,'any','Suggest to select a right resolution AAL.nii:', [],[ProgramPath,filesep,'Templates',filesep],'^AAL.*nii');
        if isempty(AMaskFilename)
            return
        end
        AMaskFilename=deblank(AMaskFilename);
        
      %  AMaskFilename=[ProgramPath,filesep,'Templates',filesep,'AAL_61x73x61.nii'];
        [MaskData,MaskVox,MaskHeader]=FG_rest_readfile(AMaskFilename);
       % DirImg=dir('*.img');
       DirImg=files;
        RefFile = deblank(DirImg(1,:));
        [RefData,RefVox,RefHeader]=FG_rest_readfile(RefFile);
        if ~isequal(size(MaskData), size(RefData))
            fprintf('\nReslice AAL Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',AMaskFilename, RefFile);
            if ~(7==exist(['..',filesep,'Masks'],'dir')) % judge whether is it a directory
                mkdir(['..',filesep,'Masks']);
            end
            ReslicedMaskName=['..',filesep,'Masks',filesep,'AAL_',dirs,'.img'];
            FG_y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
            AMaskFilename=ReslicedMaskName;
        end

        % Generate the time courses
        [AALData, Vox, Head] = FG_rest_readfile(AMaskFilename);
        for iAAL=1:116
            if iAAL<=99
                AreaName=['0',num2str(iAAL)];
                AreaName=AreaName(end-1:end);
          % in the standard 'AAL_61x73x61.nii', all the regions are  masked from 1~116
                eval(['AAL',AreaName,'Index=find(AALData==',num2str(iAAL),');']);
            else
                AreaName=num2str(iAAL);
                eval(['AAL',AreaName,'Index=find(round(AALData)==',num2str(iAAL),');']); % cliff , add round() here to deal with the situation that the AAL template is auto resliced
            end
        end

        
        for iAAL=1:116
            if iAAL<=99
                AreaName=['0',num2str(iAAL)];
                AreaName=AreaName(end-1:end);
                eval(['AAL',AreaName,'TC=[];']);
            else
                AreaName=num2str(iAAL);
                eval(['AAL',AreaName,'TC=[];']);
            end
        end
        
        % DirImg=dir('*.img');
        for j=1:size(DirImg,1)
            Filename=deblank(DirImg(j,:));
            [Data, Vox, Head] = FG_rest_readfile(Filename);
          %  Data(find(isnan(Data)))=0;  % cliff, reset all the nan values into 0
            for iAAL=1:116
                if iAAL<=99
                    AreaName=['0',num2str(iAAL)];
                    AreaName=AreaName(end-1:end);
                    eval(['Temp=mean(Data(AAL',AreaName,'Index));']);
                    eval(['AAL',AreaName,'TC=[AAL',AreaName,'TC;Temp];']);
                else
                    AreaName=num2str(iAAL);
                    eval(['Temp=mean(Data(AAL',AreaName,'Index));']);
                    eval(['AAL',AreaName,'TC=[AAL',AreaName,'TC;Temp];']);
                end
            end
        end
        
        if 7==exist(['..',filesep,'Masks'],'dir')
            rmdir (['..',filesep,'Masks'],'s')  % because the resliced BA mask may be wrong, so remove them before exit
        end
        
        
      %  save([subjdir,dirs,'_AALTC116.mat'],'-regexp', 'AAL\w*TC');
        clc
        
        % write them into excel row by row
        tem=[];
        for iAAL=1:116
            if iAAL<=9
                tem=[tem;{eval(['AAL0' num2str(iAAL) 'TC'])'}];
            else
                tem=[tem;{eval(['AAL' num2str(iAAL) 'TC'])'}];
            end
        end
        csvwrite('AAL_116TCs_rows.csv',tem);
        
        
        % write them into excel column by column
        tem=[];
        for iAAL=1:116
            if iAAL<=9
                tem=[tem {eval(['AAL0' num2str(iAAL) 'TC'])}];
            else
                tem=[tem {eval(['AAL' num2str(iAAL) 'TC'])}];
            end
        end
        csvwrite('AAL_116TCs_columns.csv',tem);
        
        cd('..');    
        
        
       fprintf('\n\n==AAL Time Cources extracting: %s''s AAL Time Course has been saved into:\n\n %s%s_AALTC.mat & AAL_116TCs_rows/columns.csv\n\n',dirs,subjdir,dirs);


