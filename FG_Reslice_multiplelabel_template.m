function FG_Reslice_multiplelabel_template
clc
% h=questdlg('Two ways to do this: the first one is based on independent codes, the second one is based on imgcal of SPM. You can check your result between these two methods!','Choose one method...','1st one','2nd one','2nd one') ;
% if isempty(h), return;end
% 
% switch h
%     case '1st one'
%         root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
%         if isempty(root_dir),return;  end   
% 
%         cd (root_dir)
%         temp =  spm_select(1,'any','Select a mutiple labeling img(such as AAL/BA template) ', [],pwd,'.img$|.nii$');
%         [a,b,c,d]=fileparts(deblank(temp(1,:)));
%         [tempData,tempVox,tempHeader]=FG_rest_readfile(temp);
%         n_region=max(max(max(tempData)));
% 
%         RefFile =  spm_select(1,'any','Select a img used to define the target space ', [],pwd,'.img$|.nii$');
%         [refData,refVox,refHeader]=FG_rest_readfile(RefFile);
% 
%                     fprintf('\nReslice AAL temp (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',[b c], RefFile);
% 
%                     ReslicedMaskName=['resliced_' b '_as_' num2str(size(refData,1)) 'x' num2str(size(refData,2)) 'x' num2str(size(refData,3)) c];
%                     FG_y_Reslice(temp,ReslicedMaskName,refVox,0, RefFile);
% 
%                     Vmat = spm_vol(ReslicedMaskName);
%                     AALData=spm_read_vols(Vmat);
% 
%                     delete (ReslicedMaskName);
% 
%                     % revalue the regions
%                     for i=1:n_region                
%                         AALData(find(round(AALData)==i))=i;
%                     end
%                 %   Vmat.pinfo(1)=1;
%                    Vmat.dt(1)=16;  %% very very important, otherwise, the value of the final img will be wrong
%                 %   clc
%                    Vmat.pinfo
% 
%                    spm_write_vol(Vmat,AALData);
% 
%                 fprintf('\n ----%s has been created at the current directory\n\n',ReslicedMaskName);
%                 
%     case '2nd one'
        % go to the working dir that is used to store the spm_job batch codes
        root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
         if isempty(root_dir),return;  end  

        cd (root_dir)
        temp =  spm_select(1,'any','Select a mutiple labeling img(such as AAL/BA template) ', [],pwd,'.*nii$|.*img$');
        [a,b,c,d]=fileparts(deblank(temp(1,:)));
        RefFile =  spm_select(1,'any','Select a img used to define the target space ', [],pwd,'.*nii$|.*img$');
        [refData,refVox,refHeader]=FG_rest_readfile(RefFile);
        recal_name=['Multiple_labeling_reslicing_job.m'];  
        newfile_name=['resliced_' b '_as_' num2str(size(refData,1)) 'x' num2str(size(refData,2)) 'x' num2str(size(refData,3)) c];

            % build the batch header
            dlmwrite(recal_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
            dlmwrite(recal_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(recal_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc'); 
            
            dlmwrite(recal_name,strcat('''', deblank(RefFile), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(recal_name,strcat('''', deblank(temp(1,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 

            dlmwrite(recal_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc');    
                                                                                     %% change the output name below on your own  
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.output = ''', newfile_name ,''';'), '-append', 'delimiter', '', 'newline','pc');  
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  

                                                                                     %% change the expression below on your own   
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.expression = ''i2'';'), '-append', 'delimiter', '', 'newline','pc'); 

            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.interp=0;'), '-append', 'delimiter', '', 'newline','pc'); % cliff: interp, be careful
            dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dtype=16;'), '-append', 'delimiter', '', 'newline','pc'); % cliff: dtype, be careful
            dlmwrite(recal_name,'%%', '-append', 'delimiter', '', 'newline','pc');

         fprintf('\nAll set! Strat to run...\n\n')
         spm_jobman('run',recal_name)
         delete (recal_name)
        fprintf('\n ----%s has been created at the current directory\n\n',newfile_name);
        
% end