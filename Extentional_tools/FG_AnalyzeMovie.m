%+---------------------------------------
%|
%| Robert C. Welsh
%| 2002.10.25
%| 
%| University of Michigan
%| Department of Radiology
%|
%| A Tool box for turning analyze 
%| images into a little kine-loop.
%| 
%| Output is AVI.
%| 
%|
%| Options are the size of the movie and the 
%| views.
%| 
%| NOTE ON UNIX THERE IS NO OPTION TO COMPRESS, SO THE
%| FILES GET REALLY BIG!!!
%|
%| 
%| 2002.12.02 - RCWelsh
%|
%| PCWin Compression Enabled.
%| 
%| BATCH IS NOT SUPPORTED.
%|
%+---------------------------------------
% cliff revised, now it is only support SPM5/8

function FG_AnalyzeMovie

SCCSid  = '0.6';

% global BCH; %- used as a flag to know if we are in batch mode or not.

%-GUI setup
%-----------------------------------------------------------------------

SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Analyze Movie Maker',0);
fprintf('AnalyzeMovie Toolbox 0.6\n');

spm('FigName','Analyze Image Movie Maker',Finter,CmdLine);
% get the name of the rois file.

movieSize = spm_input('Movie size?','+1','m',...
    ['Small (200x200)|', ...
        'Medium (300x300)|', ...
        'Large (400x400)|'],[1 2 3],1);

imageView = spm_input('Image View?','+1','m',...
    ['Axial|', ...
        'Coronal|', ...
        'Sagitall|All'],[1 2 3 4],1);

% Based if this is a windows machine then we can ask for compression type.

compressionQuality = 100;

if strcmpi(computer,'PCWIN')  % cliff£º regexpi(computer,'PCWIN')  ??
    compressionOpt=spm_input('Compression?','+1','m',...
        ['none|', ...
            'Indeo3|Indeo5|', ...
            'Cinepak'],[1 2 3 4],1);
    switch  compressionOpt
    case 1
        compressionOpt = 'none';
    case 2
        compressionOpt = 'Indeo3';
    case 3
        compressionOpt = 'Indeo5';
    case 4
        compressionOpt = 'Cinepak';
    otherwise  
        compressionOpt = 'none';
    end
    if strcmp(compressionOpt,'none') == 0
        compressionQuality = spm_input('Comression Quality (100=HQ):',...
            '+1','w',100,1,100);
    end 
else
    compressionOpt = 'none';
end

pixSize = [200 300 400];

movieType= ['a' 'c' 's' 'o'];

% smoothing parameters
nMovies = spm_input('Number of movies','+1','i','1',1,[0,Inf]);

if nMovies < 1
    spm('alert','You want to make not more than 1 movie, that mean no moive to make! Exit!','AnalyzeMovie',[],0);
    return
end

Movie_fps = spm_input('Movie-fps(frames per sec)','+1','i','2',1,[0,Inf]); % cliff

prompt = {'-------------X-slice(78~1)------------------------------------------------------', ...
          '-------------Y-slice(112~1)-----------------------------------------------------', ...
          '-------------Z-slice(50~1)------------------------------------------------------'};
dlg_title = 'Select X/Y/Z slice(default is the mid-slice)';
num_lines = 1;
def = {'78','112','50'};
XYZ_slices = inputdlg(prompt,dlg_title,num_lines,def,'on');

spmImgFiles = {};
for iMovie = 1:nMovies
    spmImgFiles{iMovie}  = spm_select([0,Inf],'image',sprintf(['Pick' ...
            ' Image files for movie %d'],iMovie),'',0);
    if (length(spmImgFiles{iMovie})< 2)
        spm('alert','Not more than 2 images selected, so No movie to make! Exit!','AnalyzeMovie',[],0);
        spm_clf(Finter);
        spm('FigName','Aborted AnalyzeMovie',Finter,CmdLine);
        spm('Pointer','Arrow');
        return
    end
end

% Now extract the files.


