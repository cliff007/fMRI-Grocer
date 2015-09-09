

function FG_img_pair_manipulation
% specify the num of imgs in each subject's dir

imgs_pair_1 = spm_select(inf,'any','Select all the normalized_imgs of one group', [],pwd,'.*img$|.*nii$');
if isempty(imgs_pair_1)
    return
end
imgs_pair_2 = spm_select(inf,'any','Select all the normalized_imgs of another group', [],pwd,'.*img$|.*nii$');
if isempty(imgs_pair_2)
    return
end

if size(imgs_pair_1,1)~=size(imgs_pair_2,1)
    fprintf('\n--------- the total image number is ODD....\n\n') 
    return;
end

expression=inputdlg('Enter the image manipulatation expression:','Hi...',1,{'(i1-i2)*100./i2'});
expression=deblank(expression{1});

root_dir = FG_module_select_root('Select the directory where to store the outputs');

for i=1:size(imgs_pair_1,1)
    fprintf('\n----- pair %d ...',i)
    tem=strvcat(deblank(imgs_pair_1(i,:)),deblank(imgs_pair_2(i,:)));
    [a1,b1,c1,d1]=fileparts(deblank(imgs_pair_1(i,:)));
    [a2,b2,c2,d2]=fileparts(deblank(imgs_pair_2(i,:)));
    new_name=fullfile(root_dir,[b1  '_Operated_' b2  c1]);
    spm_imcalc_ui(tem,new_name,expression,{0, 0, 16, 0});  % se the datatype as Float32 
end

fprintf('\n----- Image manipulation: %s  are all done............\n',expression)