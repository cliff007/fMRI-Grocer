function FG_enhanced_all_preprocessing_pipeline_gen
clc

h_type=questdlg('What are you preprocessing for?','Hi....','CBF','BOLD','CBF') ;
if isempty(h_type), return; end
h_BOLD=questdlg('Which subtype below do you want to do?','Hi....','Without-slicetiming','With-slicetiming','Without-slicetiming') ;
if isempty(h_BOLD), return; end
h_enhance=questdlg('Do you want to do the enhanced denoising procedures for your data?','Hi....','Yes','No','No') ;
if isempty(h_enhance), return; end
h_maskbefsmooth=questdlg('Do you want to self-mask the images entering to smooth?','Hi....','Yes','No','Yes') ;
if isempty(h_maskbefsmooth), return; end

h_SelfdefineorNo=[];
if strcmpi(h_maskbefsmooth,'Yes')
    h_SelfdefineorNo = questdlg('Remove the skull or just use one matter?','Way of defining mask...','Remove-skull','Gray','White','Remove-skull') ;
    if isempty(h_SelfdefineorNo), return; end
end

h_expression=[''];
if ~strcmpi(h_SelfdefineorNo,'Remove-skull') &&  ~isempty(h_SelfdefineorNo)  
    prompt = {['Specify the binarization expression for ' h_SelfdefineorNo ' matter (e.g. i1>0, i1<1, 0<i1<1)']};
    dlg_title = 'Apply for the selected matter...';
    num_lines = 1;
    def = {'i1>0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    h_expression=deblank(answer{1})   ;
end


switch h_BOLD
    case 'Without-slicetiming'
        if strcmp(h_type,'CBF')
            if strcmp(h_enhance,'Yes')
                uiwait(msgbox('Steps include: realign, enhanced-denosing, coregister and smooth','Tips....','help','modal'))
            elseif strcmp(h_enhance,'No')
                uiwait(msgbox('Steps include: realign,coregister and smooth','Tips....','help','modal'))
            end
        elseif strcmp(h_type,'BOLD')
            if strcmp(h_enhance,'Yes')
                uiwait(msgbox('Steps include: realign, enhanced-denosing, coregister, smooth and normalize!','Tips....','help','modal'))
            elseif strcmp(h_enhance,'No')
                uiwait(msgbox('Steps include: realign,coregister, smooth and normalize!','Tips....','help','modal'))
            end            
        end
        
        % 
        DOorNO=[];ASL_para_file=[];SelfmaskedorNo=[];
        if strcmp(h_type,'CBF')
           DOorNO=questdlg('Do you want to reconstruct CBF after all preprocessing?','Hi...','Yes','No','Yes');
        end
        
        if strcmp(DOorNO,'Yes')  
            h_readparas=questdlg('Do you have an existed ASL-CBF parameters file (ASL_paras.mat)?','Hi...','Yes','No','Yes');
            if strcmp(h_readparas,'No')
                [ASL_para_file,SelfmaskedorNo]=CBF_paras_tem_setting(DOorNO); 
            else
                ASL_para_file = spm_select(1,'.mat','Select your existed ASL_paras.mat file', [],pwd,'ASL_paras.mat');
                p_tem=load(ASL_para_file);
                SelfmaskedorNo=p_tem.ASL_paras.SelfmaskedorNo;
                clear p_tem
            end
        end
        
        FG_enhanced_all_preprocessing_for_BOLD_CBF_gen(h_type,h_BOLD,h_enhance,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo,h_expression)        

    case 'With-slicetiming'
        if strcmp(h_type,'CBF')
            if strcmp(h_enhance,'Yes')
                uiwait(msgbox('Steps include: slice-timing, realign, enhanced-denosing, coregister and smooth!','Tips....','help','modal'))
            elseif strcmp(h_enhance,'No')
                uiwait(msgbox('Steps include: slice-timing, realign, coregister and smooth!','Tips....','help','modal'))
            end
        elseif strcmp(h_type,'BOLD')
            if strcmp(h_enhance,'Yes')
                uiwait(msgbox('Steps include: slice-timing, realign, enhanced-denosing, coregister, smooth, and normalize!','Tips....','help','modal'))
            elseif strcmp(h_enhance,'No')
                uiwait(msgbox('Steps include: slice-timing, realign, coregister and smooth!','Tips....','help','modal'))
            end                         
        end
        % 
        DOorNO=[];ASL_para_file=[];SelfmaskedorNo=[];
        if strcmp(h_type,'CBF')
           DOorNO=questdlg('Do you want to reconstruct CBF after all preprocessing?','Hi...','Yes','No','Yes');
        end
        
        
        if strcmp(DOorNO,'Yes')        
            h_readparas=questdlg('Do you have an existed ASL-CBF parameters file (ASL_paras.mat)?','Hi...','Yes','No','Yes');
            if strcmp(CBForBOLD,'CBF')  && strcmp(h_readparas,'No')
                [ASL_para_file,SelfmaskedorNo]=CBF_paras_tem_setting(DOorNO); 
            elseif strcmp(CBForBOLD,'CBF')
                ASL_para_file = spm_select(1,'.mat','Select your existed ASL_paras.mat file', [],pwd,'ASL_paras.mat');
                p_tem=load(ASL_para_file);
                SelfmaskedorNo=p_tem.ASL_paras.SelfmaskedorNo;
                clear p_tem
            end 
        end
        
        FG_enhanced_all_preprocessing_for_BOLD_CBF_gen(h_type,h_BOLD,h_enhance,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)  
end   



function FG_enhanced_all_preprocessing_for_BOLD_CBF_gen(CBForBOLD,WithorNo,EnhanceorNo,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)

if nargin==0
    CBForBOLD='CBF'; % default for CBF
    WithorNo='Without-slicetiming';
    EnhanceorNo='Yes';
end

if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"
    %% warning for file selection of slice-timing included preprocessing
    uiwait(msgbox(sprintf(['You choose to do slice-timing!\nPlease make sure that the number of images of all the subjects under a group are same.' ...
        'Because you can only set up slice-timing parameters once.\n\nAnd then these parameters will be applied for all subjects!']),'Warning....','help','modal'))
end


anyreturn=FG_modules_enhanced_selection('','','','.*img$|.*nii$','r','g','fo','fi','t');
if anyreturn, return;end  
    
% select T1-templeate imgs
       %% cliff: ready for future use
            %     if strcmp(CBForBOLD,'BOLD')  % only do normalization for BOLD 
            %         a=which('spm.m');
            %         [b,c,d,e]=fileparts(a);
            %         T1_template =  spm_select(1,'.nii','Select your T1 template', [],[b filesep 'templates'],'T1.*nii');
            %         if FG_check_ifempty_return(T1_template), return; end
            %     end
    
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
    
fprintf('\n\n-----It is running into the preprocessing of : %s %s!\n',CBForBOLD,WithorNo) 

for g=1:size(groups,1)       
   
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);           
    % assigning the t1 of groups
    t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts);  
    
   
    for i=1:size(dirs,1)        
        fprintf('\n------ Dealing with Group:  %s  Dir:   %s .....\n',groups(g,:),dirs(i,:))
        % files writing
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);        
        FG_reset_origin_selectedImgs(fun_imgs) % reset the origin of all the entering functional images

        if strcmp(WithorNo,'With-slicetiming')  % only do slice-timing for "With"  
            % get the slice-timing parameters
            if strcmp(h_SLTiming,opts.ST.oper{1})
                nslice=cell2mat(Ans{1}(1));
                tr=cell2mat(Ans{1}(2));
                ta=eval(cell2mat(Ans{1}(3)));
                sliceorder=eval(cell2mat(Ans{1}(4)));
                refslice=cell2mat(Ans{1}(5));              
            elseif strcmp(h_SLTiming,opts.ST.oper{2})
                nslice=cell2mat(Ans{g}(1));
                tr=cell2mat(Ans{g}(2));
                ta=eval(cell2mat(Ans{g}(3)));
                sliceorder=eval(cell2mat(Ans{g}(4)));
                refslice=cell2mat(Ans{g}(5)); 
            end

            nslice=str2num(nslice);
            refslice=str2num(refslice);
            timing(1)=tr-ta;
            timing(2)=ta /(nslice -1);
            prefix='a';
            
            % get the new names after slice-timing, and do the slice timing            % 
            [pathes, names,new_names,new_fun_imgs]=FG_separate_files_into_name_and_path(fun_imgs,prefix,'prefix'); 
            h_ST='Yes';
            if exist(new_fun_imgs(end,:),'file') && g==1 && i==1
               h_ST=questdlg('We find files that prefixed by ''r'', do you really want to do the realign again?','Yes','No','No');
            end
            if strcmp(h_ST,'Yes') 
                spm_slice_timing(fun_imgs, sliceorder, refslice, timing, prefix) ;
            end

            % do the realign: est & reslice   
            realign_est_flags=spm_get_defaults('realign.estimate');
            
            [tt1, tt2,tt3,r_fun_imgs]=FG_separate_files_into_name_and_path(new_fun_imgs,'r','prefix');
            h_realign='Yes';
            if exist(r_fun_imgs(end,:),'file') && g==1 && i==1
               h_realign=questdlg('We find files that prefixed by ''r'', do you really want to do the realign again?','Hi...','Yes','No','No');
            end
            
            if strcmp(h_realign,'Yes')
                if strcmp(EnhanceorNo,'Yes')   &&  strcmp(CBForBOLD,'CBF')    % use the revised "spm_realign_asl.m" revised by zewang
                    FG_spm_realign_asl(new_fun_imgs,realign_est_flags);  % Use "default flags" here;  P = spm_realign(fun_imgs,flags), if you select a output "P", then no rp*.txt file created    
                else
                    spm_realign(new_fun_imgs,realign_est_flags);  % Use "default flags" here;  P = spm_realign(fun_imgs,flags), if you select a output "P", then no rp*.txt file created
                end            
            
                realign_write_flags=spm_get_defaults('realign.write');
                %  realign_write_flags.interp='1';   % % trilinear interpolation
                spm_reslice(new_fun_imgs,realign_write_flags);
            end
            
             if strcmp(EnhanceorNo,'Yes')  % do the enhanced-denoising
                enhanced_procs_after_realign(root_dir,groups,g,i,dirs,new_fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)   ;   
             elseif strcmp(EnhanceorNo,'No') 
                normal_procs_after_realign(root_dir,groups,g,i,dirs,new_fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)   ;               
             end       
             
        elseif strcmp(WithorNo,'Without-slicetiming')  % only do slice-timing for "With"             
            % do the realign: est & reslice
            realign_est_flags=spm_get_defaults('realign.estimate');
            
            [tt1, tt2,tt3,r_fun_imgs]=FG_separate_files_into_name_and_path(fun_imgs,'r','prefix');
            h_realign='Yes';
            if exist(r_fun_imgs(end,:),'file')  && g==1 && i==1
               h_realign=questdlg('We find files that prefixed by ''r'', do you really want to do the realign again?','Hi...','Yes','No','No');
            end
            
            if strcmp(h_realign,'Yes')    
                if strcmp(EnhanceorNo,'Yes')  &&  strcmp(CBForBOLD,'CBF')  % use the revised "spm_realign_asl.m" revised by zewang                
                    FG_spm_realign_asl(fun_imgs,realign_est_flags);  % Use "default flags" here;  P = spm_realign(fun_imgs,flags), if you select a output "P", then no rp*.txt file created 
                else
                   spm_realign(fun_imgs,realign_est_flags);  % Use "default flags" here;  P = spm_realign(fun_imgs,flags), if you select a output "P", then no rp*.txt file created 
                end
                       
                realign_write_flags=spm_get_defaults('realign.write');
                % realign_write_flags.interp='1';   % % trilinear interpolation
                spm_reslice(fun_imgs,realign_write_flags);  % == FG_enhanced_realign_asl(files)
            end
            
             if strcmp(EnhanceorNo,'Yes')  % do the enhanced-denoising
                 enhanced_procs_after_realign(root_dir,groups,g,i,dirs,fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)  ;  
             elseif strcmp(EnhanceorNo,'No') 
                 normal_procs_after_realign(root_dir,groups,g,i,dirs,fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)   ;               
             end
             
        end
    end
