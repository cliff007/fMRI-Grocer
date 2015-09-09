function calculate_averageXYZ
% the peak voxel's MNI coordinate is the same as SPM, but not as it shown  in Mricro
% this code modified from [find_peak_voxel.m]
clc;
       
      if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
           filename = spm_select(1,['.img|.nii'],'Select a ROI or Mask img file', [],pwd,'.*');
      end
if isempty(filename)
    return
end
% get the clusters in the mask
V1=spm_vol(filename);
[k1,l1]=spm_read_vols(V1); 

[mask,num_clusters]=bwlabeln(k1,18); % find out all the clusters in the img using the edge connectivity standard (18,default is 26)
%num_clusters=max(max(max(mask)));% get the num of clusters
[a,b,c,d]=fileparts(filename);
avg_xyz_name=[b,'avg_xyz.txt'];
dlmwrite(avg_xyz_name,strcat('this ROI has ',int2str(num_clusters),' clusters'),'delimiter','','newline','pc')

for j=1:num_clusters  % search in each cluster 
    x1=[];y1=[];z1=[];
    %%  get the voxels' position of all the voxels in a cluster
    [x1,y1,z1]=ind2sub(size(mask),find(mask==j));
    num_voxels=length(x1);% get the number of voxels in a cluster
    fprintf(1,'the %2.0f cluster has %2.0f voxels\n',j,num_voxels)
    dlmwrite(avg_xyz_name,strcat('cluster',int2str(j),' has ',int2str(num_voxels),' voxels'),'delimiter','','-append','newline','pc') 
    
    %% transform the voxel-space to MNI-space, then caculate the mean value of these voxels in X/Y/Y direcion separately
    MNI=vox2mni(V1.mat,[x1,y1,z1]');% transform the voxel-space to MNI-space
    avg_xyz_mni=mean(MNI');
    if num_voxels==1  % make sure it can write correctly when there is only one voxel
        avg_xyz_mni=MNI';
    end
    dlmwrite(avg_xyz_name,strcat('cluster',int2str(j),' voxels average xyz coordinate(MNI) is'),'delimiter','','-append','newline','pc') % save as .txt file
    dlmwrite(avg_xyz_name,avg_xyz_mni,'delimiter',' ','-append','newline','pc') % save as .txt file
end

