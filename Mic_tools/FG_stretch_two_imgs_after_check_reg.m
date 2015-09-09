% pathc for implement SPM's two images' Check_Reg
clear p1 p2 p3 h i l sc
fig_h=spm_figure('FindWin');
set(fig_h, 'Position', [600 40 1000 800])  % default: no "gcf", but  "1"
global st  % retract this global variable
h = 1;
img_n=nnz(~cellfun('isempty',st.vols));
if img_n>2  
    
    dlg_prompt={'which two imgs do you want to stretch?                                       '};
    dlg_name='As the order of the images you select ';
    dlg_def={'2 4'};
    img_label=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');  % select two images
    img_label=str2num(img_label{1});
    fprintf('\nThe No. %d and No. %d images left\n',img_label(1),img_label(2))
    tem=[1:img_n];
    left_imgs=tem(~ismember(tem,img_label));
    
    img_n=2;         % only display the first two images
    for j=1:length(left_imgs)
        i=left_imgs(j);
        delete(st.vols{i}.ax{1}.ax)  % delete all other image-object in the figure
    end
end    

for j=1:img_n
    i=img_label(j);
    p1 = get(st.vols{i}.ax{1}.ax,'Position');  % 1st plane (left-top), sagittal plane , p1 =[x,y,width, height]
    p2 = get(st.vols{i}.ax{2}.ax,'Position');  % 2nd plane (right-top), coronal plane
    p3 = get(st.vols{i}.ax{3}.ax,'Position');  % 3rd plane (left-bottom), horizontal plane
    l  = p1(3) + p2(3) + p3(3); 
    sc = (1-0.01)/l;           % sc---scale
    p1 = p1*sc; p2 = p2 * sc; p3 = p3 * sc;
    
    p1(4)=p1(3)/1.2019*1.7; p1(2)= p1(2)-p1(4);
    p2(4)=p2(3)/1.4409*1.7; p2(2)= p2(2)-p1(4);     
    p3(4)=p3(3)/1.7275*1.7; p3(2)= p3(2)-p1(4);
    
    set(st.vols{i}.ax{1}.ax,'Position',...
        [0 h-p1(4) p1(3) p1(4)]);
    set(st.vols{i}.ax{2}.ax,'Position',...
        [p1(3)+0.005 h-p2(4) p2(3) p2(4)]);
    set(st.vols{i}.ax{3}.ax,'Position',....
        [p1(3)+p2(3)+0.01 h-p3(4) p3(3) p3(4)]);
    h = h - p1(4)-0.005;
end