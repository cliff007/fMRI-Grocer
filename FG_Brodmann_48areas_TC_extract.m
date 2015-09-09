function FG_Brodmann_48areas_TC_extract
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
       files = spm_select(Inf,'image','Select the all the img/hdr Img. you want to draw BA regions timecourse:', [],pwd,'.img$|.nii$');
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
    

%Extract Brodmann Time Cources (48 areas) for one subject

 
  %  mkdir(['..',filesep, dirs,'_BATC',filesep])

        % Check if the mask is appropriate
        AMaskFilename=[ProgramPath,filesep,'Templates',filesep,'Brodmann_61x73x61.nii'];
        [MaskData,MaskVox,MaskHeader]=FG_rest_readfile(AMaskFilename);
       % DirImg=dir('*.img');
       DirImg=files;
        RefFile = deblank(DirImg(1,:));
        [RefData,RefVox,RefHeader]=FG_rest_readfile(RefFile);
        if ~isequal(size(MaskData), size(RefData))
            fprintf('\nReslice BA Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',AMaskFilename, RefFile);
            if ~(7==exist(['..',filesep,'Masks'],'dir')) % judge whether is it a directory
                mkdir(['..',filesep,'Masks']);
            end
            ReslicedMaskName=['..',filesep,'Masks',filesep,'BA_',dirs,'.img'];
            FG_y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
            AMaskFilename=ReslicedMaskName;
        end

        % Generate the time courses
        [BAData, Vox, Head] = FG_rest_readfile(AMaskFilename);
        for iBA=1:48
            AreaName=['0',num2str(iBA)];
            AreaName=AreaName(end-1:end);
      % in the standard 'Brodmann_61x73x61.nii', all the regions are masked from 1~48
            eval(['BA',AreaName,'Index=find(round(BAData)==',num2str(iBA),');']);
        end

        
        for iBA=1:48
            AreaName=['0',num2str(iBA)];
            AreaName=AreaName(end-1:end);
            eval(['BA',AreaName,'TC=[];']);
        end
        
        % DirImg=dir('*.img');
        for j=1:size(DirImg,1)
            Filename=deblank(DirImg(j,:));
            [Data, Vox, Head] = FG_rest_readfile(Filename);
            for iBA=1:48
                AreaName=['0',num2str(iBA)];
                AreaName=AreaName(end-1:end);
                eval(['Temp=mean(Data(BA',AreaName,'Index));']);
                eval(['BA',AreaName,'TC=[BA',AreaName,'TC;Temp];']);
            end
        end
        
        rmdir (['..',filesep,'Masks'],'s')  % because the resliced BA mask may be wrong, so remove them before exit
        cd('..');
        save([subjdir,dirs,'_BATC.mat'],'-regexp', 'BA\w\wTC');
        clc
       fprintf('\n\n==BA Time Cources extracting: %s''s BA Time Course has been saved into:\n\n %s%s_BATC.mat\n\n',dirs,subjdir,dirs);


