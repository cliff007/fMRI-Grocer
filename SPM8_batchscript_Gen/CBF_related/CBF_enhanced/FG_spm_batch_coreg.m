%
% function for coregistering in BATCH mode
% takes as parameters the target and source image filenames and returns the transformation matrix 
% Note that the filenames MUST have a .img extensions for
% the script to work!
% Tname is the filename of the target image
% Sname is a matrix of filenames: coregistration matrix is obtained with the first
% image______________this means you can put the mean*.img after realign as
% the first one of the source image
% all files are coregistered to the target (according to SPM conventions). Therefore
% all source files must be already coregistered!
% Output images are not saved to disk until reslice is called
% spm_defaults must be called before calling this function to make the
% defaults global variable available
% 
% To perform coregistration, normalized mutual information is used as a
% cost function
%
%
% Author: Lia Morra
% revised by cliff


function varargout = FG_spm_batch_coreg(Tname, Sname)
% global defaults

def_flags = struct('sep',[4 2],'params',[0 0 0  0 0 0], 'cost_fun','nmi','fwhm',[7 7],...
	'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001],'graphics',1);


Vtarget = spm_vol(Tname);
Vsource = spm_vol(Sname);
x = spm_coreg(Vtarget, Vsource(1),def_flags);
M  = inv(spm_matrix(x));
MM = zeros(4,4,size(Vsource(1),1));
for j=1:size(Sname,1),
	MM(:,:,j) = spm_get_space(deblank(Sname(j,:)));
end;
for j=1:size(Sname,1),
	spm_get_space(deblank(Sname(j,:)), M*MM(:,:,j));
end;

if nargout==1
   varargout={x}; 
end
        