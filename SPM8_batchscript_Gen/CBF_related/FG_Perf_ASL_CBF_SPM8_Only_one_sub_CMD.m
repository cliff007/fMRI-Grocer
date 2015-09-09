% function [] = perf_resconstruct 
%  
% This MATLAB function is to reconstruct the raw perfusion images from EPI images by the subtraction between labelled images 
% and control images. Quantified CBF images can also be reconstructed by select the option. It is based on SPM2 and 
% MATLAB 6. It is also comparable with SPM5 and Matlab7.
%    
% The MATLAB code of this function will be found in: http://cfn.upenn.edu/perfusion/software.htm
%    
% All the images are 3D SPM ANALYZE formatted (.img and .hdr). All the results are also saved in SPM ANALYZE format; 
% The labelled and control images should be the data after motion correction.
%    
% The method used here are based on the "simple subtraction", "surround subtraction" and "sinc subtraction" approaches described in
% Aguirre GK et al (2002) Experimental design and the relative sensitivity of perfusion and BOLD fMRI, NeuroImage. 15:488-500. 
%    
% BOLD data (or whatever the underlying pulse sequence that was used) are generated in addition to the perfusion data
%    
% for CASL and pCASL,
% CBF data are calculated according to the formula from
% Wang J, Alsop DC, et al. (2003) Arterial transit time imaging with flow encoding arterial spin tagging (FEAST).
% Magn Reson Med. 50:599-607. Page600, formula [1]
% CBF_CASL (ml/100g/min) = 60*100*deltaM*SE*R/(2*alp*Mo*(exp(-w*R)-exp(-(t+w)*R))
% where deltaM = raw ASL signal (Control-Label)
%        SE = blood/tissue water partition coefficient, R =longitudinal relaxation rate of blood,
%       alp = tagging efficiency, Mo =  equilibrium magnetization of brain, 
%       w = post-labeling delay, t = duration of the labeling pulse,  
% and we use the assumed parameters for calculation as SE=0.9g/ml, 
% for 3T, alp=0.68, T1b=1650ms, R=1/T1b=0.606sec-1. 
% for 1.5T, alp=0.71, T1b=1200ms, R=1/T1b=0.83sec-1.                                                      
%
% for PASL,
% CBF data are calculated according to the formula from
% Wang J, Aguirre GK, et al. (2003) Arterial Spin Labeling Perfusion fMRI With Very Low Task Frequency
% Magn Reson Med. 49:796-802. Page798, formula [1]
% CBF_PASL (ml/100g/min) = 60*100*deltaM*SE/(2*alp*Mo*t*exp(-(t+w)*R))
% where deltaM = raw ASL signal (Label-control)
%        SE = blood/tissue water partition coefficient, R =longitudinal relaxation rate of blood,
%       alp = tagging efficiency, Mo =  equilibrium magnetization of brain, 
%       w = Post Inf Sat delay, t = Post IR delay (TI1)  
% and we use the assumed parameters for calculation as SE=0.9g/ml, 
% for 3T, alp=0.68, T1b=1650ms, R=1/T1b=0.606sec-1. 
% for 1.5T, alp=0.95, T1b=1200ms, R=1/T1b=0.83sec-1.                                                      
%
%  Inputs:
%    Firstimage - integer variable indicating the type of first image 
%    - 0:control; 1:labeled 
%   Select raw images (*.img, images in a order of control1.img, label1.img, control2.img, label2.img,....;
%   or images in a order of label1.img, control1.img, label2.img, control2.img, .... )
%    
%    SubtractionType - integer variable indicating which subtraction method will be used 
%    -0: simple subtraction; 1: surround subtraction;2: sinc subtractioin.
%    for CASL, suppose Perfusion = Control - Label;
%    if the raw images is: (L1, C1, L2, C2...)
%     the simple subtraction is: (C1-L1, C2-L2...)
%     the surround subtraction is: (C1-(L1+L2)/2, C2-(L2+L3)/2,...)
%     the sinc subtraction is: (C1-L3/2, C2-L5/2...)
%
%    for PASL, suppose Perfusion = Label - Control;
%    if the raw images is: (L1, C1, L2, C2...)
%     the simple subtraction is: (L1-C1, L2-C2...)
%     the surround subtraction is: ((L1+L2)/2-C1, (L2+L3)/2-C2,...)
%     the sinc subtraction is: (L3/2-C1, L5/2-C2...)
%    
%  Outputs:
%    BOld Images: Bold_*.img,Bold_*.hdr;  Mean_Bold.img, Mean_Bold.hdr; 
%    Perfusion Images: Perf_*.img, Perf_*.hdr; Mean_Perf.img, Mean_Perf.hdr;
%    CBF Images: CBF_*.img, CBF_*.hdr; Mean_CBF.img, Mean_CBF.hdr;
%    
%  By H.Y. Rao & J.J. Wang, @CFN, UPenn Med. 07/2004.
%  Updated for SPM5 comparable 12/2009
%  Updated and Improved by Senhua Zhu 10/2010


% function perf_resconstruct(Filename, FieldStrength, ASLType, SubtractionType, SubtractionOrder, Threshold, T1B);
function [Mean_CBF_name,all_CBF_name]=FG_Perf_ASL_CBF_SPM8_Only_one_sub_CMD(SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
           SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('\nCBF calculating...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if nargin==0  % then load or enter parameters
           h_type=questdlg('What do you want to do?','Hi...','Load ASL_paras.mat','Enter Parameters','Load ASL_paras.mat');
           
           if strcmp(h_type,'Load ASL_paras.mat')
                FG_load_ASL_parameters; % open the .mat file loading window
                
             [SelfmaskedorNo,Filename,root_dir,mask_Vs,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp,T1b,R,MeanFlag,CBFFlag,ThreshFlag]= ...
             FG_check_and_fix_ASL_CBF_paras(SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp);
           elseif strcmp(h_type,'Enter Parameters')      
                %%%%%%%%%%%%%%%% parameters setup  %%%%%%%%%%%%%%%%%%% 
                   SelfmaskedorNo=questdlg('What kind of CBF calculation do you want?','Hi...','CBF','CBF-selfmasked','CBF');
                   % file selection
                        Filename=spm_select(inf,'any','Select all the ASL perfusion images that you want to deal with','',pwd,'.*img$|.*nii$');
                        if isempty(Filename), return;end
                        root_dir=spm_str_manip(Filename(1,:),'dh');

                   % selef mask file selection
                        if strcmp(SelfmaskedorNo,'CBF-selfmasked');  % default is no selfmask;  % define all the mask used to "self-mask"    
                            mask_img=spm_select(1,'any','Select a self-mask image','',pwd,'.*img$|.*nii$');  
                            mask_Vs=spm_read_vols(spm_vol(mask_img));
                        else
                            mask_Vs=[];                            
                        end  

                   % CASLmask = spm_select(1,'image','Select mask image'); 
                        FieldStrength = spm_input('Select Scanner''s field Strength', '+1', 'm',[' 3T| 1.5T'], [1 2], 1);  %  1--3T| 2--1.5T 
                        ASLType = spm_input('Select ASL Type', '+1', 'm',['pCASL| CASL| PASL'], [2 1 0], 1); %  2--pCASL| 1--CASL| 0--PASL


                         if ASLType == 0; % in this condition, it needs to respecify PASL images.
                              uiwait(msgbox('You need to have a M0 img of PASL in the subject folder. It means that the num of PASL images should be ODD (rather than EVEN) under the subject folder!','Tips....','help','modal'))
                              h_M0=questdlg('The M0 shoud be either the first one of PASL image series (Usually for the Simens-PASL sequence) or the last one!','Specify the location of M0 image...','First one','Last one','First one');
        %                           if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
        %                              PASLMo = spm_select(1,'any','Select M0 imgs', [],pwd,'.*');
        %                           else
        %                              PASLMo = spm_get(1,'*','Select PASL M0 image'); %% a special long TR img, or use the mean-control volumes instead
        %                           end;
        % 
        %                           if isempty(PASLMo) fprintf('No PASL M0 images selected!\n');
        %                               return;
        %                           end;
                         end;

                         FirstimageType = spm_input('1st-Img type','+1','m',['Control|Labeled'],[0 1], 1);
                             %  FirstimageType=1;  ----- '0-control; 1-labeled'; 
                             %  FirstimageType only affects the surround & sinc subtraction   
                             %  For the pCASL sequence, the firstimageType is always the "labeled" img
                             %  which is determined by the sequence.

                         SubtractionOrder = spm_input('Select SubtractionOrder', '+1', 'm',  ['Even-Odd(Img2-Img1)|Odd-Even(Img1-Img2)'], [0 1], 1); 
                             %SubtractionOrder=1;

                         SubtractionType = spm_input('Selct SubtractionType', '+1', 'm',  ['Simple|Surround|Sinc'], [0 1 2], 1);
                             %  SubtractionType=0;     

                         if SubtractionType==2, 			
                         	Timeshift = spm_input('Time shift of sinc interpolation', '+1', 'e', 0.5);
                         else
                            Timeshift = [];
                         end;

                         %CBFFlag = spm_input('Produce perf_resconstructtified CBF images? 0:no; 1:yes', '+1', 'e', 1);
                          CBFFlag=1;  %% sure to Produce perf_resconstructtified CBF images

                         %ThreshFlag = spm_input('Threshold EPI images? 0:no; 1:yes', '+1', 'e', 1);
                          ThreshFlag=1;  %% sure to threshold EPI images

                        if ThreshFlag==1
                            threshold =  spm_input('Input EPI Threshold value', '+1', 'e', 0.8);
                        end;
                        % absthreshold=200;

                        % MeanFlag = spm_input('Produce mean images? 0:no; 1:yes', '+1', 'e', 1);
                        MeanFlag=1;  %% sure to produce mean images

                        if CBFFlag==1,
                              if ASLType ==2 %%%%%%% pCASL
                                   Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.5);
                                   Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
                                   Slicetime = spm_input('Enter Slice acquisition time:msec', '+1', 'e', 30);
                                   alp = 0.85;   % pCasl tagging efficiency
                                   if FieldStrength == 1
                                       R = 0.606; 
                                   else
                                       R = 0.83;
                                   end;  % longitudinal relaxation rate of blood
                              elseif   ASLType ==1 %%%%%% CASL
                                   Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.6);
                                   Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
                                   Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 30);
                                   if FieldStrength == 1
                                       alp = 0.68; % Casl tagging efficiency
                                   else
                                       alp = 0.71;
                                   end;   
                                   if FieldStrength == 1
                                       R = 0.606;
                                   else
                                       R = 0.83; 
                                   end;  % longitudinal relaxation rate of blood
                              else  %%%%%%% PASL
                                   Labeltime = spm_input('Enter Post IR Delay time:sec', '+1', 'e', 0.7); % TI1
                                   Delaytime = spm_input('Enter Post Inf Sat Delay time:sec', '+1', 'e', 1.2);
                                   Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 42);
                                   alp = 0.95;   % PASL tagging efficiency
                                   if FieldStrength == 1
                                       R = 0.606; 
                                   else
                                       R = 0.83; 
                                   end;  % longitudinal relaxation rate of blood
                              end
                         end;

                        T1b = spm_input('Enter blood T1 : msec', '+1', 'e', 1650);  %you can input the updated blood T1
                        R = 1000/T1b;  % the seventh parameter: T1B

                        if ASLType ==2 % pCASL
                             alp = spm_input('Enter label efficiency', '+1', 'e', 0.85);
                        end;
                        
                        
                        ASL_paras=struct( ...
                        'SelfmaskedorNo',SelfmaskedorNo, ...
                        'Filename',Filename, ...
                        'root_dir',root_dir, ...
                        'mask_Vs',mask_Vs, ...
                        'FieldStrength',FieldStrength, ...
                        'ASLType',ASLType, ...
                        'FirstimageType',FirstimageType, ...
                        'SubtractionType',SubtractionType, ...
                        'SubtractionOrder',SubtractionOrder, ...                        
                        'Labeltime',Labeltime, ...
                        'Delaytime',Delaytime, ...
                        'Slicetime',Slicetime, ...            
                        'h_M0',h_M0, ... 
                        'Timeshift',Timeshift, ... 
                        'threshold',threshold, ... 
                        'alp',alp, ... 
                        'T1b',T1b, ...
                        'R',R, ...
                        'MeanFlag',MeanFlag, ...
                        'CBFFlag',CBFFlag, ...
                        'ThreshFlag',ThreshFlag);
                         
                        savefolder=spm_select(1,'dir','Select a foler to save the parameter variables');
                        fileout=fullfile(savefolder, 'ASL_paras.mat');
                        save (fileout, 'ASL_paras' ); 
                %%%%%%%%%%%%%%%% parameters setup is done %%%%%%%%%%%%%%%%%%%
           end
           
        elseif nargin==1 % then treat the only varargin as a parameter file name
            FG_load_ASL_parameters(para_file);
            
             [SelfmaskedorNo,Filename,root_dir,mask_Vs,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp,T1b,R,MeanFlag,CBFFlag,ThreshFlag]= ...
             FG_check_and_fix_ASL_CBF_paras(SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp);
         
