function FG_batch_resliceImg(PI,PO,NewVoxSize,hld, TargetSpace)
clc
% h=questdlg('Two ways to do this: the first one is based on independent codes, the second one is based on imgcal of SPM!','Choose one method...','1st one','2nd one','2nd one') ;
% if isempty(h)
%     return
% end
% 
% switch h
%     case '1st one'
% 
%         % FORMAT rest_ResliceImage(PI,PO,NewVoxSize,hld, TargetSpace)
%         %   PI - input filename
%         %   PO - output filename
%         %   NewVoxSize - 1x3 matrix of new vox size.
%         %   hld - interpolation method. 0: Nearest Neighbour. 1: Trilinear.
%         %   TargetSpace - Define the target space. 'ImageItself': defined by the image itself (corresponds  to the new voxel size); 'XXX.img': defined by a target image 'XXX.img' (the NewVoxSize parameter will be discarded in such a case).
%         %   Example: FG_y_Reslice('D:\Temp\mean.img','D:\Temp\mean3x3x3.img',[3 3 3],1,'ImageItself')
%         %       This was used to reslice the source image 'D:\Temp\mean.img' to a
%         %       resolution as 3mm*3mm*3mm by trilinear interpolation and save as 'D:\Temp\mean3x3x3.img'.
%         %__________________________________________________________________________
%         % Written by YAN Chao-Gan 090302 for DPARSF. Referenced from SPM5.
%         % State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%         % ycg.yan@gmail.com
%         %__________________________________________________________________________
%         % Last Revised by YAN Chao-Gan 100401. Fixed a bug while calculating the new dimension.
% 
%         inImg = spm_select(Inf,'any','Select images to be read', [],pwd,'.*nii$|.*img$');
%         if isempty(inImg)
%             return
%         end
%         TargetSpace = spm_select(1,'any','Select an img to define the target space', [],pwd,'.*nii$|.*img$');
%         if isempty(TargetSpace)
%             return
%         end
% 
%         h=questdlg('What kind of interpolation method do you want to use?','Interpolation method','For Binary mask','For normal images','For Binary mask');
%         if strcmp(h,'For Binary mask')
%             hld=0; % hld - interpolation method. 0: Nearest Neighbour(used for binary mask). 1: Trilinear(used for normal images).
%         else
%             hld=1;
%         end
% 
%         for i=1:size(inImg,1)
%             PI=inImg(i,:)
%             [pth1,Name1,Ext1,Versn1] = fileparts(deblank(PI));   
% 
%             if ~isempty(TargetSpace)
%                 Vmat_in=spm_vol(deblank(PI));% cliff, add 
%                 Vmat_ref=spm_vol(deblank(TargetSpace));
% 
%                 if Vmat_in.dim == Vmat_ref.dim
%                     TargetSpace='ImageItself';
%                 end
%             end
% 
%          % we are not more call this function directly
%            % if nargin<=4
%            %     TargetSpace='ImageItself';
%            % end
% 
% 
%             if ~strcmpi(TargetSpace,'ImageItself')   % reslice into a target space with the target NewVoxSize
%                 [dataIN, headIN]   = FG_rest_ReadNiftiImage(TargetSpace);
%                 mat=headIN.mat;
%                 dim=headIN.dim;
% 
%             else   % reslice into a specific NewVoxSize under the original space
%                 [dataIN, headIN]   = FG_rest_ReadNiftiImage(PI);
%                 origin=headIN.mat(1:3,4);
%                 origin=origin+[headIN.mat(1,1);headIN.mat(2,2);headIN.mat(3,3)]-[NewVoxSize(1)*sign(headIN.mat(1,1));NewVoxSize(2)*sign(headIN.mat(2,2));NewVoxSize(3)*sign(headIN.mat(3,3))];
%                 origin=round(origin./NewVoxSize').*NewVoxSize';
%                 mat = [NewVoxSize(1)*sign(headIN.mat(1,1))                 0                                   0                       origin(1)
%                     0                         NewVoxSize(2)*sign(headIN.mat(2,2))              0                       origin(2)
%                     0                                      0                      NewVoxSize(3)*sign(headIN.mat(3,3))  origin(3)
%                     0                                      0                                   0                          1      ];
%                 %dim=(headIN.dim).*diag(headIN.mat(1:3,1:3))';
%                 %dim=ceil(abs(dim./NewVoxSize)); %dim=abs(round(dim./NewVoxSize));
%                 % Revised by YAN Chao-Gan, 100401.
%                 dim=(headIN.dim-1).*diag(headIN.mat(1:3,1:3))';
%                 dim=floor(abs(dim./NewVoxSize))+1;
%             end
% 
%             PO = [pth1,filesep,'resliced_',Name1,'_' [num2str(headIN.dim(1)) 'x' num2str(headIN.dim(2)) 'x' num2str(headIN.dim(3))] Ext1];
% 
%             VI          = spm_vol(PI);
%             VO          = VI;
%             VO.fname    = deblank(PO);
%             VO.mat      = mat;
%             VO.dim(1:3) = dim;
% 
%             % VO = spm_create_vol(VO);
%             % for x3 = 1:VO.dim(3),
%             %         M  = inv(spm_matrix([0 0 -x3 0 0 0 1 1 1])*inv(VO.mat)*VI.mat);
%             %         v  = spm_slice_vol(VI,M,VO.dim(1:2),hld);
%             %         VO = spm_write_plane(VO,v,x3);
%             % end;
% 
% 
%             [x1,x2] = ndgrid(1:dim(1),1:dim(2));
%             d     = [hld*[1 1 1]' [1 1 0]'];
%             C = spm_bsplinc(VI, d);
%             v = zeros(dim);
%             for x3 = 1:dim(3),
%                 [tmp,y1,y2,y3] = getmask(inv(mat\VI.mat),x1,x2,x3,VI.dim(1:3),[1 1 0]');
%                 v(:,:,x3)      = spm_bsplins(C, y1,y2,y3, d);
%             end;
%             
%             if strcmp(h,'For Binary mask')
%               %  VO.pinfo(1)=1;
%                 VO.dt(1)=8;    % 16 may cause some NaN values, 8 is OK!   
%                 v=double(logical(v));
%                 VO = spm_write_vol(VO,v);  % for the binary, this is important. otherwise, your are binary output may be not [binary]
%             else
%                 VO = spm_write_vol(VO,v);
%             end
%             
% 
%         end
%         
%        fprintf('\n ----ALl set'); 
%         
%     case '2nd one'
%                 % go to the working dir that is used to store the spm_job batch codes

        
        h2=questdlg('Do you want to reslice all selected Imgs into one target space OR reslice each selected Img into a specific space one by one?', ...
            'Hi...','All -> one','1 -> 1','All -> one') ;

%         root_dir = spm_select(1,'dir','Select the root folder of your images', [],pwd);
%               if isempty(root_dir)
%                 return
%               end   
%         cd (root_dir)
       
        temp =  spm_select(inf,'any','Select all the imgs you want to reslice ', [],pwd,'.*nii$|.*img$');
        if strcmp(h2,'All -> one')
            RefFile =  spm_select(1,'any','Select a img used to define the target space ', [],pwd,'.*nii$|.*img$');
%             refData=spm_read_vols(spm_vol(RefFile));
        elseif strcmp(h2,'1 -> 1')
            RefFile =  spm_select(size(temp,1),'any','Select Imgs used to define corresponding target space ', [],pwd,'.*nii$|.*img$');    
%             refData=spm_read_vols(spm_vol(RefFile));
        end
        
        
        recal_name=['batch_reslicing_job.m']; 
        
        h=questdlg('Specify interpolation scheme and datatype:','Choose one scheme...','1.For normal imgs','2.For binary imgs','3.Specify myself','1.For normal imgs') ;

        switch h
            case '3.Specify myself'
                dlg_prompt={'Interpolation shceme(0 for NearestNeighbor, 1 for Trilinear, etc.):','Datatype:                               '};
                dlg_name='Specify Parameters...';
                dlg_def={'1','4'};
                Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
                intp=Ans{1};
                datat=Ans{2};
            case '1.For normal imgs'
                intp='1';
                datat='4';                
            case '2.For binary imgs'
                intp='0';
                datat='8';   % 16 may cause some NaN values, 8 is OK!             
        end

        for i=1:size(temp,1)        
                [a,b,c,d]=fileparts(deblank(temp(i,:)));
                
                if strcmp(h2,'All -> one') && i==1
                    refData=spm_read_vols(spm_vol(RefFile)); 
                elseif strcmp(h2,'1 -> 1')
                    refData=spm_read_vols(spm_vol(RefFile(i,:)));                   
                end                
                
                newfile_name=['resliced_' b '_as_' num2str(size(refData,1)) 'x' num2str(size(refData,2)) 'x' num2str(size(refData,3)) c];

                % build the batch header
                dlmwrite(recal_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
                dlmwrite(recal_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc'); 
                
                if strcmp(h2,'All -> one')
                    dlmwrite(recal_name,strcat('''', deblank(RefFile), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
                elseif strcmp(h2,'1 -> 1')
                    dlmwrite(recal_name,strcat('''', deblank(RefFile(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');                    
                end
                
                dlmwrite(recal_name,strcat('''', deblank(temp(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc');    
                                                                                         %% change the output name below on your own  
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.output = ''', newfile_name ,''';'), '-append', 'delimiter', '', 'newline','pc');  
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  

                                                                                         %% change the expression below on your own   
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.expression = ''i2'';'), '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.interp=',intp, ';'), '-append', 'delimiter', '', 'newline','pc'); % cliff: interp, be careful
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dtype=',datat, ';'), '-append', 'delimiter', '', 'newline','pc'); % cliff: dtype, be careful
                dlmwrite(recal_name,'%%', '-append', 'delimiter', '', 'newline','pc');

                 fprintf('\nAll set! Strat to run...\n\n')
                 spm_jobman('run',recal_name)
                 delete (recal_name)
        end
        
        fprintf('\n -----------Reslicing is done!\n');         
        
        
% end   

%         %_______________________________________________________________________
%         function [Mask,y1,y2,y3] = getmask(M,x1,x2,x3,dim,wrp)
%         tiny = 5e-2; % From spm_vol_utils.c
%         y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
%         y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
%         y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
%         Mask = logical(ones(size(y1)));
%         if ~wrp(1), Mask = Mask & (y1 >= (1-tiny) & y1 <= (dim(1)+tiny)); end;
%         if ~wrp(2), Mask = Mask & (y2 >= (1-tiny) & y2 <= (dim(2)+tiny)); end;
%         if ~wrp(3), Mask = Mask & (y3 >= (1-tiny) & y3 <= (dim(3)+tiny)); end;
%         return;
%         %_______________________________________________________________________
%         
        

