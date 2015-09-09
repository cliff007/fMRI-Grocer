function varargout=FG_simpleresliceROI_to_target_space(imgs,target)
if nargin==0
   imgs= spm_select(inf,'any','Select all the imgs you want to reslice ', [],pwd,'.*nii$|.*img$'); 
   if isempty(imgs),return,end
   target =  spm_select(1,'any','Select a img used to define the target space ', [],pwd,'.*nii$|.*img$');
   if isempty(target),return,end
end

newnames=[];
for i=1:size(imgs,1)
    two_imgs=strvcat(deblank(target),deblank(imgs(i,:)));
    [pth,name,ext,even]=FG_fileparts(deblank(imgs(i,:)));
    
    clear even
    
    target_mat=spm_vol(target);
    new_name=['resliced_' name '_as_' num2str(target_mat.dim(1)) 'x' num2str(target_mat.dim(2)) 'x' num2str(target_mat.dim(3)) ext];
    target_mat.fname=fullfile(pth,new_name);
    spm_imcalc(spm_vol(two_imgs),target_mat,'i2',{0,0,0});     
    newnames=strvcat(newnames,target_mat.fname);
end

if nargout~=0
    varargout={newnames};
end
