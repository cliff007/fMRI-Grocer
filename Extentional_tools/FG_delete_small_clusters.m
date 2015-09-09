function Vout=FG_delete_small_clusters(V,thresh)
% thresh is used to define the rate of the 
if nargin<2
    thresh=0.25;
end

[V1,n]=bwlabeln(V,18);
fprintf('\n--- there are %d clusters in the input...\n',n)
for i=1:n
    N_vols(i)=length(find(V1==i));
end

N_vols_bp=N_vols;
N_vols=sort(unique(N_vols),'descend');
cut_N=ceil(length(N_vols)*thresh); % use ceil to avoid the situation that only 1 cluster left
cutoff=N_vols(cut_N);

for i=1:n
    if N_vols_bp(i)<=cutoff
        V1(V1(:,:,:)==i)=0;
    end
end

%% new clusters
[Vout,n]=bwlabeln(V1,18);

fprintf('\n--- there are %d clusters in the output...\n',n)