%              mask_Vs=spm_read_vols(spm_vol(self_maskimg));
        elseif nargin>1  % then treat the varargins as the input-ASL-parameters
            % check the inputs and reload the necessary outputs for the
            % following cbf calculation
            [SelfmaskedorNo,Filename,root_dir,mask_Vs,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp,T1b,R,MeanFlag,CBFFlag,ThreshFlag]= ...
             FG_check_and_fix_ASL_CBF_paras(SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
             SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp);
         
%              mask_Vs=spm_read_vols(spm_vol(self_maskimg));
        end
  
        
    %%%%%%%%%%%%%%%% the main program,, start calculation  %%%
    

    [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Perf Reconstruct',0);
    spm('FigName','Perf Reconstruct: working',Finter,CmdLine);
    spm('Pointer','Watch')

    %%% repecify M0 and PASL images for the following calculating...
        if ASLType == 0;  % PASL
              if mod(size(Filename,1),2)==0
                 h_sure=questdlg('The PASL-image num (should be ODD) of the first subj is EVEN , are you sure there is a M0 under the subj folder?','Warning...','No','Sure','No');
                 if strcmp(h_sure,'No')
                     return
                 end
              end     
              
           if strcmp(h_M0,'First one')
              PASLMo = deblank(Filename(1,:));
              Filename = Filename(2:end,:);

           elseif strcmp(h_M0,'Last one')
              PASLMo = deblank(Filename(end,:));
              Filename = Filename(1:end-1,:);  
           end
        end;
    

    % Map images
    V=spm_vol(deblank(Filename)); % what kind of situation will cause this "deblank" necessity?
    %if there are warnings like "Warning: Cant get default Analyze orientation - assuming flipped" appear, that is right. 
    % We are exactly using the %SPM Analyze, not FSL.

    if ASLType==0, 
         VMo = spm_vol(deblank(PASLMo)); 
         PASLModat = zeros([VMo.dim(1:2) 1]);
    end;

     if isempty(V), fprintf('no raw img files was selected'); return; end;
     if rem(length(V),2)==1, warning('the number of raw img files is not even, last img is ignored'); end;
     perfnum=fix(length(V)/2); 

    % Create output images...
    % cliff: revised the CBF maps naming rules
%     VO = V(1:perfnum);
%     VB = V(1:perfnum);
%     VCBF=V(1:perfnum);
    VO = V(1:2:2*perfnum);
    VB = V(1:2:2*perfnum);
    VCBF=V(1:2:2*perfnum);  
    
    VMP = V(1);
    VMCBF = V(1);
    VMC = V(1); 
    
      all_CBF_name=[] ;  % for function output     
      for k=1:perfnum, %cliff
            [pth,nm,xt,vr] = fileparts(deblank(V(2*k-1).fname)); % cliff revised

             if SubtractionType==0, 
             VO(k).fname = fullfile(pth,['Perf_0' nm xt vr]);
             if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_0_' nm xt vr]);end;
            end;

            if SubtractionType==1, 
             VO(k).fname = fullfile(pth,['Perf_1' nm xt vr]);
             if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_1_' nm xt vr]);end;
            end;

            if SubtractionType==2, 
             VO(k).fname = fullfile(pth,['Perf_2' nm xt vr]);
             if CBFFlag==1, VCBF(k).fname = fullfile(pth,['CBF_2_' nm xt vr]);end;
            end;

            VB(k).fname    = fullfile(pth,['Bold_' nm xt vr]);
            all_CBF_name=strvcat(all_CBF_name,VCBF(k).fname) ;  % for function output
      end;
      
% cliff
      for k=1:perfnum,
   %            VO(k)  = spm_create_vol(VO(k));
   %            VB(k)  = spm_create_vol(VB(k));
               VCBF(k)  = spm_create_vol(VCBF(k));
              if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8') |strcmp(spm('ver',[],1),'SPM12')  
                VO(k).dt=[16,0]; VB(k).dt=[16,0]; VCBF(k).dt =[16,0];  %'float' type
             else
               VO(k).dim(4) = 16; VB(k).dim(4) = 16; VCBF(k).dim(4) = 16; %'float' type
              end;
      end;

    cdat = zeros([VO(1).dim(1:3) perfnum]);
    ldat = zeros([VO(1).dim(1:3) perfnum]);
    pdat = zeros([VO(1).dim(1:3) perfnum]);
    bdat = zeros([VB(1).dim(1:3) perfnum]);

    linear_cdat=zeros([VB(1).dim(1:3) 2*perfnum]);
    linear_ldat=zeros([VB(1).dim(1:3) 2*perfnum]);
    sinc_ldat=zeros([VB(1).dim(1:3) 2*perfnum]);
    sinc_cdat=zeros([VB(1).dim(1:3) 2*perfnum]);


    %-Start progress plot
    %-----------------------------------------------------------------------
    spm_progress_bar('Init',perfnum,'Perf Reconstruct','Images completed');

    % read raw data
    dat = spm_read_vols(V);
    threshvalue = zeros(1,length(V));

    % threshold the EPI images 
    
    if strcmp(SelfmaskedorNo,'CBF-selfmasked')  % cliff add self-mask
        Mask=double(logical(mask_Vs));% cliff add
    elseif strcmp(SelfmaskedorNo,'CBF')
        Mask=ones(V(1).dim(1:3));
    end
         
    % read the Mo data for PASL
      if ASLType==0;
        PASLModat = spm_read_vols(VMo); 
        Mask = Mask.*(PASLModat>threshold*mean(mean(mean(PASLModat))));
      end;

      if ThreshFlag ==1,
       for k=1:size(V,1),
         Mask = Mask.*(dat(:,:,:,k)>threshold*mean(mean(mean(dat(:,:,:,k)))));
         threshvalue(1, k) = max(100, threshold*mean(mean(mean(dat(:,:,:,k)))));
    %     Mask = Mask.*(dat(:,:,:,k)>absthreshold);
       end;
      end;


     for k=1:size(V,1),
    %    datamk= spm_read_vols(V(k));
    %   datamk = datamk.*Mask;
        dat(:,:,:,k) = dat(:,:,:,k).*Mask; 
     end;

    % define the control and label images...
     for k=1:size(V,1),
      if SubtractionOrder==0, 
          if rem(k,2)== 1, ldat(:,:,:,(k+1)/2) = dat(:,:,:,k); end;
          if rem(k,2)== 0, cdat(:,:,:,k/2) = dat(:,:,:,k); end;
      end;
      if SubtractionOrder==1, 
          if rem(k,2)== 1, cdat(:,:,:,(k+1)/2) = dat(:,:,:,k); end;
          if rem(k,2)== 0, ldat(:,:,:,k/2) = dat(:,:,:,k); end;
      end;
     end;


     % obtained BOLD data
     for k=1:perfnum,
      bdat(:,:,:,k) = (dat(:,:,:,2*k-1) + dat(:,:,:,2*k))/2;
     end;

     % do the simple subtraction...
    if SubtractionType==0,
      for k=1:perfnum,
        pdat(:,:,:,k) = cdat(:,:,:,k) - ldat(:,:,:,k);
      end;
     spm_progress_bar('Set',k);
    end;

      % do the linear interpolation...
      if SubtractionType==1,
         pnum=1:perfnum;
         lnum=1:0.5:perfnum;
         for x=1:V(1).dim(1),
          for y=1:V(1).dim(2),
           for z=1:V(1).dim(3),
            cdata = zeros(1,perfnum);
            ldata = zeros(1,perfnum);
            linear_cdata = zeros(1,length(V));
            linear_ldata = zeros(1,length(V));
             for k=1:perfnum, 
              cdata(k) = cdat(x,y,z,k);
              ldata(k) = ldat(x,y,z,k);
             end;
             linear_cdata=interp1(pnum,cdata,lnum);
             linear_ldata=interp1(pnum,ldata,lnum);
             for k=1:2*perfnum-1, 
              linear_cdat(x,y,z,k)= linear_cdata(k);
              linear_ldat(x,y,z,k)= linear_ldata(k);
             end;
            end; 
           end; 
          end; 


         % do the surround subtraction....
         if FirstimageType ==1;        %%%%  FirstimageType only affect the surround & sinc subtraction
              pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
              spm_progress_bar('Set',1);
            for k=2:perfnum, 
              pdat(:,:,:,k) = linear_cdat(:,:,:,2*(k-1)) - ldat(:,:,:,k);
              spm_progress_bar('Set',k);
            end;
         end;
         if FirstimageType ==0; 
              pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
              spm_progress_bar('Set',1);
           for k=2:perfnum, 
              pdat(:,:,:,k) = cdat(:,:,:,k) - linear_ldat(:,:,:,2*(k-1));
              spm_progress_bar('Set',k);
            end;
         end;
    end;


     % do the sinc interpolation...
      if SubtractionType==2,
         for x=1:V(1).dim(1),
           for y=1:V(1).dim(2),
             for z=1:V(1).dim(3),
               cdata = zeros(1,perfnum);
               ldata = zeros(1,perfnum);
               sinc_cdata = zeros(1,length(V));
               sinc_ldata = zeros(1,length(V));
               for k=1:perfnum, 
                 cdata(k) = cdat(x,y,z,k);
                 ldata(k) = ldat(x,y,z,k);
               end;
               sincnum = fix(perfnum/Timeshift);
               sinc_cdata=interpft(cdata,sincnum);
               sinc_ldata=interpft(ldata,sincnum);
               for k=1:2*perfnum, 
                sinc_cdat(x,y,z,k)= sinc_cdata(k);
                sinc_ldat(x,y,z,k)= sinc_ldata(k);
               end;
             end;  
           end;
         end;

          % do the sinc subtraction....
             if FirstimageType ==1; 
              pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
                 for k=2:perfnum, 
                   pdat(:,:,:,k) = sinc_cdat(:,:,2*(k-1)) - ldat(:,:,k);
                   spm_progress_bar('Set',k);
                 end;
              end;
             if FirstimageType ==0; 
               pdat(:,:,:,1) = cdat(:,:,:,1) - ldat(:,:,:,1);
                 for k=2:perfnum, 
                   pdat(:,:,:,k) = cdat(:,:,:,k) - sinc_ldat(:,:,:,2*(k-1));
                   spm_progress_bar('Set',k);
               end;
             end;
      end;      

% cliff
     % Write Bold and perfusion image...
   %    for k=1:perfnum,
   %       VO(k) = spm_write_vol(VO(k),pdat(:,:,:,k));
   %       VB(k) = spm_write_vol(VB(k),bdat(:,:,:,k));
   %    end;


     % calculated the mean image...
      if MeanFlag ==1,
        Mean_dat=zeros([V(1).dim(1:3)]);
        VMP.fname = fullfile(pth,['Mean_Perf' nm(1:5) xt vr]);
        VMP = spm_create_vol(VMP);
        if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8') |strcmp(spm('ver',[],1),'SPM12') 
           VMP.dt=[16,0];   %'float' type
          else
          VMP.dim(4) = 16; %'float' type
        end;

        for x=1:V(1).dim(1),
           for y=1:V(1).dim(2),
             for z=1:V(1).dim(3),
              Mean_dat(x,y,z) = mean(pdat(x,y,z,:));
             end;
           end;
        end;
% cliff
        % Write mean perfusion image...
           VMP = spm_write_vol(VMP,Mean_dat);
      end;


      % calculated the CBF image...
      if CBFFlag ==1,

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       spm_progress_bar('Clear')

      [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Perf Reconstruct',0);
      spm('FigName','CBF Reconstruct: working',Finter,CmdLine);
      spm('Pointer','Watch')
      %-----------------------------------------------------------------------
      spm_progress_bar('Init',perfnum,'CBF Reconstruct','Images completed');

         cbfdat = zeros([VO(1).dim(1:3), perfnum]);
         cmean_dat = zeros([VO(1).dim(1:3)]);

         for x=1:V(1).dim(1),
           for y=1:V(1).dim(2),
             for z=1:V(1).dim(3),
              cmean_dat(x,y,z) = mean(cdat(x,y,z,:));
             end;
           end;
         end;
% cliff
         % Write mean BOLD/Control image...
       if MeanFlag ==1,
         VMC.fname = fullfile(pth,['Mean_BOLD' nm(1:5) xt vr]);
         VMC = spm_create_vol(VMC);
         if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8') |strcmp(spm('ver',[],1),'SPM12')    
                VMC.dt=[16,0];   %'float' type
          else
            VMC.dim(4) = 16; %'float' type
           end;

         VMC = spm_write_vol(VMC,cmean_dat);
       end;

         for k=1:perfnum, 
           for x=1:V(1).dim(1),
           for y=1:V(1).dim(2),
           for z=1:V(1).dim(3),
            Dtime = Delaytime + Slicetime*z/1000;

            if ASLType ==2   % pCASL
             if cmean_dat(x,y,z)<mean(threshvalue)
              cbfdat(x,y,z,k)=0;
             else
              cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)*R/alp/((exp(-Dtime*R)-exp(-(Dtime+Labeltime)*R))*cmean_dat(x,y,z));
             end;
            end;

            if ASLType ==1   % CASL
             if cmean_dat(x,y,z)<mean(threshvalue)
              cbfdat(x,y,z,k)=0;
             else
              cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)*R/alp/((exp(-Dtime*R)-exp(-(Dtime+Labeltime)*R))*cmean_dat(x,y,z));
             end;
            end;

            if ASLType ==0  %PASL
             if (PASLModat(x,y,z)<mean(threshvalue) | cmean_dat(x,y,z)<mean(threshvalue))
              cbfdat(x,y,z,k)=0;
             else
              cbfdat(x,y,z,k) = 2700*pdat(x,y,z,k)/Labeltime/alp/(exp(-(Dtime+Labeltime)*R)*PASLModat(x,y,z));
             end;
            end;

           end;
           end;
           end;
