function bandfiltered_full_names=FG_bandpass_filter(ADataDir,fun_imgs, ...
                                ASamplePeriod, ... 
                                ALowPass_HighCutoff, ... 
                                AHighPass_LowCutoff, ...
                                AAddMeanBack, ...
                                AMaskFilename)

  if nargin==0
        fun_imgs =  spm_select(inf,'.img|.nii','Select all the imgs having same orientation and resolution', [],pwd,'.*');
%         AMaskFilename=spm_select(1,'any','Suggest to select a non-skull whole brain mask', [],pwd,'.*nii$|.*img$');
        [a,b,c,d]=FG_separate_files_into_name_and_path(fun_imgs(1,:));
        ADataDir=a;
        prompt = {'Enter your scan TR:','Enter the low pass high-cutoff:','Enter the high pass low-cutoff:', ...
                  'Add Mean back to the images after filtering(Yes or No):'};
        dlg_title = 'Filter the images...';
        num_lines = 1;
        def = {'2','0.08','0.01','Yes'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        ASamplePeriod=str2num(answer{1});
        ALowPass_HighCutoff=str2num(answer{2});
        AHighPass_LowCutoff=str2num(answer{3});
        AAddMeanBack=answer{4};
        AMaskFilename=1;  
  end
    
    pause(0.5)
    bandfiltered_full_names=FG_rest_bandpass(ADataDir,fun_imgs, ...
                        ASamplePeriod, ALowPass_HighCutoff, AHighPass_LowCutoff, ...
                        AAddMeanBack, ...
                        AMaskFilename);