end

fprintf('\n\n\n =========== The whole program of preprocessing & potential CBF reconstruction for "%s %s" in this run is done! ............\n',CBForBOLD,WithorNo)


%%%%%%%%%%%%%%%%  subfunctions    %%%%%%%%%%%%%%%% 


function [ASL_para_file,SelfmaskedorNo]=CBF_paras_tem_setting(DOorNO)
    if strcmp(DOorNO,'No')
        ASL_para_file=[];
        SelfmaskedorNo=[];
        return;
    elseif strcmp(DOorNO,'Yes')
        [ASL_para_file,SelfmaskedorNo]=FG_ASL_CBF_paras_gen_and_save('IsTemp');
    end

        

function enhanced_procs_after_realign(root_dir,groups,g,i,dirs,new_fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)  
        Filled_masks=[];
        [pathes, names,new_names,r_fun_imgs]=FG_separate_files_into_name_and_path(new_fun_imgs,'r','prefix');  
        files_after_motion_filter=FG_motion_filter_after_realign(r_fun_imgs,fullfile(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:))));
        pca_r_fun_imgs=FG_pca_denoising_after_motion_filter(files_after_motion_filter,fullfile(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:))),0.95,CBForBOLD) ; 
       
        % calculate a new_mean
            Vmat_out=spm_vol(pca_r_fun_imgs(1,:));
            [a,b,c,d]=fileparts(Vmat_out.fname);
            Vmat_out.fname=fullfile(a, 'mean_pca_r_EPI.nii');
            Vo = spm_imcalc(spm_vol(pca_r_fun_imgs),Vmat_out,['sum(X)/' num2str(size(pca_r_fun_imgs,1))],{1,0,0});        
            % get the new mean_*.img after pca noise-reduction
            mean_img=spm_select('FPList',fullfile(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:))),'^mean_pca_r_EPI.*img$|^mean_pca_r_EPI.*nii$');
        
