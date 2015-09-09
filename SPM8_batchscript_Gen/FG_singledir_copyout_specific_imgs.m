function FG_singledir_copyout_specific_imgs(imgs,TimgP,img_series,series_names,out_dir)

if nargin==0
    imgs =  spm_select(inf,'any','Select all the imgs you want to dealwith', [],pwd,'.*img$|.*nii$');
    if FG_check_ifempty_return(imgs), return; end

    TimgP=inputdlg({'How many timepoint groups do you want to separate?'},'Timepoint group setting',1,{'3'});
    TimgP=str2num(TimgP{1});
    img_series = FG_inputdlg_selfdefined(TimgP,'Please enter the image-number series for group ','Image series...');  
    series_names = FG_inputdlg_selfdefined(TimgP,'Please enter the name of the group ','Group names...','Group');  
end

for i=1:TimgP
    tem{i}=eval(['[ ' img_series{i,:} ']']);
end
img_series=tem;
clear tem
pause(0.5) 

pth=FG_separate_files_into_name_and_path(imgs(1,:));

for i=1:TimgP
    if nargin==5
        new_dir=out_dir;
    else
        new_dir=FG_add_characters_at_the_end(pth,['_' series_names{i} filesep]);
    end
    
    if ~exist(new_dir,'dir')
        mkdir(new_dir)
    end
    
    img_tem=img_series{i};
    for j=1:length(img_tem)
        copyfile(deblank(imgs(img_tem(j),:)),new_dir);
    end
end


fprintf('\nAll set! The location of the outputed folders are same as \n  %s\n',pth)
