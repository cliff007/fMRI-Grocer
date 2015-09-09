
% cliff revised, now it is only support SPM5/8

function FG_snap_to_makeMovie
%-GUI setup
%-----------------------------------------------------------------------
SCCSid  = '0.6';
SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Analyze Movie Maker',0);
fprintf('AnalyzeMovie Toolbox 0.6\n');

spm('FigName','Analyze Image Movie Maker',Finter,CmdLine);
% get the name of the rois file.

% movieSize = spm_input('Movie size?','+1','m',...
%     ['Small (200x200)|', ...
%         'Medium (300x300)|', ...
%         'Large (400x400)|'],[1 2 3],1);

imageView = spm_input('Image View?','+1','m',...
    ['Axial|', ...
        'Coronal|', ...
        'Sagitall|All'],[1 2 3 4],1);
    
%  imageView = 4   ;

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

% pixSize = [200 300 400];

movieType= {'axial', 'coronal', 'sagital', 'ortho'};

% smoothing parameters
% nMovies = spm_input('Number of movies','+1','i','1',1,[0,Inf]);
nMovies =1;

if nMovies < 1
    spm('alert','You want to make not more than 1 movie, that mean no moive to make! Exit!','AnalyzeMovie',[],0);
    return
end

Movie_fps = spm_input('Movie-fps(frames per sec)','+1','i','2',1,[0,Inf]); % cliff

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
    
    h_repos = questdlg(sprintf('Do you want to show a specific coordinate of the image? \nOr just show the default-middle slice of each image?'), ...
                           'Reposition or not...','Enter a coordinate...','Default','Default');

    if FG_check_ifempty_return(h_repos), return; end
    if ~strcmp(h_repos,'Default')
        h_type = questdlg(sprintf('Enter a MNI coordinate or a voxel-space coordinate?'), ...
                           'Reposition or not...','MNI','Voxel-space','Voxel-space');

        if strcmp(h_type,'MNI')        
            prompt = {'Enter a MNI coordinate (mm)...'};
            dlg_title = 'MNI...';
            num_lines = 1;
            def = {'[10 -10 0]'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            new_pos=eval(answer{1});
        else strcmp(h_type,'Voxel-space')  
            prompt = {'Enter a voxel-space coordinate (x/y/z slices)...'};
            dlg_title = 'voxel-space...';
            num_lines = 1;
            def = {'[10 20 30]'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            new_pos=eval(answer{1});            
        end
    end    
end

% Now extract the files.
uiwait(msgbox(sprintf('Make sure the spm Graphic-window is not covered by any other window during this script working! \n\nEspecially under the Linux OS!!'), ...
    'Attention...','warn','modal'))

for iMovie = 1:nMovies
    [movieDir movieName] = fileparts(spmImgFiles{iMovie}(1,:));
    newMovieName = fullfile(movieDir,['avi_Movie_' ...
            movieType{imageView} '-fps ' num2str(Movie_fps) '-' compressionOpt '.avi']);
    newMovieName=FG_check_and_rename_existed_file(newMovieName);    
        
    theMovie = avifile(newMovieName,'Compression',compressionOpt,'fps',Movie_fps , ...
        'quality',compressionQuality);
    spm_progress_bar('Init',size(spmImgFiles{iMovie},1),sprintf(['Movie #' ...
            ' %d of %d'],iMovie,nMovies),'Extracting data');
    for iFile = 1:size(spmImgFiles{iMovie},1)
        spm_progress_bar('Set',iFile);
%         volHdr = spm_vol(spmImgFiles{iMovie}(iFile,:));
%         close 
        if iFile==1
            spm_image('init',spmImgFiles{iMovie}(iFile,:))  
            spm_orthviews('Xhairs','off');  % turn off the blue xhair in the spm orth-viewer
            if ~strcmp(h_repos,'Default')
                if strcmp(h_type,'Voxel-space')  
                    M=spm_vol(spmImgFiles{iMovie}(iFile,:));
                    M=M.mat;
                    new_pos=FG_vox2mni(M,new_pos);
                end
                spm_orthviews('reposition',new_pos); 
            end
        else  % actually, nothing different from above situation
            spm_image('display',spmImgFiles{iMovie}(iFile,:))
            spm_orthviews('Xhairs','off');  % turn off the blue xhair in the spm orth-viewer
            if ~strcmp(h_repos,'Default')
                if strcmp(h_type,'Voxel-space')  
                    M=spm_vol(spmImgFiles{iMovie}(iFile,:));
                    M=M.mat;
                    new_pos=FG_vox2mni(M,new_pos);
                end                
                spm_orthviews('reposition',new_pos); 
            end 
        end
        
        global st   
        Fgraph = spm_figure('GetWin','Graphics'); % make the spm-graphic window on the top
        % Fgraph = spm_figure('FindWin','Graphics')
        switch imageView 
            case 1   % Axial - a      
                curFrame = getframe(st.vols{1}.ax{1}.ax);
                if  iFile==1 
                    tem=size(curFrame.cdata);
                else
                    if ~FG_issame(tem,size(curFrame.cdata))
                        tem1=size(curFrame.cdata);
%                         crop_x=floor((tem1(1)-tem(1))/2);
%                         crop_y=floor((tem1(2)-tem(2))/2);
%                         curFrame.cdata=imcrop(curFrame.cdata,[crop_y,crop_x,tem(2)-1,tem(1)-1]);
                        curFrame.cdata=imresize(curFrame.cdata,[tem(1),tem(2)]);
                    end
                end
            case 2    % Coronal  - c          
                curFrame = getframe(st.vols{1}.ax{2}.ax);  
                if  iFile==1 
                    tem=size(curFrame.cdata);
                else
                    if ~FG_issame(tem,size(curFrame.cdata))
                        tem1=size(curFrame.cdata);
%                         crop_x=floor((tem1(1)-tem(1))/2);
%                         crop_y=floor((tem1(2)-tem(2))/2);
%                         curFrame.cdata=imcrop(curFrame.cdata,[crop_y,crop_x,tem(2)-1,tem(1)-1]);
                        curFrame.cdata=imresize(curFrame.cdata,[tem(1),tem(2)]);
                    end
                end                
            case 3     % Sagitall  - s     
                curFrame = getframe(st.vols{1}.ax{3}.ax);
                if  iFile==1 
                    tem=size(curFrame.cdata);
                else
                    if ~FG_issame(tem,size(curFrame.cdata))
                        tem1=size(curFrame.cdata);
%                         crop_x=floor((tem1(1)-tem(1))/2);
%                         crop_y=floor((tem1(2)-tem(2))/2);
%                         curFrame.cdata=imcrop(curFrame.cdata,[crop_y,crop_x,tem(2)-1,tem(1)-1]);
                        curFrame.cdata=imresize(curFrame.cdata,[tem(1),tem(2)]);
                    end
                end                
            case 4  % All - o     %                 
                    curFrame1 = getframe(st.vols{1}.ax{1}.ax);
                    [a1,b1,c1]=size(curFrame1.cdata);
                    curFrame2 = getframe(st.vols{1}.ax{2}.ax);
                    [a2,b2,c2]=size(curFrame2.cdata);
                    curFrame3 = getframe(st.vols{1}.ax{3}.ax);
                    [a3,b3,c3]=size(curFrame3.cdata);
%                     pos1=get(st.vols{1}.ax{1}.ax,'Position');
%                     pos2=get(st.vols{1}.ax{2}.ax,'Position');
%                     pos3=get(st.vols{1}.ax{3}.ax,'Position');
%                     pos_blank=pos2(2)-pos1(2);
%                     pos_w=pos1(3)+pos3(3);
%                     pos_h=pos1(4)+pos2(4);
                      pos_blank=(1/18)*a1;
%                 end
                curFrame = getframe(st.vols{1}.ax{1}.ax,[0,0,b1+b3+pos_blank,a1+a2+pos_blank]);
                if  iFile==1 
                    tem=size(curFrame.cdata);
                else
                    if ~FG_issame(tem,size(curFrame.cdata))
                        tem1=size(curFrame.cdata);
%                         crop_x=floor((tem1(1)-tem(1))/2);
%                         crop_y=floor((tem1(2)-tem(2))/2);
%                         curFrame.cdata=imcrop(curFrame.cdata,[crop_y,crop_x,tem(2)-1,tem(1)-1]);
                        curFrame.cdata=imresize(curFrame.cdata,[tem(1),tem(2)]);
                    end
                end                
        end
        theMovie = addframe(theMovie,curFrame);
                            %   --------------    --------------------------      
                            %   |            |    |                        | 
                            %   | ax{2}.ax   |    |       ax{3}.ax         |
                            %   |            |    |                        |
                            %   |  coronal   |    |       sagitall         |
                            %   -------------|    -------------------------|
                            %   
                            %   --------------        
                            %   |            |
                            %   |  ax{1}.ax  |
                            %   |            |
                            %   |            |
                            %   |   axial    | 
                            %   |            |
                            %   |            |         
                            %   -------------|       
    end
    theMovie=close(theMovie);
end

spm_progress_bar('Clear');
spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');


fprintf('\n---------AVI movie making is done:\n %s\n',newMovieName);

