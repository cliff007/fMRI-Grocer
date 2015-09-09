function  [SelfmaskedorNo,Filename,root_dir,mask_Vs,FieldStrength,ASLType,FirstimageType, ...
           SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp, ...
           T1b,R,MeanFlag,CBFFlag,ThreshFlag] ...
      = FG_check_and_fix_ASL_CBF_paras( ...
           SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType, ...
           SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp)  
% example: 
% [SelfmaskedorNo,Filename,self_maskimg,FieldStrength,ASLType,FirstimageType,SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp,T1b,R,MeanFlag,CBFFlag,ThreshFlag]=FG_check_and_load_ASL_CBF_defaults('CBF-selfmasked',Filename,self_maskimg,1,2,0,0,0,1.5,1.2,30,'','','','') 
% If you some variables need to be decided in the function, use empty ('') instead
%                 if FieldStrength==1
%                    FieldS='FieldStrength: 3T';
%                 elseif FieldStrength==2
%                    FieldS='FieldStrength: 1.5T'; 
%                 end
% 
%                 if ASLType==2
%                    ASLT='ASLType: pcasl';
%                 elseif ASLType==1
%                    ASLT='ASLType: casl'; 
%                 elseif ASLType==0
%                    ASLT='ASLType: pasl'; 
%                 end
% 
% 
%                 if FirstimageType==0
%                    FirstimageT='FirstimageType: control';
%                 elseif FirstimageType==1
%                    FirstimageT='FirstimageType: labeled' ;
%                 end
% 
% 
%                 if SubtractionOrder==0
%                    SubtractionO='SubtractionOrder: Even-Odd(Img2-Img1)';
%                 elseif SubtractionOrder==1
%                    SubtractionO='SubtractionOrder: Odd-Even(Img1-Img2)'; 
%                 end
% 
% 
%                 if SubtractionType==0
%                    SubtractionT='SubtractionType: Simple';
%                 elseif SubtractionType==1
%                    SubtractionT='SubtractionType: Surround' ;
%                 elseif SubtractionType==2
%                    SubtractionT='SubtractionType: Sinc';   
%                 end

%          Filename=spm_select(inf,'any','Select all the fun-images','',pwd,'.*img$|.*nii$');
%          maskimg=spm_select(inf,'any','Select all the fun-images','',pwd,'.*img$|.*nii$');
%          self_maskimg=spm_select(inf,'any','Select all the fun-images','',pwd,'.*img$|.*nii$');
   
    vars_in={ 
            'SelfmaskedorNo' ...
        'Filename' ...
        'self_maskimg' ...
            'FieldStrength' ...
            'ASLType' ...
            'FirstimageType' ...
            'SubtractionType' ...
            'SubtractionOrder' ...                        
            'Labeltime' ...
            'Delaytime' ...
            'Slicetime' ...            
        'h_M0','Timeshift', 'threshold','alp'           
            };  % the last four variables are optional
        %

        
     if any(~cellfun(@(x) exist(x,'var'),vars_in)), % if any vars_in is existed:  ANY: True if any element of a vector is a nonzero number
         fprintf('\nNot enough inputs! Please check it out!\n'),
         return;
     end    
     
     if any(cellfun(@isempty,vars_in(1,4:11))), % if any critical vars_in is empty:  ANY: True if any element of a vector is a nonzero number
         fprintf('\nSome of the critical input variables (the first 12 vars) that needs to be predefined is empty! Please check it out!\n'),
         return;
     end 
     
   
     if isempty(Filename)
           % file selection
        Filename=spm_select(inf,'any','Select all the fun-images','',pwd,'.*img$|.*nii$');
        if isempty(Filename), return;end        
     end
     root_dir=spm_str_manip(Filename(1,:),'dh');
    
   mask_Vs=[];  
   % self mask file selection
     if isempty(self_maskimg)
        if strcmp(SelfmaskedorNo,'CBF-selfmasked');  % default is no selfmask;  % define all the mask used to "self-mask"    
            self_maskimg=spm_select(1,'any','Select a mask image','',pwd,'.*img$|.*nii$');  
            mask_Vs=spm_read_vols(spm_vol(self_maskimg));
        end   
     else
        mask_Vs=spm_read_vols(spm_vol(self_maskimg)); 
     end        
     
     
 %%%%%%%%%%%%%%%% parameters setup  %%%%%%%%%%%%%%%%%%%   
    if ASLType == 0; % in this condition, it needs to select PASL reference-images.
           if  ~exist('h_M0','var')  || isempty(h_M0)
              fprintf('\nPASLMo is non-given! Specify h_M0 instead...'),  
              uiwait(msgbox('You need to have a M0 img of PASL in the subject folder. It means that the num of PASL images should be ODD (rather than EVEN) under the subject folder!','Tips....','help','modal'))
              h_M0=questdlg('The M0 shoud be either the first one of PASL image series (Usually for the Simens-PASL sequence) or the last one!','Specify the location of M0 image...','First one','Last one','First one');
