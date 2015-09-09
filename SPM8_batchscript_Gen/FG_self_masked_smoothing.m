function FG_self_masked_smoothing
clc
h_T1orMask=questdlg(sprintf( ...
    'If you already have the final self-masks,\nyou can select them instead of the original T1-imgs\nin the followed T1-selection dialog box'), ...
    'Choose one option....','Final-masks','Original-T1s','Original-T1s') ;

if strcmp(h_T1orMask,'Original-T1s')
    SelforNo = questdlg('Remove the skull or just use one matter?','Way of defining mask...','Remove-skull','Gray','White','Remove-skull') ;
end
    expression=[''];
    if ~strcmpi(SelforNo,'Remove-skull')     &&  ~isempty(h_SelfdefineorNo)  
        prompt = {'Specify the binarization expression(e.g. i1>0, i1<1, 0<i1<1)'};
        dlg_title = 'Apply for the selected matter...';
        num_lines = 1;
        def = {'i1>0'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        expression=deblank(answer{1})   ;
    end

anyreturn=FG_modules_enhanced_selection('','','','^r.*img$|^r.*nii$','r','g','fo','fi','t');
if anyreturn, return;end          

% specify smooth kernel size    
    dlg_prompt={'What is the kernel size you want to specify (spm_default:[8 8 8]) :'};
    dlg_name='smooth kernel size';
    dlg_def={'8 8 8'};
    smooth_kernel=inputdlg(dlg_prompt,dlg_name,1,dlg_def);  
    if FG_check_ifempty_return(smooth_kernel), return; end

for g=1:size(groups,1)       
   
    % assigning the subfolders of groups
    dirs=FG_module_assign_dirs(root_dir,dirs_tem,groups,g,folder_filter,h_folder,opts);           
    % assigning the t1 of groups
    t1_imgs=FG_module_assign_t1(t1_imgs_tem,g,h_t1,opts);  
    
   
    for i=1:size(dirs,1)        
        fprintf('\n------ Dealing with Group:  %s  Dir:   %s .....\n',groups(g,:),dirs(i,:))
        % files writing
        fun_imgs=FG_module_enhanced_read_funImgs(root_dir,groups,dirs,g,i,all_fun_imgs,file_filter,h_files,opts);
        
        % set the smooth output names, and do the smooth
        [pathes, names,new_names,s_fun_imgs]=FG_separate_files_into_name_and_path(fun_imgs,'s','prefix'); 
        [pathes, names,new_names,self_masked_fun_imgs]=FG_separate_files_into_name_and_path(fun_imgs,'self_masked_','prefix');
        
        if strcmp(h_T1orMask,'Original-T1s')
            Filled_masks=FG_create_Individual_masks(t1_imgs(i,:),fun_imgs(1,:),SelforNo,expression);
        elseif strcmp(h_T1orMask,'Final-masks')
            Filled_masks=t1_imgs(i,:);
        end
        
             for i_s=1:size(fun_imgs,1)  % you can do smooth only one by one 
                tem_V=[];
                tem_mask=[];
                tem_mat=[];
                tem_V=spm_read_vols(spm_vol(fun_imgs(i_s,:)));
                tem_mask=spm_read_vols(spm_vol(Filled_masks(1,:)));
                tem_V=tem_V.*tem_mask;  % self-mask the imges befoe they enter to the smooth
                tem_mat=spm_vol(fun_imgs(i_s,:));
                tem_mat.fname=self_masked_fun_imgs(i_s,:);
                spm_write_vol(tem_mat,tem_V);
                spm_smooth(tem_mat,s_fun_imgs(i_s,:),str2num(smooth_kernel{1}));  %  spm_smooth(P,Q,s,dtype)
            end           
    end
end
        
fprintf('\n\n-----Self-masked smoothing is done! The output file likes: %s\n', s_fun_imgs(end,:)) 
fprintf('-----The temporary file after self-masking likes: %s\n', self_masked_fun_imgs(end,:))        