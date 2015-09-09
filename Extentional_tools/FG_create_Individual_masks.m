function Filled_masks=FG_create_Individual_masks(t1_imgs,ref_img,SelforNo,expression)

    if nargin==0
        t1_imgs =  spm_select(inf,'any','Select T1 img(s) for segment ', [],pwd,'.*nii$|.*img$');  
        if isempty(t1_imgs), return;end;
        ref_img =  spm_select(inf,'any','Select reference img(s) of the target-space', [],pwd,'.*nii$|.*img$');
        if isempty(ref_img), return;end   ; 
        SelforNo = questdlg('Remove the skull or just use one matter?','Way of defining mask...','Remove-skull','Gray','White','Remove-skull') ;
        
        if ~strcmpi(SelforNo,'Remove-skull')    
            prompt = {'Specify the binarization expression(e.g. i1>0, i1<1, 0<i1<1)'};
            dlg_title = 'Apply for the selected matter...';
            num_lines = 1;
            def = {'i1>0'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            expression=deblank(answer{1})   ;
        end
        
    elseif nargin==2
        SelforNo='Remove-skull';
    elseif nargin==3
         if ~strcmpi(SelforNo,'Remove-skull')    
            prompt = {'Specify the binarization expression(e.g. i1>0, i1<1, 0<i1<1)'};
            dlg_title = 'Apply for the selected matter...';
            num_lines = 1;
            def = {'i1>0'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            expression=deblank(answer{1})   ;
        end       
    end
    
    if strcmpi(SelforNo,'Remove-skull')
            Filled_masks=[];

            [all_path_t1,test_imgs,all_name_t1,c]=FG_separate_files_into_name_and_path(t1_imgs);

            % check existed files first
            for i=1:size(t1_imgs,1)
                tem=deblank(all_name_t1(i,:));
                tem=tem(end,1:end-4);
                Filled_mask=spm_select('FPList',all_path_t1(i,:),['^Binarized_s_\w*' tem '.*img$|^Binarized_s_\w*' tem '.*nii$']); 
                if size(Filled_mask,1)>1
                    fprintf('\n There is more than one file of " %s ", Please check it out first!\n',['^Binarized_s_\w*' tem '.*img$|^Binarized_s_\w*' tem '.*nii$'])
                    return
                end
            end

          fprintf('\n--- Segmenting T1 and creating individual-masks for the self-masked CBF calculation.....\n')        
          % check existed file and do the related segments
                for q=1:size(t1_imgs,1)
                    t1=deblank(t1_imgs(q,:));
                    tem1=deblank(all_name_t1(q,:));
                    tem=tem1(end,1:end-4);
                    Filled_mask=spm_select('FPList',all_path_t1(q,:),['^Binarized_s_\w*' tem '.*img$|^Binarized_s_\w*' tem '.*nii$']); 

                        if isempty(Filled_mask) % if there is no related Binarized_s file, we do the segment

                            %%%% T1 segment;  done't use pm_segment() to do the T1 segment        
                                % first, set options (watch out for line breaks)
                                 opts_seg = struct('ngaus',[2 2 2 4], 'warpreg',1, 'warpco',25, 'biasreg',1.0000e-004, 'biasfwhm',50, 'regtype','mni', 'fudge',5, 'msk','', 'samp',3);
                                 opts_write = struct('biascor',0,'GM',[0 0 1],'WM',[0 0 1],'CSF',[0 0 1], 'cleanup',1);


                                 fprintf('\n--- Segmenting\n  %d:  %s.....\n',i,t1)
                                 [path_t1, b,c,c1_ims]=FG_separate_files_into_name_and_path(t1,'c1','prefix'); 
                                 [path_t1, b,c,c2_ims]=FG_separate_files_into_name_and_path(t1,'c2','prefix'); 

                                 if ~exist(c1_ims,'file') && ~exist(c2_ims,'file')
                                     % segment dataset
                                     results = spm_preproc(deblank(t1), opts_seg);
                                    % process generated spatial normalization parameters
                                     [po,pin] = spm_prep2sn(results);
                                    % save parameters
                                     spm_prep2sn(results);
                                    % write out segmented data
                                     spm_preproc_write(po,opts_write);
                                 end


                               % sum the c1 c2 & c3 and then binarize the mask
                                 [path_t1, b,c,Binary_mask]=FG_separate_files_into_name_and_path(t1,'Binary_GW_','prefix');      
                                 if ~exist(Binary_mask,'file')
                                     T1_Vout=spm_vol(t1);                             

                                     T1_Vout.fname=deblank(Binary_mask);
                    %                  tem_imgs=strvcat(c1_ims(i,:),c2_ims(i,:),c3_ims(i,:));
                    %                  spm_imcalc(spm_vol(tem_imgs),T1_Vout,'sum(X)/3>0',{1,0,0});
                                     tem_imgs=strvcat(c1_ims,c2_ims);
                                     spm_imcalc(spm_vol(tem_imgs),T1_Vout,'sum(X)>0',{1,0,0});  
                                 end

                                 % reslice the masks
                                 [path_t1, b,c,Resliced_masks]=FG_separate_files_into_name_and_path(Binary_mask,'resliced_','prefix'); 
                                 if ~exist(Resliced_masks,'file')
                                     mask_Vout=spm_vol(ref_img(1,:)); % use the reference header file do define the resliced-output             
                                     mask_Vout.fname=deblank(Resliced_masks); 
                                     tem_imgs=strvcat(ref_img(1,:),Binary_mask);
                                    % spm_imcalc(spm_vol(tem_imgs),mask_Vout,'i2',{0,0,0});  % ref_img(1,:) is the target space, Binary_ims_imgs(i,:) is the source space
                                     spm_imcalc_ui(tem_imgs,mask_Vout.fname,'i2',{0,0,4,0});      %% define the datatype of the output as 4  
                                 end


                             %% fill the holes in the resliced-masks created above, and
                             %% then 
                                 [path_t1, b,c,Filled_masks_tem]=FG_separate_files_into_name_and_path(Resliced_masks,'Filled_','prefix');
                                 if ~exist(Filled_masks_tem,'file')
                                     mask_Vout.fname=deblank(Resliced_masks); 
                                     FG_fill_inside_Graymatter(Resliced_masks,0); 
                                 end


                          % smooth the filled mask     
                            [path_t1, b,c,s_Filled_mask]=FG_separate_files_into_name_and_path(Filled_masks_tem,'s_','prefix'); 
                            if ~exist(s_Filled_mask,'file')
                                 s_filled_Vout=spm_vol(Filled_masks_tem);
                                 fprintf('\n ------Smooth the imfilled mask image...\n');  
                                 % do a moderate smooth [3 3 3] to the original resliced mask before imfill
                                 s_filled_Vout.fname=deblank(s_Filled_mask); 
                                 spm_smooth(Filled_masks_tem,s_filled_Vout.fname,[3 3 3]);  %  spm_smooth(P,Q,s,dtype)
                            end


                          % binary the smoothed mask again
                              filled_Vout=spm_vol(s_Filled_mask);
                              [path_t1, b,c,Filled_mask]=FG_separate_files_into_name_and_path(s_Filled_mask,'Binarized_','prefix');
                              if ~exist(Filled_mask,'file')
                                  fprintf('\n ------Binarize the smoothed imfilled mask image...\n');  
                                  filled_Vout.fname=deblank(Filled_mask); 
                                  spm_imcalc_ui(s_Filled_mask,filled_Vout.fname,'i1>0',{0,0,4,0});  
                              end

        %                    % delete two temporary files
        %                      delete (deblank(Resliced_masks))
        %                      delete (deblank(s_Filled_mask))

                           % record the output
                             Filled_masks=strvcat(Filled_masks,Filled_mask);

                        elseif exist(deblank(Filled_mask),'file')  % if there is a related Binarized_s file, we just output its name
                                fprintf('\nThis T1 has a target-mask file: %s!\n',deblank(Filled_mask))
                                Filled_mask=spm_select('FPList',all_path_t1(i,:),['^Binarized_s_\w*' tem '.*img$|^Binarized_s_\w*' tem '.*nii$']);
                                Filled_masks=strvcat(Filled_masks,Filled_mask);
                        end
                end
    elseif ~strcmpi(SelforNo,'Remove-skull')
           Filled_masks=[];
           h_type = SelforNo;
           
           if strcmpi(SelforNo,'Gray')
                   h_t='1';
           elseif strcmpi(SelforNo,'White')
                   h_t='2';
           else
               fprintf('\n---I don''t know what does %s mean...\n',SelforNo)
               return
           end           
           
            [all_path_t1,test_imgs,all_name_t1,c]=FG_separate_files_into_name_and_path(t1_imgs);

            % check existed files first
            for i=1:size(t1_imgs,1)
                tem=deblank(all_name_t1(i,:));
                tem=tem(end,1:end-4);
                Filled_mask=spm_select('FPList',all_path_t1(i,:),['^resliced_Binary_' h_type '\w*' tem '.*img$|^resliced_Binary_' h_type '\w*' tem '.*nii$']); 
                if size(Filled_mask,1)>1
                    fprintf('\n There is more than one file of " %s ", Please check it out first!\n',['^resliced_Binary_' h_type '\w*' tem '.*img$|^resliced_Binary_' h_type '\w*' tem '.*nii$'])
                    return
                end
            end

          fprintf('\n--- Segmenting T1 and creating individual-masks for the self-masked CBF calculation.....\n')        
          % check existed file and do the related segments
                for q=1:size(t1_imgs,1)
                    t1=deblank(t1_imgs(q,:));
                    tem1=deblank(all_name_t1(q,:));
                    tem=tem1(end,1:end-4);
                    Filled_mask=spm_select('FPList',all_path_t1(q,:),['^resliced_Binary_' h_type '\w*' tem '.*img$|^resliced_Binary_' h_type '\w*' tem '.*nii$']); 

                        if isempty(Filled_mask) % if there is no related Binarized_s file, we do the segment

                            %%%% T1 segment;  done't use pm_segment() to do the T1 segment        
                                % first, set options (watch out for line breaks)
                                 opts_seg = struct('ngaus',[2 2 2 4], 'warpreg',1, 'warpco',25, 'biasreg',1.0000e-004, 'biasfwhm',50, 'regtype','mni', 'fudge',5, 'msk','', 'samp',3);
                                 opts_write = struct('biascor',0,'GM',[0 0 1],'WM',[0 0 1],'CSF',[0 0 1], 'cleanup',1);


                                 fprintf('\n--- Segmenting\n  %d:  %s.....\n',i,t1)
                                 [path_t1, b,c,c1_ims]=FG_separate_files_into_name_and_path(t1,'c1','prefix'); 
                                 [path_t1, b,c,c2_ims]=FG_separate_files_into_name_and_path(t1,'c2','prefix'); 
                                 
                                 if ~exist(eval(['c' h_t '_ims']),'file')  % only check the required matter
                                     % segment dataset
                                     results = spm_preproc(deblank(t1), opts_seg);
                                    % process generated spatial normalization parameters
                                     [po,pin] = spm_prep2sn(results);
                                    % save parameters
                                     spm_prep2sn(results);
                                    % write out segmented data
                                     spm_preproc_write(po,opts_write);
                                 end


                               % sum the c1 c2 & c3 and then binarize the mask
                                 [path_t1, b,c,Binary_mask]=FG_separate_files_into_name_and_path(t1,['Binary_' h_type '_'],'prefix');      
                                 if ~exist(Binary_mask,'file')
                                     T1_Vout=spm_vol(t1);    
                                     T1_Vout.fname=deblank(Binary_mask);
                                     tem_imgs=eval(['c' h_t '_ims']);
                                     spm_imcalc(spm_vol(tem_imgs),T1_Vout,expression,{0,0,0});  
                                 end

                                 % reslice the masks
                                 [path_t1, b,c,Resliced_masks]=FG_separate_files_into_name_and_path(Binary_mask,'resliced_','prefix'); 
                                 if ~exist(Resliced_masks,'file')
                                     mask_Vout=spm_vol(ref_img(1,:)); % use the reference header file do define the resliced-output             
                                     mask_Vout.fname=deblank(Resliced_masks); 
                                     tem_imgs=strvcat(ref_img(1,:),Binary_mask);
                                    % spm_imcalc(spm_vol(tem_imgs),mask_Vout,'i2',{0,0,0});  % ref_img(1,:) is the target space, Binary_ims_imgs(i,:) is the source space
                                     spm_imcalc_ui(tem_imgs,mask_Vout.fname,'i2',{0,0,4,0});      %% define the datatype of the output as 4  
                                 end

                           % record the output
                             Filled_mask=Resliced_masks;
                             Filled_masks=strvcat(Filled_masks,Filled_mask);

                        elseif exist(deblank(Filled_mask),'file')  % if there is a related Binarized_s file, we just output its name
                                fprintf('\nThis T1 has a target-mask file: %s!\n',deblank(Filled_mask))
                                Filled_mask=spm_select('FPList',all_path_t1(i,:),['^resliced_Binary_' h_type '\w*' tem '.*img$|^resliced_Binary_' h_type '\w*' tem '.*nii$']);
                                Filled_masks=strvcat(Filled_masks,Filled_mask);
                        end
                end
    end
        
        
        fprintf('\n---------------This run of self-mask creation is done!\n')
         

         