function FG_dice_similarity_coefficient_3D_two_groups_revised(order)

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
[subj2,full_subj2]=FG_module_select_groups(['Please select subjects under Group2...']);

if size(subj1,1) ~=size(subj2,1)
    fprintf('\nERROR:  The subj number under two groups should be the same!\n\n')
    return
end

all_DSC=[];
all_overlayname=[];

opts=FG_module_settings_of_questdlg;
% h_files=questdlg(opts.files.prom,opts.files.title,opts.files.oper{1},opts.files.oper{2},opts.files.oper{3},opts.files.oper{1}) ;

% revised by cliff: 2015.5.18
prompt = {'Enter the img order you want to select in the 1st group----------','Enter the img order you want to select in the 2nd group----------'};
dlg_title = 'Img order of Subjs of 2 groups...';
num_lines = 1;
def = {'1 3 9 8 6','5:-1:1'};
orders = inputdlg(prompt,dlg_title,num_lines,def);
for i=1:2
    img_orders{i}= eval(['[' orders{i} ']']);
end

if length(img_orders{1})~=length(img_orders{2})
   fprintf('\nERROR:  The specified file number should be the same!\n\n') 
   return
end

out_dir =  spm_select(1,'dir','Select an output directory to hold the overlay output folders', [],pwd);
pause(0.5)

% if strcmp(h_files,opts.files.oper{2})
%     img_g1 =  spm_select(inf,'any','Select the first group of images', [],pwd,'.*nii$|.*img$');
%     img_g2 =  spm_select(size(img_g1,1),'any','Select the second group of images', [],pwd,'.*nii$|.*img$'); 
%     img_g1_tem = spm_str_manip(img_g1,'dt');
%     img_g2_tem = spm_str_manip(img_g2,'dt');
% elseif strcmp(h_files,opts.files.oper{1})
%     img_g1 = spm_select(inf,'any','Select the first group of images', [],pwd,'.*nii$|.*img$');
%     img_g1_tem = spm_str_manip(img_g1,'dt');
%     img_g2_tem = img_g1_tem;
% end

  for i=1:size(subj1,1)

%       if strcmp(h_files,opts.files.oper{3})
%         img_g1 =  spm_select('FPList',deblank(full_subj1(i,:)),'.*img|.*nii');
%         img_g2 =  spm_select('FPList',deblank(full_subj2(i,:)),'.*img|.*nii');
%       elseif strcmp(h_files,opts.files.oper{2}) || strcmp(h_files,opts.files.oper{1})
%         img_g1 =  FG_combine_two_str_vectors(repmat(full_subj1(i,:),size(img_g1_tem,1),1),img_g1_tem);
%         img_g2 =  FG_combine_two_str_vectors(repmat(full_subj2(i,:),size(img_g2_tem,1),1),img_g2_tem);
%       end
       
        img_g1 =  spm_select('FPList',deblank(full_subj1(i,:)),'.*img|.*nii');
        img_g2 =  spm_select('FPList',deblank(full_subj2(i,:)),'.*img|.*nii');
        
        img_g1=img_g1(img_orders{1},:)
        img_g2=img_g2(img_orders{2},:)


        
        tem1=[deblank(subj1(i,:)),num2str(i)]; 
        tem2=[deblank(subj2(i,:)),num2str(i)];       
        
        overlay_dir=fullfile(out_dir,[tem1 '_overlay_' tem2 ]);  % cliff: what if the length of tem1 is less than 5??
        mkdir (overlay_dir);
        [DSC,overlayname]=FG_dice_similarity_coefficient_3D(overlay_dir,img_g1, img_g2,'No') ;  
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
