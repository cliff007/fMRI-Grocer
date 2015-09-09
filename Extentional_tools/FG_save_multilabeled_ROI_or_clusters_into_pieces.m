function pic_names=FG_save_multilabeled_ROI_or_clusters_into_pieces(ROI,LabeledorNo)
if nargin==1
    LabeledorNo=1;
end

[V,header]=FG_read_vols(ROI);
[a,b,c,d]=fileparts(deblank(header.fname));
if LabeledorNo==0
    [V,n]=bwlabeln(V,18); % in this case, label it first
end

pic_names=[];
vox_vals=sort(unique(V(:)),'descend');
if vox_vals(end)<=0
   vox_vals=vox_vals(1:end-1);  % remove the potential background
end

N_clusters=length(vox_vals);

for i=1:N_clusters
    V_tem=V;
    V_tem(V_tem(:,:,:)~=vox_vals(i))=0;
    N_vox=length(find(V_tem==vox_vals(i)));
    pic_names=strvcat(pic_names,fullfile(a,[b,'_cluster_',num2str(i) '_' num2str(N_vox) ,'.nii']));
    FG_write_vol(header,V_tem,fullfile(a,[b,'_cluster_',num2str(i) '_' num2str(N_vox) ,'.nii']));
end


fprintf('\n---Totally %d clusters have been saved separately...\n',N_clusters)