%         % get the mean_*.img after realign
%         mean_img=spm_select('FPList',fullfile(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:))),'^mean.*img$|^mean.*nii$');
        
        % set the mean_img as the first source image, and do the coreg: Estimate
         FG_spm_batch_coreg(t1_imgs(i,:),strvcat(mean_img(1,:),pca_r_fun_imgs));  %  x = FG_spm_batch_coreg(Tname, Sname)
        % set the smooth output names, and do the smooth
        [pathes, names,new_names,s_fun_imgs]=FG_separate_files_into_name_and_path(pca_r_fun_imgs,'s','prefix'); 
        [pathes, names,new_names,self_masked_fun_imgs]=FG_separate_files_into_name_and_path(pca_r_fun_imgs,'self_masked_','prefix');
        if ~strcmp(h_maskbefsmooth,'Yes') % for the normal non-selfmasked processing
            for i_s=1:size(pca_r_fun_imgs,1)  % you can do smooth only one by one
                spm_smooth(pca_r_fun_imgs(i_s,:),deblank(s_fun_imgs(i_s,:)),str2num(smooth_kernel{1}));  %  spm_smooth(P,Q,s,dtype)
            end
        elseif strcmp(h_maskbefsmooth,'Yes')  % for the normal selfmasked processing
             Filled_masks=FG_create_Individual_masks(t1_imgs(i,:),pca_r_fun_imgs(1,:),h_SelfdefineorNo, h_expression);
             tem_mask=spm_read_vols(spm_vol(Filled_masks(1,:)));
             tem_mask=double(logical(tem_mask));
             for i_s=1:size(pca_r_fun_imgs,1)  % you can do smooth only one by one  

                tem_mat=spm_vol(pca_r_fun_imgs(i_s,:));
                tem_V=spm_read_vols(tem_mat);
                
                tem_masked_V=tem_V.*tem_mask;  % self-mask the imges before they enter to the smooth    
                tem_masked_name=deblank(self_masked_fun_imgs(i_s,:));
                tem_mat.fname=tem_masked_name;
                spm_write_vol(tem_mat,tem_masked_V);    
                
                spm_smooth(tem_masked_name,deblank(s_fun_imgs(i_s,:)),str2num(smooth_kernel{1}));  %  spm_smooth(P,Q,s,dtype)
            end           
        end
        
        if strcmp(CBForBOLD,'BOLD')  % only do normalization for BOLD
            % do the normalize: est & write
            tem=which('spm.m');
            [path_T1, b,c,d]=FG_separate_files_into_name_and_path(tem); 
            T1_tem=fullfile(path_T1,'templates','T1.nii');  % get the T1.nii template of the SPM
            spm_normalise(spm_vol(T1_tem),spm_vol(t1_imgs(i,:)));  % params = spm_normalise(VG,VF,matname,VWG,VWF,flags), if you select a output "params", then no *_sn.mat file created

            [path_t1, b,c,sn_mat]=FG_separate_files_into_name_and_path(deblank(t1_imgs(i,:)),'_sn','subfix','.mat'); 
            if ~exist(sn_mat,'file'), return;end
            
            spm_write_sn(spm_vol(s_fun_imgs),sn_mat);  
        end
            
        if strcmp(DOorNO,'Yes') 
            if strcmp(SelfmaskedorNo,'CBF-selfmasked') && isempty(Filled_masks) % if you have ever done self-mask before smooth, them skip this step
                Filled_masks=FG_create_Individual_masks(t1_imgs(i,:),s_fun_imgs,h_SelfdefineorNo, h_expression);
            end
            
             % CBF calculation  (so far, only for casl and pCasl images, not suitable for pasl images)
             FG_load_ASL_parameters(ASL_para_file);
             [Mean_CBF_name,all_CBF_name]=FG_Perf_ASL_CBF_SPM8_Only_one_sub_CMD(SelfmaskedorNo, ...
                                                     s_fun_imgs, ...
                                                     Filled_masks(1,:), ...
                                                    FieldStrength,ASLType,FirstimageType, SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,PASLMo,Timeshift,threshold,alp);
            
            [path_t1, b,c,sn_mat]=FG_separate_files_into_name_and_path(deblank(t1_imgs(i,:)),'_seg_sn','subfix','.mat');           
            spm_write_sn(spm_vol(Mean_CBF_name),sn_mat);   
            %normalized the CBF images
            spm_write_sn(spm_vol(all_CBF_name),sn_mat); 
            
            %%% copy out the Mean_CBFs and wMean_CBFs
            destination=fullfile(deblank(root_dir),['all_MeanCBF_' deblank(groups(g,:))]);
            if ~exist('destination','dir') , mkdir(destination), end
            prefix_c='Mean_CBF*';
            destination_w=fullfile(deblank(root_dir),['all_wMeanCBF_' deblank(groups(g,:))]);
            if ~exist('destination_w','dir') , mkdir(destination_w), end
            prefix_c_w='wMean_CBF*';                       
            
            FG_copy_all_wMeanCBF(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:)),prefix_c,destination);
            FG_copy_all_wMeanCBF(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:)),prefix_c_w,destination_w);            
        end

        
        
        
 