figMovie=figure;
close(figMovie);
figMovie=figure(figMovie);
set(figMovie,'visible','off');
set(figMovie,'DoubleBuffer','on');
set(figMovie,'color',[0 0 0]);
curPos = get(figMovie,'Position');
set(figMovie,'Position',[curPos(1) curPos(2) pixSize(movieSize) pixSize(movieSize)]);
set(figMovie,'visible','on');
for iMovie = 1:nMovies
    [movieDir movieName] = fileparts(spmImgFiles{iMovie}(1,:));
    newMovieName = fullfile(movieDir,['MRI-Movie_' ...
            movieType(imageView:imageView) '-fps ' num2str(Movie_fps) '-' compressionOpt '.avi']);
    theMovie = avifile(newMovieName,'Compression',compressionOpt,'fps',Movie_fps , ...
        'quality',compressionQuality);
    spm_progress_bar('Init',size(spmImgFiles{iMovie},1),sprintf(['Movie #' ...
            ' %d of %d'],iMovie,nMovies),'Extracting data');
    for iFile = 1:size(spmImgFiles{iMovie},1)
        spm_progress_bar('Set',iFile);
        volHdr = spm_vol(spmImgFiles{iMovie}(iFile,:));
        slices = movieView(volHdr,str2num(XYZ_slices{1}),str2num(XYZ_slices{2}),str2num(XYZ_slices{3}));
        %aVol = spm_read_vols(spm_vol(spmImgFiles{iMovie}(iFile,:)));
        %[nX nY nZ] = size(aVol);
        %midX = floor(nX/2);
        %midY = floor(nY/2);
        %midZ = floor(nZ/2);
        switch imageView
        case 1
            aSlice = slices.aS;
            %aSlice = squeeze(aVol(:,:,midZ));
        case 2
            aSlice = rot90(slices.cS,1);
            %aSlice = squeeze(aVol(:,midY,:));
        case 3
            aSlice = rot90(slices.sS,1);
            %aSlice = squeeze(aVol(midX,:,:));
        case 4 
            aSlice = slices.ortho;
        end
        aSlice = aSlice/max(aSlice(:));
        aSlice = aSlice*256;
        figure(figMovie);
        image(aSlice);
        axis image;
        colormap(gray(256));
        curFrame = getframe(gca);
        theMovie = addframe(theMovie,curFrame);
    end
    theMovie=close(theMovie);
end

spm_progress_bar('Clear');
spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');

close(figMovie);

fprintf('\nFinished  making movie : %s\n',newMovieName);


% A macro to build the viws (based on spm_orthoviews)
% Robert C. Welsh 
% Dept of Radiology
% University of Michigan
% 2002.10.29
% Version 0.1%
% rcwelsh@umich.edu

function results = movieView(vHdr,xslice, yslice, zslice)
%% bounding box =[-78 -112 -50; 
%%                78   76   85]
%% xslice, yslice, zslice, abs(x/y/zslice) should be less than 78/112/50
%% defaults: xslice=78, yslice=112, zslice=50

if nargin==1
   xslice=78; yslice=112; zslice=50 ;
elseif  nargin==2
   yslice=112; zslice=50 ;
elseif  nargin==3
   zslice=50 ;    
end
    
bb = [-78 -112 -50; 78 76 85]; % bounding box(mm) which is realtive to AC as in the SPM

Dims = diff(bb)'+1;  % x-length=78-(-78);    y-length=76-(-112);     z-length=85-(-50);

TM0 = [ 1 0 0 xslice+1;...
        0 1 0 yslice+1;...
        0 0 1 0;...
        0 0 0 1];
CM0 = [ 1 0 0 xslice+1;...
        0 0 1 zslice+1;...
        0 1 1 0;...
        0 0 0 1];
SM0 = [ 0 -1 0 yslice+1;...
        0 0 1 zslice+1;...
        1 0 0 0;...
        0 0 0 1];

TD = [Dims(1) Dims(2)];
CD = [Dims(1) Dims(3)];
SD = [Dims(2) Dims(3)];

notSure = [1 0 0 0; 0 1 0 0 ; 0 0 1 0; 0 0 0 1];

TM = inv(TM0*(notSure\vHdr.mat)); % transforms the data into each plane (transverse, coronal, and sagittal)
CM = inv(CM0*(notSure\vHdr.mat));
SM = inv(SM0*(notSure\vHdr.mat));


axialSlice = spm_slice_vol(vHdr,TM,TD,0);
coronalSlice = spm_slice_vol(vHdr,CM,CD,0);
sagittalSlice = spm_slice_vol(vHdr,SM,SD,0);

results.aS = axialSlice;
results.cS = coronalSlice;
results.sS = sagittalSlice;

bigPix = zeros(Dims(2)+Dims(3),Dims(1)+Dims(2));

bigPix(1:Dims(2),1:Dims(1)) = rot90(axialSlice,1);
bigPix(Dims(2)+1:Dims(2)+Dims(3),1:Dims(1)) = rot90(coronalSlice);
bigPix(Dims(2)+1:Dims(2)+Dims(3),Dims(1)+1:Dims(1)+Dims(2)) = ...
    rot90(sagittalSlice);

results.ortho=bigPix;

return

%
% all done
% 

