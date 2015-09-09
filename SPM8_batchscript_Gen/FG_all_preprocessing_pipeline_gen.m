function FG_all_preprocessing_pipeline_gen
clc

h_type=questdlg('What are you preprocessing for?','Hi....','CBF','BOLD','CBF') ;
if isempty(h_type), return; end
h_BOLD=questdlg('Which subtype below do you want to do?','Hi....','Without-slicetiming','With-slicetiming','Without-slicetiming') ;
if isempty(h_BOLD), return; end

switch h_BOLD
    case 'Without-slicetiming'
        if strcmp(h_type,'CBF')
            uiwait(msgbox('Steps include: realign, coregister and smooth','Tips....','help','modal'))
        elseif strcmp(h_type,'BOLD')
            uiwait(msgbox('Steps include: realign, coregister, smooth and normalize!','Tips....','help','modal'))
        end
        FG_all_preprocessing_for_BOLD_CBF_gen(h_type,h_BOLD)        

    case 'With-slicetiming'
        if strcmp(h_type,'CBF')
            uiwait(msgbox('Steps include: slice-timing, realign, coregister and smooth!','Tips....','help','modal'))
        elseif strcmp(h_type,'BOLD')
            uiwait(msgbox('Steps include: slice-timing, realign, coregister,smooth and normalize!','Tips....','help','modal'))            
        end
        FG_all_preprocessing_for_BOLD_CBF_gen(h_type,h_BOLD)  
end   


function FG_all_preprocessing_for_BOLD_CBF_gen(CBForBOLD,WithorNo)
%   Important: Your directory and filename  structure must be the same 
%   for all other subjects. Here's an example of a valid fMRI
%   directory and file structure:
%   - fMRI study root path
%     - functional_group1_Data
%       - subj_1
%         - vol_001.nii    ------ three digits' image number
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - subj_1
%         - vol_001.nii    ------ three digits' image number
%         - vol_002.nii
%         - ...
%       - subj_2
%         - vol_001.nii
%         - vol_002.nii
%         - ...
%       - subj_n
%         - ...
%     - functional_group2_Data
%       - ... 
%     - anatomy_data
%       - t1_subj_001.nii      ------ t1 imgs' order must be the same as the subject folders'.
%       - t1_subj_002.nii
%       - ...
%
% go to the working dir that is used to store the spm_job batch codes

if nargin==0
    CBForBOLD='CBF'; % default for CBF
    WithorNo='Without-slicetiming';
end

if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"
    %% warning for file selection of slice-timing included preprocessing
    uiwait(msgbox(sprintf(['You choose to do slice-timing!\nPlease make sure that the number of images of all the subjects under a group are same.' ...
        'Because you can only set up slice-timing parameters once.\n\nAnd then these parameters will be applied for all subjects!']),'Warning....','help','modal'))
end


% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
% 
% [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'.*img$|.*nii$');
%   
% [h_t1,t1_imgs_tem]=FG_module_select_T1_Img(groups,opts);

anyreturn=FG_modules_selection('','','','.*img$|.*nii$','r','g','fo','fi','t');
if anyreturn, return;end  
    
% select T1-templeate imgs
    
    if strcmp(CBForBOLD,'BOLD')  % only do normalization for BOLD 
        a=which('spm.m');
        [b,c,d,e]=fileparts(a);
        T1_template =  spm_select(1,'.nii','Select your T1 template', [],[b filesep 'templates'],'T1.*nii');
        if FG_check_ifempty_return(T1_template), return; end
    end
    
 % enter slice-timing parameters
 
     if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"   
        [h_SLTiming,Ans]=FG_module_select_slicetiming_paras(groups,opts);
     end
    
% specify smooth kernel size    
    dlg_prompt={'What is the kernel size you want to specify (spm_default:[8 8 8]) :'};
    dlg_name='smooth kernel size';
    dlg_def={'8 8 8'};
    smooth_kernel=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
    if FG_check_ifempty_return(smooth_kernel), return; end
    
fprintf('\n\n-----It is writing the codes of preprocessing for %s %s!\n',CBForBOLD,WithorNo) 

