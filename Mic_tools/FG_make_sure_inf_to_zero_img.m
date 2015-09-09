function img=FG_make_sure_inf_to_zero_img(img)
% this function is used to make the input image is a binary image and make
% the inf values to 0
img(isinf(img))=0;

