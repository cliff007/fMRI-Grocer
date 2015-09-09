function FG_CBF_created_for_Heather_seq_multi_subj(sub_dirs)
if nargin==0
   sub_dirs =spm_select(inf,'dir','Select all the subj_folders containing Original ASL images acquired by Heather''s sequence', [],pwd,'.*');
end

n=size(sub_dirs,1);

for i=1:n
    ASL_imgs= spm_select('FPList',deblank(sub_dirs(i,:)),'.*img');
    FG_CBF_created_for_Heather_seq(ASL_imgs);
end

fprintf('\n----All subjects are done...\n')