for g=1:size(groups,1)  
    
%%%%% build the batch header 
    i_batch=1;  
    
    if strcmp(WithorNo,'With-slicetiming')   &&  strcmp(CBForBOLD,'CBF')
        write_name=FG_check_and_rename_existed_file(['ST_Re_Co_Sm_'  deblank(groups(g,:))  '_job.m']) ;
    elseif strcmp(WithorNo,'Without-slicetiming')  &&  strcmp(CBForBOLD,'CBF')
        write_name=FG_check_and_rename_existed_file(['Re_Co_Sm_'  deblank(groups(g,:))  '_job.m']) ;
    elseif strcmp(WithorNo,'With-slicetiming')   &&  strcmp(CBForBOLD,'BOLD')
         write_name=FG_check_and_rename_existed_file(['ST_Re_Co_Sm_Nm_'  deblank(groups(g,:))  '_job.m']) ;
    elseif strcmp(WithorNo,'Without-slicetiming')   &&  strcmp(CBForBOLD,'BOLD')
         write_name=FG_check_and_rename_existed_file(['Re_Co_Sm_Nm_'  deblank(groups(g,:))  '_job.m']) ;
    end
    
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by cfg_util (created by fmri_grocer)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc');     
  
  
    if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"
%%%%% slice-timing         
        dlmwrite(write_name,'%% slice-timing---', '-append', 'delimiter', '', 'newline','pc');
    elseif strcmp(WithorNo,'Without-slicetiming')
%%%%% realign_first        
        dlmwrite(write_name,'%% realign---', '-append', 'delimiter', '', 'newline','pc');
    end   
    
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);   
    % assigning the t1 of groups
    t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts);
    
    for i=1:size(dirs,1)
        
        if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"        
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.scans = {'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,'{', '-append', 'delimiter', '', 'newline','pc'); 
        elseif strcmp(WithorNo,'Without-slicetiming')   
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data = {'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,'{', '-append', 'delimiter', '', 'newline','pc');        
        end   
    
        % files writing
        FG_module_write_funImgs(root_dir,groups,dirs,g,i,fun_imgs,write_name,file_filter,h_files,opts);
        
        dlmwrite(write_name,'}', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'}'';', '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,'%%', '-append', 'delimiter', '', 'newline','pc');
        
        if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"  
            if strcmp(h_SLTiming,opts.ST.oper{1})
                nslice=cell2mat(Ans{1}(1));
                tr=cell2mat(Ans{1}(2));
                ta=num2str(eval(cell2mat(Ans{1}(3))));
                sliceorder=num2str(eval(cell2mat(Ans{1}(4))));
                refslice=cell2mat(Ans{1}(5));              
            elseif strcmp(h_SLTiming,opts.ST.oper{2})
                nslice=cell2mat(Ans{g}(1));
                tr=cell2mat(Ans{g}(2));
                ta=num2str(eval(cell2mat(Ans{g}(3))));
                sliceorder=num2str(eval(cell2mat(Ans{g}(4))));
                refslice=cell2mat(Ans{g}(5)); 
            end  
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.nslices = ',nslice,';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.tr =  ',tr,';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.ta =  ',ta,';'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.so = [ ',sliceorder,'];'), '-append', 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.temporal.st.refslice =  ',refslice,';'), '-append', 'delimiter', '', 'newline','pc'); 
        end
        
        i_batch=i_batch+1;
       
     if strcmp(WithorNo,'With-slicetiming')  
    %%%%% realign_second      
            dlmwrite(write_name,'%% realign---', '-append', 'delimiter', '', 'newline','pc');

            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep;'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).tname = ''Session'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).name = ''filter'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(1).value = ''image'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).name = ''strtype'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).tgt_spec{1}(2).value = ''e'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).sname = ''Slice Timing: Slice Timing Corr. Images (Sess 1)'';'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).src_exbranch = substruct(''.'',','''val'',', '''{}'',','{', num2str(i_batch-1), '},', ...
                                '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1});'), '-append', 'delimiter', '', 'newline','pc');
            dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.realign.estwrite.data{1}(1).src_output = substruct(''()'',','{1},','''.'',', '''files'');'), '-append', 'delimiter', '', 'newline','pc');

            i_batch=i_batch+1;
     end
        
 %%%%% coregister
     %%% sess1
        dlmwrite(write_name,'%% coregister---', '-append', 'delimiter', '', 'newline','pc');

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.ref = {''',deblank(t1_imgs(i,:)) , ',1''};'), '-append', 'delimiter', '', 'newline','pc');  

        
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1) = cfg_dep;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).tname = ''Source Image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).name = ''filter'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(1).value = ''image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).name = ''strtype'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).tgt_spec{1}(2).value = ''e'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).sname = ''Realign: Estimate & Reslice: Mean Image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).src_exbranch = substruct(''.'',','''val'',', '''{}'',','{', num2str(i_batch-1), '},', ...
                            '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1});'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.source(1).src_output = substruct(''.'',', '''rmean'');'), '-append', 'delimiter', '', 'newline','pc');

     %%% sess2
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1) = cfg_dep;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).tname = ''Other Images'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).tgt_spec{1}(1).name = ''filter'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).tgt_spec{1}(1).value = ''image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).tgt_spec{1}(2).name = ''strtype'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).tgt_spec{1}(2).value = ''e'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).sname = ''Realign: Estimate & Reslice: Resliced Images (Sess 1)'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).src_exbranch = substruct(''.'',','''val'',', '''{}'',','{', num2str(i_batch-1), '},', ...
                            '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1});'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.coreg.estimate.other(1).src_output = substruct(''.'',', '''sess'',', '''()'',','{1},', '''.'',','''rfiles'');'), '-append', 'delimiter', '', 'newline','pc');
        i_batch=i_batch+1;