% cliff
          % Write CBF images...
          VCBF(k) = spm_write_vol(VCBF(k),cbfdat(:,:,:,k));
          spm_progress_bar('Set',k);
          
         end;


        if MeanFlag ==1,
         Mean_cbfdat=zeros([VO(1).dim(1:3)]);
         VMCBF.fname = fullfile(pth,['Mean_CBF' nm(1:5) xt vr]);
         VMCBF = spm_create_vol(VMCBF);
          if strcmp(spm('ver',[],1),'SPM5') |strcmp(spm('ver',[],1),'SPM8')  
            VMCBF.dt=[16,0];   %'float' type
          else
            VMCBF.dim(4) = 16; %'float' type
           end;

        voxelnum=0;
        zeronum=0;
        globalCBF=0;
        meancontrol=0;

         for x=1:V(1).dim(1),
           for y=1:V(1).dim(2),
             for z=1:V(1).dim(3),
                Mean_cbfdat(x,y,z) = mean(cbfdat(x,y,z,:));
                if Mean_cbfdat(x,y,z) ==0,  
                  zeronum = zeronum+1;
                else
                  voxelnum = voxelnum+1;
                  globalCBF = globalCBF+Mean_cbfdat(x,y,z);
                  meancontrol = meancontrol+cmean_dat(x,y,z); 
                end;
             end;
           end;
         end;

       globalCBF = globalCBF/voxelnum;
       meancontrol = meancontrol/voxelnum;
