function FG_view_multiple_imgs_as_mricro
clc
%  spm_figure('close',allchild(0))
a=findobj('Tag','as_mricro');
if ~isempty(a)
    h=questdlg('Do you want to close all the figures has opened by me before?','Close all or not...','Yes','No','Yes');
    if strcmp(h,'Yes')
        % close all
        close (findobj('Tag','as_mricro'));
        clear a
    end
end

% [filename, pathname] = uigetfile({'*.img', 'ANALYZE or NIFTI files (*.img)';'*.nii','NIFTI files (*.nii)'},	'Pick one brain map');
% root_dir = spm_select(1,'dir','Select the root folder of fMRI_stduy', [],pwd);
%     if isempty(root_dir)
%        return
%     end
     
% cd (root_dir)

fun_imgs =  spm_select(inf,'any','Select mutiple Imgs(e.g. SPM_T.img) you want to display', [],pwd,'.*img$|.*nii$');
    if isempty(fun_imgs)
        return
    end
i_imgs=size(fun_imgs,1);

a=which('fmri_grocer');
[b,c,d,e]=fileparts(a);
defpath=[b filesep 'Templates'];

clear a b c d e



for i=1:i_imgs
    % eval(['persistent fig_h',num2str(i)])  % optional
    fig_h=FG_rest_sliceviewer('Showimage','');
    FG_rest_sliceviewer('ShowOverlay', fig_h,deblank(fun_imgs(i,:)));
    set(fig_h,'Tag','as_mricro');
    if i==1
       a=get(fig_h,'Position');
       b=get(0,'ScreenSize') ;
      %  WS   = spm('WinScale');	
    end
    if i_imgs>1
        if (b(3)/i_imgs)<a(3)
            set(fig_h,'Position',[(i-1)*b(3)/i_imgs a(2) a(3) a(4)])
        else
            set(fig_h,'Position',[(i-1)*a(3) a(2) a(3) a(4)])
        end
    end
    clear fig_h  %% Very Very important!!! If you don't clear these handles you create, these figure handles will stay in the function workspace
                                  % then if you close some figures before you run this script agagin, there will be lots of invaild figure handles casuing the
                                  % problem of "Error using ==> setInvalid handle object"
end