function pth=FG_read_root_of_an_img(imgs)
img=deblank(imgs(1,:));
[pth,name]=FG_separate_files_into_name_and_path(img);
clear name