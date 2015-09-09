function detrended_imgs=FG_linear_detrend_selected_imgs(fun_imgs)
%% cliff: most simple linear trend removing script
if nargin==0
    fun_imgs =  spm_select(inf,'any','Select all the imgs having same orientation and resolution', [],pwd,'.*nii$|.*img$');
end

    n_img=size(fun_imgs,1);
    
    fprintf('\n -- Removing the linear trend.......\n'); 
    Vmats=spm_vol(fun_imgs);
    Vs=spm_read_vols(Vmats);
    new_Vs=reshape(Vs,prod(Vmats(1).dim),n_img)' ; % % transpose the reshpaed the 4-D matrix into 2-D so that the timecourse of each voxel was in the columns
    
    detrended_Vs=detrend(new_Vs)+repmat(mean(new_Vs),[size(new_Vs,1),1]);
    detrended_Vs=detrended_Vs';
    final_Vs=reshape(detrended_Vs,Vmats(1).dim(1),Vmats(1).dim(2),Vmats(1).dim(3),n_img);
    
    detrended_imgs=[];
    
    % build the output dir 
       Header=Vmats(1);
       ext=deblank(Header.fname);
       ext=ext(end-3:end);
       outDir=FG_separate_files_into_name_and_path(deblank(Header.fname(1,:)));
       % output dir
       outDir =sprintf('%s%s',outDir,'_detrended');
       mkdir(outDir);

    
    for i=1:n_img
        new_name=fullfile(outDir,[sprintf('%s%.8d','Detrended', i) ext]);
        FG_write_vol(Vmats(i),final_Vs(:,:,:,i),new_name,'float32')  ;
        detrended_imgs=strvcat(detrended_imgs,new_name);
    end
    
%     new_folder=[a,'_detrend']; 
%     if ~exist(new_folder,'dir')        
%         mkdir(new_folder);     
%     end
%     movefile(fullfile(a,'detrended_*.*'),new_folder); 
    
	fprintf('\n------ linear trend removing is done............\n');
