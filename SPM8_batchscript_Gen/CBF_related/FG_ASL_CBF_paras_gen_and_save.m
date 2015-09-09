
function varargout=FG_ASL_CBF_paras_gen_and_save(Temporal_ASL_setting)

%%% critical parameters that need to be setup one by one yourself
%%%%%%%%%%%%%%%% parameters setup  %%%%%%%%%%%%%%%%%%%  
SelfmaskedorNo=[];
Filename=[];
self_maskimg=[];
FieldStrength=[];
ASLType=[];
FirstimageType=[];
SubtractionType=[];
SubtractionOrder=[];
Labeltime=[];
Delaytime=[];
Slicetime=[];
h_M0=[];
Timeshift=[];
threshold=[];
alp=[];

                
                    
                    SelfmaskedorNo=questdlg('What kind of CBF calculation do you want to do?','Hi...','CBF','CBF-selfmasked','CBF');
                    if isempty(SelfmaskedorNo), return;end
                    
                    
                if ~strcmp(Temporal_ASL_setting,'IsTemp')    % only do this when it is a independent usage, if it is called within a function, you should skip these two steps
                   % file selection
                        Filename=spm_select(inf,'any','[optional:]Select all the ASL perfusion images you want to deal with','',pwd,'.*img$|.*nii$');

                   % selef mask file selection
                        if strcmp(SelfmaskedorNo,'CBF-selfmasked');  % default is no selfmask;  % define all the mask used to "self-mask"    
                            self_maskimg=spm_select(1,'any','[optional:]Select a self-mask image','',pwd,'.*img$|.*nii$');  
                        end  
                end

                   % CASLmask = spm_select(1,'image','Select mask image'); 
                        FieldStrength = spm_input('Select Scanner''s field Strength', '+1', 'm',[' 3T| 1.5T'], [1 2], 1);  %  1--3T| 2--1.5T 
                        ASLType = spm_input('Select ASL Type', '+1', 'm',['pCASL| CASL| PASL'], [2 1 0], 1); %  2--pCASL| 1--CASL| 0--PASL


                         if ASLType == 0; % in this condition, it needs to select PASL reference-images.
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
                %%%%%%%%%%%%%%%% parameters setup is done %%%%%%%%%%%%%%%%%%%      
    
    

      ASL_paras=struct( ...
            'SelfmaskedorNo',SelfmaskedorNo, ...
            'Filename',Filename, ...
            'self_maskimg',self_maskimg, ...
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
        
        if nargout==1
            varargout(1)={fileout};
        elseif nargout==2
            varargout(1)={fileout};
            varargout(2)={SelfmaskedorNo};
        end
    
        fprintf('\n------the parameter file of ASL-CBF calculation has been saved into %s\n',fileout)
