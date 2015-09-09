function FG_batch_reorient_allFun_origin
% batch_reorient imgs' origin into a new origin

root_dir=FG_module_select_root;
if any(strcmpi('return',{root_dir})), return;end

groups = FG_module_select_groups;
if any(strcmpi('return',{groups})), return;end   

all_subs_dir = spm_select(inf,'dir','Select all subjects'' folders', [],pwd);
if isempty(all_subs_dir), return;    end
dirs=spm_str_manip(spm_str_manip(all_subs_dir,'dh'),'dc');  % take use of the "spm_str_manip" function


       
%% modified from the SPM8 function : spm_image
% Just for SPM8/5
     
    P_par=[zeros(1,3) zeros(1,3) ones(1,3) zeros(1,3)];  % 12 parameters. see [spm_matrix.m]
    % set the mat(1,4),mat(2,4),mat(3,4) corresonding to the right{mm},forward{mm},up{mm}
    dlg_prompt={'right{mm} ,forward{mm} ,up{mm}:','Pitch{rad} ,Roll{rad} ,Yaw{rad}:','Zoom(leave the default setting alone)','shear(leave the default setting alone)'};
    dlg_name='reorienting (enter the MNI coordinate (mm) please)...';
    dlg_def={'0 0 0','0 0 0', '1 1 1', '0 0 0'};
    dlg_values=inputdlg(dlg_prompt,dlg_name,2,dlg_def);
    
    dlg_val=str2num(cell2mat(dlg_values(1)));
    P_par(1)=dlg_val(1);
    P_par(2)=dlg_val(2);
    P_par(3)=dlg_val(3);
    
    dlg_val=str2num(cell2mat(dlg_values(2)));
    P_par(4)=dlg_val(1);
    P_par(5)=dlg_val(2);
    P_par(6)=dlg_val(3);
    
    dlg_val=str2num(cell2mat(dlg_values(3)));
    P_par(7)=dlg_val(1);
    P_par(8)=dlg_val(2);
    P_par(9)=dlg_val(3);
    
    dlg_val=str2num(cell2mat(dlg_values(4)));   
    P_par(10)=dlg_val(1);
    P_par(11)=dlg_val(2);
    P_par(12)=dlg_val(3);   
  
    mat = spm_matrix(P_par);
    
  for g=1:size(groups,1) 
   for j=1:size(dirs,1)
       
    %P = spm_select(Inf, 'image','Images to reorient');
    P = spm_select('FPList', [root_dir deblank(groups(g,:)) filesep dirs(j,:)],'.*img$|.*nii$');
    
    Mats = zeros(4,4,size(P,1));    
    for i=1:size(P,1),
        % get the original imgs' space matrix
        Mats(:,:,i) = spm_get_space(P(i,:));
        
    end;   
    

    for i=1:size(P,1),
        % set the new space matrix into the imgs
        spm_get_space(P(i,:),mat*Mats(:,:,i));     
    end;

    fprintf('\n\n-----------Reorienting is done~~\n')
    
  %  tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
  %  if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
  %      spm_image('init',st.vols{1}.fname);
  %  end;


   end
 end