%%%%%% smooth
        dlmwrite(write_name,'%% smooth---', '-append', 'delimiter', '', 'newline','pc');
        
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1) = cfg_dep;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).tname = ''Images to Smooth'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = ''filter'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = ''image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = ''strtype'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = ''e'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).sname = ''Coregister: Estimate: Coregistered Images'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).src_exbranch = substruct(''.'',','''val'',', '''{}'',','{', num2str(i_batch-1), '},', ...
                            '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1});'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.data(1).src_output = substruct(''.'',','''cfiles'');'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.smooth.fwhm = [',smooth_kernel{1},'];'), '-append', 'delimiter', '', 'newline','pc'); 
        i_batch=i_batch+1;
 
   if strcmp(CBForBOLD,'BOLD')  % only do normalization for BOLD
        
%%%%%% normalize: est & write
        dlmwrite(write_name,'%% normalize: est & write---', '-append', 'delimiter', '', 'newline','pc');

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.source = {''',deblank(t1_imgs(i,:)) , ',1''};'), '-append', 'delimiter', '', 'newline','pc');  
      

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.wtsrc='''';'), '-append', 'delimiter', '', 'newline','pc'); 

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1) = cfg_dep;'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).tname = ''Images to Write'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(1).name = ''filter'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(1).value = ''image'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(2).name = ''strtype'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).tgt_spec{1}(2).value = ''e'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).sname = ''Smooth: Smoothed Images'';'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).src_exbranch = substruct(''.'',','''val'',', '''{}'',','{', num2str(i_batch-1), '},', ...
                            '''.'',','''val'',', '''{}'',','{1},', '''.'',','''val'',', '''{}'',','{1});'), '-append', 'delimiter', '', 'newline','pc');
        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.subj.resample(1).src_output = substruct(''.'',','''files'');'), '-append', 'delimiter', '', 'newline','pc');

        dlmwrite(write_name,strcat('matlabbatch{', num2str(i_batch), '}.spm.spatial.normalise.estwrite.eoptions.template= {''',deblank(T1_template(1,:)),',1''};'), '-append', 'delimiter', '', 'newline','pc'); 
        i_batch=i_batch+1;
        
  end
    end
end
fprintf('\n\n-----codes of preprocessing for %s %s:-:-: %s :-:-: are done!\n',CBForBOLD,WithorNo,write_name)
