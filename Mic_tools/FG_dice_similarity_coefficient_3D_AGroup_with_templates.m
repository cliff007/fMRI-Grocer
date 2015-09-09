function FG_dice_similarity_coefficient_3D_AGroup_with_templates(order)

%%%% this function is useful for doing individual-level's similarity
%%%% comparisons after ICA analysis

% go to the working dir that is used to store the spm_job batch codes 

% opts=FG_module_settings_of_questdlg;
% 
% root_dir = FG_module_select_root;
% 
% groups = FG_module_select_groups;    
% 
% [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
% 
% [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(group
% s,opts,'.*img$|.*nii$');

[subj1,full_subj1]=FG_module_select_groups(['Please select subjects under Group1...']);


all_DSC=[];
all_overlayname=[];

opts=FG_module_settings_of_questdlg;
% h_files=questdlg(opts.files.prom,opts.files.title,opts.files.oper{1},opts.files.oper{2},opts.files.oper{3},opts.files.oper{1}) ;

% revised by cliff: 2015.5.18
prompt = {'Enter the img order you want to select in the subject group----------'};
dlg_title = 'Img order of Subjs...';
num_lines = 1;
def = {'5:-1:1'};
orders = inputdlg(prompt,dlg_title,num_lines,def);

img_orders{1}= eval(['[' orders{1} ']']);

templates =  spm_select(length(img_orders{1}),'any','Select template images that is corresponding to the image-order', [],pwd,'.*nii$|.*img$')

out_dir =  spm_select(1,'dir','Select an output directory to hold the overlay output folders', [],pwd);
pause(0.5)

  for i=1:size(subj1,1)
       
        img_g1 =  spm_select('FPList',deblank(full_subj1(i,:)),'.*img|.*nii');        
        img_g1=img_g1(img_orders{1},:)
        
        tem1=[deblank(subj1(i,:)),num2str(i)]; 
        
        overlay_dir=fullfile(out_dir,[tem1(1,[1:5, end-4:end]) '_DSC_Overlay']);  % cliff: what if the length of tem1 is less than 5??
        mkdir (overlay_dir);
        [DSC,overlayname]=FG_dice_similarity_coefficient_3D(overlay_dir,img_g1, templates,'No') ;  
        all_DSC=[all_DSC, DSC]; %% cliff: haven't deal with the situation that the vectors have differnt length
        all_overlayname=strvcat(all_overlayname, strvcat(overlayname,'---------NEXT Subject...............')); 
  end
 

  write_name1=fullfile(out_dir,'all_DSCs.csv');
  write_name1=FG_check_and_rename_existed_file(write_name1);
 csvwrite( write_name1,all_DSC)        %% cliff: haven't deal with the situation that the vectors have differnt length

write_name2 = fullfile(out_dir,'Overlay_similarity_files.txt');
write_name2=FG_check_and_rename_existed_file(write_name2);
dlmwrite(write_name2, all_overlayname, 'delimiter', '', 'newline','pc');
 

fprintf('\nAll DSC calculations are done!...\n\n')