%               if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
%                  PASLMo = spm_select(1,'any','Select M0 imgs', [],pwd,'.*');
%               else
%                  PASLMo = spm_get(1,'*','Select PASL M0 image'); %% a special long TR img, or use the mean-control volumes instead
%               end;
% 
%               if isempty(PASLMo) fprintf('No PASL M0 images selected!\n');
%                   return;
%               end;
           else
               fprintf('\nUse predefined PASLMo: %s  ...',h_M0)
           end
     end;

     if SubtractionType==2, 
        if  ~exist('Timeshift','var') || isempty(Timeshift)
            Timeshift = 0.5;
            fprintf('\nDefault Time shift of sinc interpolation is 0.5');
        else
            fprintf('\nUse predefined Timeshift: %d ...',Timeshift)
        end
     end;

     CBFFlag=1;  %% sure to Produce perf_resconstructtified CBF images
     ThreshFlag=1;  %% sure to threshold EPI images

    if ThreshFlag==1
        if  ~exist('threshold','var') || isempty(threshold)
            threshold = 0.8;
            fprintf('\nDefault EPI Threshold value is 0.8');
        else
            fprintf('\nUse predefined threshold: %d  ...',threshold)
        end
    end;

    MeanFlag=1;  %% sure to produce mean images

    if CBFFlag==1,
          if ASLType ==2 %%%%%%% pCASL
%                Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.5);
%                Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
%                Slicetime = spm_input('Enter Slice acquisition time:msec', '+1', 'e', 30);
             if  ~exist('alp','var')  || isempty(alp) 
                   alp = 0.85;
                   fprintf('\nDefault label efficiency of pCASL is 0.85');
             else
                   fprintf('\nUse predefined label efficiency of pCASL (alp): %d ...',alp)
             end

               if FieldStrength == 1
                   R = 0.606; 
               else
                   R = 0.83;
               end;  % longitudinal relaxation rate of blood
          elseif   ASLType ==1 %%%%%% CASL
%                Labeltime = spm_input('Enter Label time:sec', '+1', 'e', 1.6);
%                Delaytime = spm_input('Enter Delay time:sec', '+1', 'e', 1.2);
%                Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 30);

               if FieldStrength == 1
                   if ~exist('alp','var')  || isempty(alp) 
                       alp = 0.68; % Casl tagging efficiency
                       fprintf('\nDefault label efficiency of pCASL is 0.68')
                   else
                       fprintf('\nUse predefined label efficiency of pCASL (alp) ...')
                   end
               else
                   if ~exist('alp','var')  || isempty(alp) 
                       alp = 0.71; % Casl tagging efficiency
                       fprintf('\nDefault label efficiency of pCASL is 0.71')
                   else
                       fprintf('\nUse predefined label efficiency of pCASL (alp) ...')
                   end
               end;   
               
               if FieldStrength == 1
                   R = 0.606;
               else
                   R = 0.83; 
               end;  % longitudinal relaxation rate of blood
               
          else  %%%%%%% PASL
%                Labeltime = spm_input('Enter Post IR Delay time:sec', '+1', 'e', 0.7); % TI1
%                Delaytime = spm_input('Enter Post Inf Sat Delay time:sec', '+1', 'e', 1.2);
%                Slicetime = spm_input('Enter slice acquisition time:msec', '+1', 'e', 42);
               alp = 0.95;   % PASL tagging efficiency
               if FieldStrength == 1
                   R = 0.606; 
               else
                   R = 0.83; 
               end;  % longitudinal relaxation rate of blood
          end
     end;

    T1b = 1650;
    fprintf('\nT1b: the blood T1 is 1650 ...\n');
    R = 1000/T1b;  

%     tem=struct( ...
%             'SelfmaskedorNo',SelfmaskedorNo, ...
%             'Filename',Filename, ...
%             'self_maskimg',self_maskimg, ...
%             'FieldStrength',FieldStrength, ...
%             'ASLType',ASLType, ...
%             'FirstimageType',FirstimageType, ...
%             'SubtractionType',SubtractionType, ...
%             'SubtractionOrder',SubtractionOrder, ...                        
%             'Labeltime',Labeltime, ...
%             'Delaytime',Delaytime, ...
%             'Slicetime',Slicetime, ...            
%             'h_M0',h_M0, ... 
%             'Timeshift',Timeshift, ... 
%             'threshold',threshold, ... 
%             'alp',alp ...     
%             );    

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameters setup is done

fprintf('\n--------Paras checking of ASL-CBF calculation is done............\n');
    
    
    