function normal_procs_after_realign(root_dir,groups,g,i,dirs,new_fun_imgs,CBForBOLD,smooth_kernel,t1_imgs,ASL_para_file,SelfmaskedorNo,DOorNO,h_maskbefsmooth,h_SelfdefineorNo, h_expression)
        Filled_masks=[];
        % get the mean_*.img after realign
        mean_img=spm_select('FPList',fullfile(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:))),'^mean.*img$|^mean.*nii$');
        % set the mean_img as the first source image, and do the coreg: Estimate
        [pathes, names,new_names,r_fun_imgs]=FG_separate_files_into_name_and_path(new_fun_imgs,'r','prefix'); 
         FG_spm_batch_coreg(t1_imgs(i,:),strvcat(mean_img(1,:),r_fun_imgs));  %  x = FG_spm_batch_coreg(Tname, Sname)
        % set the smooth output names, and do the smooth
        [pathes, names,new_names,s_fun_imgs]=FG_separate_files_into_name_and_path(r_fun_imgs,'s','prefix'); 
        [pathes, names,new_names,self_masked_fun_imgs]=FG_separate_files_into_name_and_path(r_fun_imgs,'self_masked_','prefix');
         if ~strcmp(h_maskbefsmooth,'Yes')  % for the normal non-selfmasked processing
            for i_s=1:size(r_fun_imgs,1)  % you can do smooth only one by one
                spm_smooth(r_fun_imgs(i_s,:),deblank(s_fun_imgs(i_s,:)),str2num(smooth_kernel{1}));  %  spm_smooth(P,Q,s,dtype)
            end
        elseif strcmp(h_maskbefsmooth,'Yes')  % for the normal selfmasked processing
             Filled_masks=FG_create_Individual_masks(t1_imgs(i,:),r_fun_imgs(1,:),h_SelfdefineorNo, h_expression);
             tem_mask=spm_read_vols(spm_vol(Filled_masks(1,:)));
             tem_mask=double(logical(tem_mask));
             for i_s=1:size(r_fun_imgs,1)  % you can do smooth only one by one 
               
                tem_mat=spm_vol(r_fun_imgs(i_s,:));
                tem_V=spm_read_vols(tem_mat);
                
                tem_masked_V=tem_V.*tem_mask;  % self-mask the imges before they enter to the smooth
                tem_masked_name=deblank(self_masked_fun_imgs(i_s,:));
                tem_mat.fname=tem_masked_name;
                spm_write_vol(tem_mat,tem_masked_V);
                
                spm_smooth(tem_masked_name,deblank(s_fun_imgs(i_s,:)),str2num(smooth_kernel{1}));  %  spm_smooth(P,Q,s,dtype)
            end           
         end
        

        if strcmp(CBForBOLD,'BOLD')  % only do normalization for BOLD
            % do the normalize: est & write
            tem=which('spm.m');
            [path_T1, b,c,d]=FG_separate_files_into_name_and_path(tem); 
            T1_tem=fullfile(path_T1,'templates','T1.nii');  % get the T1.nii template of the SPM
            spm_normalise(spm_vol(T1_tem),spm_vol(t1_imgs(i,:)));  % params = spm_normalise(VG,VF,matname,VWG,VWF,flags), if you select a output "params", then no *_sn.mat file created

            [path_t1, b,c,sn_mat]=FG_separate_files_into_name_and_path(deblank(t1_imgs(i,:)),'_sn','subfix','.mat'); 
            if ~exist(sn_mat,'file'), return;end
            
            spm_write_sn(spm_vol(s_fun_imgs),sn_mat);  
        end
        
        
        if strcmp(DOorNO,'Yes')
            if strcmp(SelfmaskedorNo,'CBF-selfmasked') && isempty(Filled_masks) % if you have ever done self-mask before smooth, them skip this step
                Filled_masks=FG_create_Individual_masks(t1_imgs(i,:),s_fun_imgs(1,:),h_SelfdefineorNo, h_expression);
            end 

            % CBF calculation  (so far, only for casl and pCasl images, not suitable for pasl images)
             FG_load_ASL_parameters(ASL_para_file);
             [Mean_CBF_name,all_CBF_name]=FG_Perf_ASL_CBF_SPM8_Only_one_sub_CMD(SelfmaskedorNo, ...
                                                     s_fun_imgs, ...
                                                     Filled_masks(1,:), ...
                                                    FieldStrength,ASLType,FirstimageType, SubtractionType,SubtractionOrder,Labeltime,Delaytime,Slicetime,h_M0,Timeshift,threshold,alp);
        
            [path_t1, b,c,sn_mat]=FG_separate_files_into_name_and_path(deblank(t1_imgs(i,:)),'_seg_sn','subfix','.mat');           
            spm_write_sn(spm_vol(Mean_CBF_name),sn_mat);   
            %normalized the CBF images
            spm_write_sn(spm_vol(all_CBF_name),sn_mat);   
            
            %%% copy out the Mean_CBFs and wMean_CBFs
            destination=fullfile(deblank(root_dir),['all_MeanCBF_' deblank(groups(g,:))]);
            if ~exist('destination','dir') , mkdir(destination), end
            prefix_c='Mean_CBF*';
            destination_w=fullfile(deblank(root_dir),['all_wMeanCBF_' deblank(groups(g,:))]);
            if ~exist('destination_w','dir') , mkdir(destination_w), end
            prefix_c_w='wMean_CBF*';                       
            
            FG_copy_all_wMeanCBF(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:)),prefix_c,destination);
            FG_copy_all_wMeanCBF(deblank(root_dir),deblank(groups(g,:)),deblank(dirs(i,:)),prefix_c_w,destination_w);
        end       
        