function img_name_no_dot1=FG_remove_potential_dot1_of_image_names(img_names)
% for the image names selected by spm_select(inf,'image',...), there is a ",1" 
img_name_no_dot1=[];
for i=1:size(img_names,1)
    tem=deblank(img_names(i,:));
    t=regexp(tem,',1','once');
    if ~isempty(t)
        img_name_no_dot1=strvcat(img_name_no_dot1,tem(1,1:end-2));
        fprintf('--- ",1" is removed...\n')
    else
        img_name_no_dot1=strvcat(img_name_no_dot1,tem(1,:));        
    end
end


