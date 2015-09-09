function outpoints = FG_mni2tal(inpoints)
% Converts coordinates from MNI brain to best guess
% for equivalent Talairach coordinates
% FORMAT outpoints = mni2tal(inpoints)
% Where inpoints is N by 3 or 3 by N matrix of coordinates
%  (N being the number of points)
% outpoints is the coordinate matrix with Talairach points
% Matthew Brett 10/8/99
if nargin==0
    dlg_prompt={'Enter a spm(MNI) Coord.: x{mm} ,y{mm} ,z{mm},or you can just close this window to select a Coord. txt file'};
    dlg_name='SPM (MNI) coordinate';
    inpoints=inputdlg(dlg_prompt,dlg_name);

    %% otherwise inquery many coordinates one time in a .txt file
     if isempty(inpoints) || strcmp(inpoints{1},'')
        % select the .txt file that contain all the sphere coordinate (as below)
                % coordinate.txt  (if your file is .mat format, please load and save as .txt first, sorry!)
                    % the coordinates it contain is as below( a group of x/y/z(mm) each line)
                    %      1     2     3
                    %      4     5     6
                    %     -1    -2    -3
          if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
               coord_txt = spm_select(1,'.txt','Select the txt file where the voxel-space coordinates are in:', [],pwd,'.*txt');
               eval(['inpoints=load(''' coord_txt ''');']);
          end
     else
         inpoints=str2num(inpoints{1});    
     end
end

%  inpoints=inpoints;
dimdim = find(size(inpoints) == 3);
if isempty(dimdim)
  error('input must be a N by 3 or 3 by N matrix')
end
if dimdim == 2
  inpoints = inpoints';
end

% Transformation matrices, different zooms above/below AC
upT = spm_matrix([0 0 0 0.05 0 0 0.99 0.97 0.92]);
downT = spm_matrix([0 0 0 0.05 0 0 0.99 0.97 0.84]);

tmp = inpoints(3,:)<0;  % 1 if below AC
inpoints = [inpoints; ones(1, size(inpoints, 2))];
inpoints(:, tmp) = downT * inpoints(:, tmp);
inpoints(:, ~tmp) = upT * inpoints(:, ~tmp);
outpoints = inpoints(1:3, :);
if dimdim == 2
  outpoints = outpoints';
end
fprintf('\n\n-------see the output below(row by row):\n')
fprintf('\n------------Coordinate transformation is done!\n')


