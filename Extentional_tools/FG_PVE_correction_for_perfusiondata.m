function FG_PVE_correction_for_perfusiondata(Imgs,Grays,Whites,smooth_kernel)
if nargin==0
    Imgs=spm_select(inf,'any','Select the Mean_CBF*.imgs that need to do PVE-correction', [],pwd,'.*nii$|.*img$');  
    if isempty(Imgs), return; end
    
    Grays=spm_select(inf,'any','Select the corresponding original Gray-matters to each Img', [],pwd,'^c1.*nii$|^c1.*img$');  
    if isempty(Grays), return; end
    
    Whites=spm_select(inf,'any','Select the corresponding original White-matters to each Img', [],pwd,'^c2.*nii$|^c2.*img$');  
    if isempty(Whites), return; end
    
    prompt = {'Specify the smooth kernel that will be applied to the T1 tissues(e.g. [4 4 6])'};
    dlg_title = 'Apply for the T1 tissues...';
    num_lines = 1;
    def = {'[4 4 6]'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    smooth_kernel=eval(deblank(answer{1}));    
end
    
    if size(Grays,1)~=size(Whites,1) || size(Grays,1)~=size(Imgs,1)  || size(Whites,1)~=size(Imgs,1)
        fprintf ('\nThe number of MeanCBF-imgs/gray/white-matters imgs is different...\n')
        return
    end    
    h_type=questdlg('Which matter do you want to appy the PVE-correction?','Hi....','Gray-matter','White-matter','Both','Gray-matter') ;


 
    [pathes, names,new_names,s_gray_imgs]=FG_separate_files_into_name_and_path(Grays,'s_forPVE_','prefix');
    [pathes, names,new_names,s_white_imgs]=FG_separate_files_into_name_and_path(Whites,'s_forPVE_','prefix'); 
    [path_t1, b,c,Resliced_gray_imgs]=FG_separate_files_into_name_and_path(s_gray_imgs,'resliced_','prefix'); 
    [path_t1, b,c,Resliced_white_imgs]=FG_separate_files_into_name_and_path(s_white_imgs,'resliced_','prefix');
    
    if strcmp(h_type,'Both')  
        [pathes, names,new_names,PVE_gray_imgs]=FG_separate_files_into_name_and_path(Imgs,'PVE_corred_gray_','prefix'); 
        [pathes, names,new_names,PVE_white_imgs]=FG_separate_files_into_name_and_path(Imgs,'PVE_corred_white_','prefix'); 
    elseif strcmp(h_type,'Gray-matter')
        [pathes, names,new_names,PVE_imgs]=FG_separate_files_into_name_and_path(Imgs,'PVE_corred_gray_','prefix');
    elseif strcmp(h_type,'White-matter')
        [pathes, names,new_names,PVE_imgs]=FG_separate_files_into_name_and_path(Imgs,'PVE_corred_white_','prefix');        
    end
    
   fprintf ('\n-----running......\n')

    for i=1:size(Grays,1)
        spm_smooth(Grays(i,:),deblank(s_gray_imgs(i,:)),smooth_kernel);  %  spm_smooth(P,Q,s,dtype)
        spm_smooth(Whites(i,:),deblank(s_white_imgs(i,:)),smooth_kernel);  %  spm_smooth(P,Q,s,dtype)

         target_Vout=spm_vol(Imgs(i,:)); % use the reference header file do define the resliced-output             
         target_Vout.fname=deblank(Resliced_gray_imgs(i,:)); 
         tem_imgs=strvcat(Imgs(1,:),s_gray_imgs(i,:));
         spm_imcalc_ui(tem_imgs,target_Vout.fname,'i2',{0,0,4,0});      %% define the datatype of the output as 4 
         
         target_Vout.fname=deblank(Resliced_white_imgs(i,:)); 
         tem_imgs=strvcat(Imgs(1,:),s_white_imgs(i,:));
         spm_imcalc_ui(tem_imgs,target_Vout.fname,'i2',{0,0,4,0});      %% define the datatype of the output as 4     
    end

    
    for i=1:size(Grays,1)
        Vmat=spm_vol(Imgs(i,:));
        V=spm_read_vols(Vmat);
        V(isnan(V))=0;
        GM=spm_read_vols(spm_vol(Resliced_gray_imgs(i,:)));
        WM=spm_read_vols(spm_vol(Resliced_white_imgs(i,:)));
        GM(find(GM<=0.3))=0;
        WM(find(WM<=0.3))=0;
        
        if strcmp(h_type,'Gray-matter')            
            V2=zeros(size(V));  
            V2(find(GM))=V(find(GM))./(GM(find(GM))+0.4*WM(find(GM)));   %%  Icorr=Iuncorr/(Pgm+0.4Pwm) 
        elseif strcmp(h_type,'White-matter')                            %% 'Hypoperfusion in frontotemporal dementia and Alzheimer disease by arterial spin labeling MRI'       
            V2=zeros(size(V));       
            V2(find(WM))=V(find(WM))./(WM(find(WM))+2.5*GM(find(WM)));  %  it was assumed that perfusion of GM is 2.5 times the perfusion of WM (Roberts et al. 1994)
        elseif strcmp(h_type,'Both')  
            V21=zeros(size(V));
            V22=zeros(size(V));        
            V21(find(GM))=V(find(GM))./(GM(find(GM))+0.4*WM(find(GM))); 
            V22(find(WM))=V(find(WM))./(WM(find(WM))+2.5*GM(find(WM)));         
        end

        if strcmp(h_type,'Both')  
            Vmat.fname=deblank(PVE_gray_imgs(i,:));
%             V21=reshape(V21,size(V));
            spm_write_vol(Vmat,V21);    
%             V22=reshape(V22,size(V));
            Vmat.fname=deblank(PVE_white_imgs(i,:));
            spm_write_vol(Vmat,V22);   
        else
            Vmat.fname=deblank(PVE_imgs(i,:));
%             V2=reshape(V2,size(V));
            spm_write_vol(Vmat,V2);
        end
    end

       fprintf ('\n-----PVE correction is done!......\n')

