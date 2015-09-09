function VOX=FG_mni2vox(M,MNI)
% vox2mni transforms 3 by N vectors of coordinates in voxel-space to MNI-space. 
% In order to do so you have to feed the function with the respective 4x4 matrix M of the volume. 
% This is stored in the field "mat" of a structure created by the function spm_vol. 
% So typing MNI=vox2mni(M,VOX) will give you then a 3 by N matrix of vectors with MNI-coordinates. 
% The other function simply does the reverse.
if nargin==0
    file = spm_select(1,'.img','Select the reference img file that define the MNI-space:', [],pwd,'.*');
    M=spm_vol(file);
    M=M.mat;

    dlg_prompt={'Enter a spm(MNI) Coord.: x{mm} ,y{mm} ,z{mm},or you can just close this window to select a Coord. txt file'};
    dlg_name='SPM (MNI) coordinate';
    MNI=inputdlg(dlg_prompt,dlg_name);   
%% otherwise inquery many coordinates one time in a .txt file
     if isempty(MNI) || strcmp(MNI{1},'')
        % select the .txt file that contain all the sphere coordinate (as below)
                % coordinate.txt  (if your file is .mat format, please load and save as .txt first, sorry!)
                    % the coordinates it contain is as below( a group of x/y/z(mm) each line)
                    %      1     2     3
                    %      4     5     6
                    %     -1    -2    -3
          if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
               coord_txt = spm_select(1,'.txt','Select the txt file where the voxel-space coordinates are in:', [],pwd,'.*txt');
               eval(['MNI=load(''' coord_txt ''');']);
          end
     else
         MNI=eval(MNI{1});    
     end
end 

inpoints=MNI;
dimdim = find(size(inpoints) == 3);
if isempty(dimdim)
  error('input must be a N by 3 or 3 by N matrix')
end
if dimdim == 2
  inpoints = inpoints';
end

MNI= inpoints ;
%function VOX=mni2vox(M,MNI)
%MNI-space to Voxel-space
 T=M(1:3,4);
 M=M(1:3,1:3);
 for i=1:3
	 MNI(i,:)=MNI(i,:)-T(i);
 end
 VOX=round(inv(M)*MNI);

fprintf('\n------------Coordinate transformation is done!\n')