% cliff
         % Write mean CBf image...
         VMCBF = spm_write_vol(VMCBF, Mean_cbfdat);
        end;

    end;

    
     Mean_CBF_name=VMCBF.fname;  % for function output
     all_CBF_name=VCBF(k) ;  % for function output
     gcbf = spm_global(VMCBF);
     gbold = spm_global(VMC);
     
   % save globalCBF globalCBF %EDIT(H)
          output_name='Output_description.txt';
          dlmwrite(fullfile(pth,output_name), [pth, '-------------- Output description ------------'], 'delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), '====[1]. Perfusion images output =================', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), 'Perfusion images are written to: ', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VO(1).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '          ...', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VO(perfnum).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
      if MeanFlag ==1, 
          dlmwrite(fullfile(pth,output_name), 'Mean_perf image is written to: ', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VMP.fname, '-append','delimiter', '','newline','pc');
      end;  

          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row

          dlmwrite(fullfile(pth,output_name), '====[2]. BOLD images output ================', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), 'BOLD images are written to: ', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VB(1).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '          ...', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VB(perfnum).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row

      if MeanFlag ==1, 
          dlmwrite(fullfile(pth,output_name), 'Mean_BOLD image is written to: ', '-append','delimiter', '','newline','pc','newline','pc');
          dlmwrite(fullfile(pth,output_name), VMC.fname, '-append','delimiter', '','newline','pc','newline','pc');  
      end;  
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
      if CBFFlag ==1, 
          dlmwrite(fullfile(pth,output_name), '====[3]. Quantified CBF images output ================', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), 'Quantified CBF images are written to: ', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VCBF(1).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '          ...', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VCBF(fix(length(VCBF)/2)).fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), 'Mean Quantified CBF image is written to: ', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), VMCBF.fname, '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row

          dlmwrite(fullfile(pth,output_name), '====[4]. The caculation index summary ================', '-append','delimiter', '','newline','pc');
          dlmwrite(fullfile(pth,output_name), 'the spm global mean BOLD control signal is:  ', '-append','delimiter', '');
          dlmwrite(fullfile(pth,output_name), gbold, '-append','delimiter', '','precision', '%2.2f', 'newline','pc');
          dlmwrite(fullfile(pth,output_name), 'the spm global mean CBF signal is:           ', '-append','delimiter', '');
          dlmwrite(fullfile(pth,output_name), gcbf, '-append','delimiter', '','precision', '%2.2f');
          dlmwrite(fullfile(pth,output_name), '  .....ml/100g/min', '-append','delimiter', '', 'newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), 'the calculated voxel number is:      ', '-append','delimiter', '');
          dlmwrite(fullfile(pth,output_name), voxelnum, '-append','delimiter', '', 'newline','pc');
          dlmwrite(fullfile(pth,output_name), 'the zero number is:                  ', '-append','delimiter', '');
          dlmwrite(fullfile(pth,output_name), zeronum, '-append','delimiter', '', 'newline','pc');
          dlmwrite(fullfile(pth,output_name), '  ', '-append','delimiter', '','newline','pc');% blank row
          dlmwrite(fullfile(pth,output_name), 'the global mean BOLD control signal is:      ', '-append','delimiter', '');       
          dlmwrite(fullfile(pth,output_name), meancontrol, '-append','delimiter', '','precision', '%2.2f', 'newline','pc');
          dlmwrite(fullfile(pth,output_name), 'the global mean CBF signal is:               ', '-append','delimiter', '');       
          dlmwrite(fullfile(pth,output_name), globalCBF, '-append','delimiter', '','precision','%2.2f');     
          dlmwrite(fullfile(pth,output_name), '  .....ml/100g/min', '-append','delimiter', '', 'newline','pc');  
          % parameters output and write
          FG_ASL_CBF_parameters_output(FieldStrength,ASLType,FirstimageType,SubtractionOrder,SubtractionType,threshold,Labeltime,Delaytime,Slicetime,T1b,alp,pth,output_name);
          
          

         fprintf('\n\nResults Summary of:  %s  ...\n',pth)
             fprintf('---- You can find more details in the: %s : under each subject''s directory ----\n\n',output_name)
         fprintf('\t the spm global mean BOLD control signal is:')
         fprintf('\t %6.2f \n',gbold)
         fprintf('\t the spm global mean CBF signal is:         ')
         fprintf('\t %6.3f  ....ml/100g/min   \n\n',gcbf)

         fprintf('\t the global mean BOLD control signal is:    ')
         fprintf('\t %6.2f \n',meancontrol)
         fprintf('\t the global mean CBF signal is:             ')
         fprintf('\t %6.3f  ....ml/100g/min \n\n\n',globalCBF)

      end;  

     % spm_progress_bar('Clear')
     close;
     
 %%%% an extra enhanced MeanCBF denoising procedure      
       movefil=spm_select('FPList', root_dir, ['^rp_\w*\.txt$']);
       if ~isempty(movefil) && size(movefil,1)==1    
           if ~exist('FG_outlier_clean_after_CBF','file')
               sprintf('There is not "FG_outlier_clean_after_CBF.m" function, skip CBF outlier cleaning!')
           end
             % get all the original CBFs
             CBF_files=spm_select('FPList', root_dir, '^CBF.*.img$|^CBF.*.nii$');
             % run outlier cleaning to get a outlier-reduced meanCBF img
             FG_outlier_clean_after_CBF(CBF_files,root_dir);
       else
            fprintf('\nMotion-file (rp*.txt) is non-existed or more than one, so skip to create Mean_corred_CBF_*.nii\n')            
       end   % return when there are no rp*.txt file
    
 fprintf('\n\n\n----- CBF calculation of this subject is done---------\n')

 spm('Pointer');
% [Finter,Fgraph,CmdLine]=spm('FigName','CBFReconstruct done',Finter,CmdLine);
 
