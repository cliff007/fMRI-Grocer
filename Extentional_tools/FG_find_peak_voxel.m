function find_peak_voxel
% this code find the peak voxel in each cluster in the img
clc;
       
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       filename = spm_select(1,['.img|.nii'],'Select an img defining the cluster(s)', [],pwd,'.*');
  end
    if isempty(filename)
        return
    end
% the peak voxel's MNI coordinate is the same as SPM, but not as it shown  in Mricro
% this code find the peak voxel in MNI coordinate, and then transform MNI  to Talairach coordinate via [icbm_spm2tal()] funcion
% at last, you can use [TalairachClient](a sofeware) to find the Broadmann  regions of these peak voxels

% get the clusters in the mask
V1=spm_vol(deblank(filename)); % read the ROI img's header file
[k1,l1]=spm_read_vols(V1); % read the ROI img

[mask,num_clusters]=bwlabeln(k1,18); % find out all the clusters in the img using the edge connectivity standard (18,default is 26)
%num_clusters=max(max(max(mask)));% get the num of clusters
fprintf(1,'this Img you selected has %2.0f clusters\n\n',num_clusters)

% find the peak voxels in different clusters, and get the peak voxel's location in voxel-space
  if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
       filename = spm_select(1,['.img|.nii'],'Select an img(mask) in which searching the peak voxel(s)', [],pwd,'.*');
  end
    if isempty(filename)
        return
    end
V=spm_vol(deblank(filename));
[k,l]=spm_read_vols(V); 

position_xyz=[];% store the peak voxels' coordinate
for j=1:num_clusters % search in each cluster 
    
    %% 1��get the voxels' position of all the voxels in a cluster
    [x1,y1,z1]=ind2sub(size(mask),find(mask==j));
    num_voxels=length(x1);% the voxels' number of a cluster
    fprintf(1,'the No. %2.0f cluster has %2.0f  voxels\n',j,num_voxels)
    fprintf('Calculating............\n')
    
    %% 2��get the value of that voxel
    voxel_value=[];
    for i=1:num_voxels
        voxel_value=[voxel_value;k(x1(i),y1(i),z1(i))]; 
    end
    max_value=max(voxel_value);  %get the maximal value of these voxels
    fprintf(1,'the No. %2.0f clusters peak voxel(s)''s value is %5.4f\n',j,max_value)

    %% 3��find all the voxels that have the maximal value
   
    for i=1:num_voxels  % we can not exclude the possibility that there are more than one voxel have the maximal value
        if max_value==k(x1(i),y1(i),z1(i))   % get the corresponding coordinate
           position_xyz=[position_xyz;x1(i),y1(i),z1(i)];
           fprintf(1,'the peak voxel''s voxel-space coordinate in the %2.0f cluster is %5.0f   %3.0f   %3.0f \n\n',j,x1(i),y1(i),z1(i))
        end
    end     
    
end



MNI=vox2mni(V.mat,position_xyz'); % transform the voxel-space to MNI-space
dlmwrite('position_xyz_MNI.txt',MNI','delimiter',' ','newline','pc') ;
position_xyz_tal=icbm_spm2tal(MNI'); % attention to the funcion of [vox2mni()],it's input and output formate
% dlmwrite('position_xyz_MNI.txt',MNI','delimiter',' ','newline','pc')
dlmwrite('position_xyz_tal.txt',position_xyz_tal,'delimiter',' ','newline','pc') % save as .txt file so that we can import it into [Talairach Client]


fprintf('\n---ALL The MNI & Tal coordinates are saved into two separate txt files under the current directory')
fprintf('\n----So far, all the coordinates are mixed together in the output files. \n------You need to separate them referring to the output in the command window yourself!')

%%% subfunctions
function MNI=vox2mni(M,VOX)
%function MNI=vox2mni(M,VOX)
%Voxel-space to MNI-space
 T=M(1:3,4);
 M=M(1:3,1:3);
 MNI=M*VOX;
 for i=1:3
	 MNI(i,:)=MNI(i,:)+T(i);
 end
return


function outpoints = icbm_spm2tal(inpoints)
dimdim = find(size(inpoints) == 3);
if isempty(dimdim)
  error('input must be a N by 3 or 3 by N matrix')
end
%%%if 3x3 matrix, make dimdim 2
if dimdim == [1 2]
  dimdim = 2;
end
%%%
if dimdim == 2
  inpoints = inpoints';
end

% Transformation matrices, different for each software package
icbm_spm = [0.9254 0.0024 -0.0118 -1.0207
	   	   -0.0048 0.9316 -0.0871 -1.7667
            0.0152 0.0883  0.8924  4.0926
            0.0000 0.0000  0.0000  1.0000];

% apply the transformation matrix
inpoints = [inpoints; ones(1, size(inpoints, 2))];
inpoints = icbm_spm * inpoints;

% format the outpoints, transpose if necessary
outpoints = inpoints(1:3, :);
if dimdim == 2
  outpoints = outpoints';
end









