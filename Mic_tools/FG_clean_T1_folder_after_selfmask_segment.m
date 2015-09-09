function FG_clean_T1_folder_after_selfmask_segment
pth=spm_select(inf,'dir','Select the T1 folders under which selfmask-segment was done', [],pwd);
a=pwd;

butt = questdlg('Three levels''s T1 data cleaning...','What do you want to keep...','Only *seg_sn.mat left','c1/c2/c3 also left','selfmasks also left','Only *seg_sn.mat left') ;
if isempty(butt)
    return
end

for i=1:size(pth,1)
    cd(deblank(pth(i,:)))
    delete('s_Filled_resliced_Binary*.*')
    delete('Filled_resliced_Binary_GW*.*')
    delete('resliced_Binary_GW*.*')
    delete('Binary_GW*.*')

    if strcmp(butt,'Only *seg_sn.mat left')
        delete('Binarized_s_Filled_resliced_Binary_GW*.*')
        delete('c1*.*')
        delete('c2*.*')
        delete('c3*.*')
    elseif strcmp(butt,'c1/c2/c3 also left')
        delete('Binarized_s_Filled_resliced_Binary_GW*.*')   
    end
    fprintf('\n    == T1 data under path %d has been cleaned...\n',i)
    cd(a);
end

fprintf('\n ---- All T1 data has been cleaned...\n')