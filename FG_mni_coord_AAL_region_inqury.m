%% AAL_region judgement

function FG_mni_coord_AAL_region_inqury

    dlg_prompt={'x{mm} ,y{mm} ,z{mm},or you can just close this window to select a Coord. txt file'};
    dlg_name='MNI region (mm coordinate)';
    %% inquery one by one
    dlg_values=inputdlg(dlg_prompt,dlg_name);

    %% otherwise inquery many coordinates one time in a .txt file
     if isempty(dlg_values) | strcmp(dlg_values{1},'')
        % select the .txt file that contain all the sphere coordinate (as below)
                % coordinate.txt  (if your file is .mat format, please load and save as .txt first, sorry!)
                    % the coordinates it contain is as below( a group of x/y/z(mm) each line)
                    %      1     2     3
                    %      4     5     6
                    %     -1    -2    -3
          if strcmp(spm('ver',[],1),'SPM5')|strcmp(spm('ver',[],1),'SPM8')
               coord_txt = spm_select(1,'.txt','Select the txt file where the MNI coordinates are in:', [],pwd,'.*txt');
               eval(['dlg_values=load(''' coord_txt ''');']);
          %else  
          %     roi_dir = spm_get(1,'dir','Select the directory where the ROIs(.mat) is in:'); 
          end
     end
    
   if iscell(dlg_values)   
       cor=str2num(cell2mat(dlg_values));
   else
       cor=dlg_values;
   end
    %head = spm_vol('/jet/szhu/fmri_related/REST/DPARSF_V2.0_101025/Templates/AAL_61x73x61_YCG.nii')
    %mni=cor2mni(cor)%,head.mat);
    
 for cor_num=1:size(cor,1) 
    mni=cor(cor_num,:);
    pos =1;
    tmpmni = mni(pos,:);

% list structure of voxels in this cluster
  
   x = load('TDdatabase.mat');
    [a, b] = cuixuFindStructure(tmpmni, x.DB);
    names = unique(b(:));
    index = NaN*zeros(length(b(:)),1);
    for ii=1:length(names)
        pos = find(strcmp(b(:),names{ii}));
        index(pos) = ii;
    end

    report = {};
    
    for ii=1:max(index)
        report{ii,1} = names{ii};
        report{ii,2} = length(find(index==ii));
    end
    for ii=1:size(report,1)
        for jj=ii+1:size(report,1)
            if report{ii,2} < report{jj,2}
                tmp = report(ii,:);
                report(ii,:) = report(jj,:);
                report(jj,:) = tmp;
            end
        end
    end
    report = [{'structure','# voxels'}; {'--TOTAL # VOXELS--', length(a)}; report];

    report2 = {sprintf('%s\t%s',report{1,2}, report{1,1}),''};
    for ii=2:size(report,1)
        if strcmp('undefined', report{ii,1}); continue; end
        report2 = [report2, {sprintf('%5d\t%s',report{ii,2}, report{ii,1})}];
    end

    disp(['Peak MNI coordinate: ' num2str(mni)])
    [a,b] = cuixuFindStructure(mni, x.DB);
    disp(['Peak MNI coordinate region:\n\n ' a{1}]);
    fprintf('----------------------\n\n')
   % cliff marked
 %   for kk=1:length(report2)
 %       disp(report2{kk});
 %   end
 end

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

%%%%% mni subfunction
function mni = cor2mni(cor, T)
% function mni = cor2mni(cor, T)
% convert matrix coordinate to mni coordinate
%
% cor: an Nx3 matrix
% T: (optional) rotation matrix
% mni is the returned coordinate in mni space
%
% caution: if T is not given, the default T is
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
% last revised: 2005-04-30

if nargin == 1
    T = ...
        [-4     0     0    84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

cor = round(cor);
mni = T*[cor(:,1) cor(:,2) cor(:,3) ones(size(cor,1),1)]';
mni = mni';
mni(:,4) = [];

%%%%%%%% cuixuFindStructure subfunction
function [onelinestructure, cellarraystructure] = cuixuFindStructure(mni, DB)
% function [onelinestructure, cellarraystructure] = cuixuFindStructure(mni, DB)
%
% this function converts MNI coordinate to a description of brain structure
% in aal
%
%   mni: the coordinates (MNI) of some points, in mm.  It is Nx3 matrix
%   where each row is the coordinate for one point
%   LDB: the database.  This variable is available if you load
%   TDdatabase.mat
%
%   onelinestructure: description of the position, one line for each point
%   cellarraystructure: description of the position, a cell array for each point
%
%   Example:
%   cuixuFindStructure([72 -34 -2; 50 22 0], DB)
%
% Xu Cui
% 2007-11-20
%

N = size(mni, 1);

% round the coordinates
mni = round(mni/2) * 2;

T = [...
     2     0     0   -92
     0     2     0  -128
     0     0     2   -74
     0     0     0     1];

index = mni2cor(mni, T);

cellarraystructure = cell(N, length(DB));
onelinestructure = cell(N, 1);

for ii=1:N
    for jj=1:length(DB)
        graylevel = DB{jj}.mnilist(index(ii, 1), index(ii, 2),index(ii, 3));
        if graylevel == 0
            thelabel = 'undefined';
        else
            if jj==length(DB); tmp = ' (aal)'; else tmp = ''; end
            thelabel = [DB{jj}.anatomy{graylevel} tmp];
        end
        cellarraystructure{ii, jj} = thelabel;
        onelinestructure{ii} = [ onelinestructure{ii} ' // ' thelabel ];
    end
end

function coordinate = mni2cor(mni, T)
% function coordinate = mni2cor(mni, T)
% convert mni coordinate to matrix coordinate
%
% mni: a Nx3 matrix of mni coordinate
% T: (optional) transform matrix
% coordinate is the returned coordinate in matrix
%
% caution: if T is not specified, we use:
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
%

if isempty(mni)
    coordinate = [];
    return;
end

if nargin == 1
	T = ...
        [-4     0     0    84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
coordinate(:,4) = [];
coordinate = round(coordinate);