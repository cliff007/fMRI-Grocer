function FG_batch_reorient_T1s_origin
% batch_reorient imgs' origin into a new origin

%% modified from the SPM8 function : spm_image
% Just for SPM8/5

    P = spm_select(Inf, 'image','Images to reorient');
    if isempty(P)
        return
    end
      
    P_par=[zeros(1,3) zeros(1,3) ones(1,3) zeros(1,3)] ; % 12 parameters. see [spm_matrix.m]
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
    
    Mats = zeros(4,4,size(P,1));    
    for i=1:size(P,1),
        % get the original imgs' space matrix
        Mats(:,:,i) = spm_get_space(P(i,:));
        
    end;   
    

    for i=1:size(P,1),
        % set the new space matrix into the imgs
        spm_get_space(P(i,:),mat*Mats(:,:,i));     
    end;

    fprintf('%s \n\n','reorienting done~~')
    
  %  tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
  %  if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
  %      spm_image('init',st.vols{1}.fname);
  %  end;


