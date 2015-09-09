function FG_sum_GrayWhiteCSF_after_segment
% this script can help you to calculate up all the whites and grays (and
% CSFs) under the same folder
% this is used to build all subjs' individual brain mask
clc
       h=questdlg('What do you want to sum?','Choose one scheme...','Gray+White','Gray+White+CSF','Gray+White') ;
       h1=questdlg('Do you want to binarize the result of the SUM?','Choose one scheme...','Yes','No','Yes') ;
       % go to the working dir that is used to store the spm_job batch codes
        root_dir = spm_select(1,'dir','Select the root folder of all T1 segments', [],pwd);
              if isempty(root_dir)
                return
             end   

        cd (root_dir)
        Grays =  spm_select(inf,'any','Select all the gray matters ', [],pwd,'^c1.*nii$|^c1.*img$');
                Gs=spm_str_manip(Grays,'dc');  % take use of the "spm_str_manip" function
                if size(Gs,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Gs,'dh'),'dc')] can't get the group dirctories
                    [a,b,c,d]=fileparts(Grays(1,:));
                    Gs=[b c];
                end
        Whites =  spm_select(inf,'any','Select all the white matters ', [],pwd,'^c2.*nii$|^c2.*img$');
                Ws=spm_str_manip(Whites,'dc');  % take use of the "spm_str_manip" function
                if size(Ws,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Gs,'dh'),'dc')] can't get the group dirctories
                    [a,b,c,d]=fileparts(Whites(1,:));
                    Ws=[b c];
                end        
        
        % judge the img num
        if strcmp(h,'Gray+White+CSF')
            CSFs =  spm_select(inf,'any','Select all the CSFs ', [],pwd,'^c3.*nii$|^c3.*img$');
                Cs=spm_str_manip(CSFs,'dc');  % take use of the "spm_str_manip" function
                if size(Ws,1)==1   % in this condition, [spm_str_manip(spm_str_manip(Gs,'dh'),'dc')] can't get the group dirctories
                    [a,b,c,d]=fileparts(CSFs(1,:));
                    Cs=[b c];
                end                
            
            if size(Grays,1)~=size(Whites,1) |size(Whites,1)~=size(CSFs,1)|size(Grays,1)~=size(CSFs,1)
                pfrintf('\nThe num of Grays, Whites and CSFs is not the same!\n')
                return
            end
        else
            if size(Grays,1)~=size(Whites,1)
                pfrintf('\nThe num of Grays and Whites is not the same!\n')
                return
            end
        end
        
        % job name
        recal_name=['Sum_GWC_job.m']; 
        % calculation expression
        if strcmp(h,'Gray+White+CSF') & strcmp(h1,'Yes')
            cal_exp='''(i1+i2+i3)>0''';
        elseif strcmp(h,'Gray+White+CSF') & strcmp(h1,'No')
            cal_exp='''i1+i2+i3'''; 
        elseif strcmp(h,'Gray+White') & strcmp(h1,'Yes')    
             cal_exp='''(i1+i2)>0''';
        elseif strcmp(h,'Gray+White') & strcmp(h1,'No')
            cal_exp='''i1+i2'''    ; 
        end
        
        intp='1';
        datat='4';
         [a,b,c,d]=fileparts(Grays(1,:));   
        for i=1:size(Grays,1)        

                if strcmp(h,'Gray+White+CSF') & strcmp(h1,'Yes')
                    if i<10
                        newfile_name=['Binary_GWC0' num2str(i) '_' Gs(i,1:end-4) c];
                    else%if i<100
                        newfile_name=['Binary_GWC' num2str(i) '_' Gs(i,1:end-4) c];
                    end
                        
                elseif strcmp(h,'Gray+White+CSF') & strcmp(h1,'No')
                    if i<10
                        newfile_name=['Sum_GWC0' num2str(i) '_' Gs(i,1:end-4) c]; 
                    else%if i<100
                        newfile_name=['Sum_GWC' num2str(i) '_' Gs(i,1:end-4) c];                         
                    end
                elseif strcmp(h,'Gray+White') & strcmp(h1,'Yes')
                    if i<10
                        newfile_name=['Binary_GW0' num2str(i) '_' Gs(i,1:end-4) c];
                    else%if i<100
                        newfile_name=['Binary_GW' num2str(i) '_' Gs(i,1:end-4) c];
                    end
                elseif strcmp(h,'Gray+White') & strcmp(h1,'No')
                    if i<10
                        newfile_name=['Sum_GW0' num2str(i) '_' Gs(i,1:end-4) c];   
                    else%if i<100
                        newfile_name=['Sum_GW' num2str(i) '_' Gs(i,1:end-4) c];                          
                    end
                end
                

                % build the batch header
                dlmwrite(recal_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name, '% Job configuration created by cfg_util (rev $Rev: 3944 $)', '-append', 'delimiter', '', 'newline','pc');
                dlmwrite(recal_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.input = {'), '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('''', deblank(Whites(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name,strcat('''', deblank(Grays(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc'); 
                if strcmp(h,'Gray+White+CSF')
                    dlmwrite(recal_name,strcat('''', deblank(CSFs(i,:)), ',1'''), '-append', 'delimiter', '', 'newline','pc');
                end

                dlmwrite(recal_name,strcat('};'), '-append', 'delimiter', '', 'newline','pc');    
                                                                                         %% change the output name below on your own  
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.output = ''', newfile_name ,''';'), '-append', 'delimiter', '', 'newline','pc');  
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.outdir = {''''};'), '-append', 'delimiter', '', 'newline','pc');  

                                                                                         %% change the expression below on your own   
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.expression = ',cal_exp,';'), '-append', 'delimiter', '', 'newline','pc'); 

                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.mask = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.interp=',intp, ';'), '-append', 'delimiter', '', 'newline','pc'); % cliff: interp, be careful
                dlmwrite(recal_name,strcat('matlabbatch{1}.spm.util.imcalc.options.dtype=',datat, ';'), '-append', 'delimiter', '', 'newline','pc'); % cliff: dtype, be careful
                dlmwrite(recal_name,'%%', '-append', 'delimiter', '', 'newline','pc');

                 fprintf('\nAll set! Start to run...\n\n')
                 spm_jobman('run',recal_name)
                 delete (recal_name)
                 
        end
        
        fprintf('\n -----------GWC masks have been created!\n');  
       % delete(recal_name)
        

        
        

