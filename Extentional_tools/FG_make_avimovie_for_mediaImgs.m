
% cliff revised, now it is only support SPM5/8

function FG_make_avimovie_for_mediaImgs(imgs,MovieName,Movie_fps,GIForNot)

clc;
if nargin==0
    imgs=spm_select(inf,'jpg|jpeg|bmp','Select jpeg/bmp etc. pictures...',[],pwd);
    MovieName = spm_input('Enter the name of avi-movie','+1','s','avi-movie'); % cliff
%     if regexpi(computer,'PCWIN')  % cliff£º regexpi(computer,'PCWIN')  ??
%         compressionOpt=spm_input('Compression?','+1','m',...
%             ['none|', ...
%                 'Indeo3|Indeo5|', ...
%                 'Cinepak'],[1 2 3 4],1);
%         switch  compressionOpt
%         case 1
%             compressionOpt = 'none';
%         case 2
%             compressionOpt = 'Indeo3';
%         case 3
%             compressionOpt = 'Indeo5';
%         case 4
%             compressionOpt = 'Cinepak';
%         otherwise  
%             compressionOpt = 'none';
%         end
%         if strcmpi(compressionOpt,'none') == 0
%             compressionQuality = spm_input('Comression Quality (100=HQ):',...
%                 '+1','w',100,1,100);
%         end 
%     else
        compressionOpt = 'none';
%     end

    Movie_fps = spm_input('Movie-fps(frames per sec)','+1','i','2',1,[0,Inf]); % cliff
    GIForNot = spm_input('Export *.Gif or not?','+1','y/n');
    close gcf
else
    compressionOpt = 'none';    
end


% if strcmpi(compressionOpt,'none') == 0
%     mov=avifile(MovieName,'Compression',compressionOpt,'fps',Movie_fps , ...
%             'quality',compressionQuality);
% else
    mov=avifile(MovieName,'Compression',compressionOpt,'fps',Movie_fps);    
% end


 mov.colormap=colormap(bone(256));

try
    for k=1:size(imgs,1)
        fprintf([num2str(k) ' '])
        frame=imread(deblank(imgs(k,:)));
         mov=addframe(mov,uint8(frame));
%        mov=addframe(mov,double(frame));
    end
catch me
    display(me.message)
    tem=close(mov);
end

try 
    tem=close(mov);
catch me1
    display(me1.message)
end

close

fprintf(['\n---Generating GIF image... '])
if strcmpi(GIForNot,'y')
    FG_avi_to_gif(MovieName, [MovieName '.gif'], size(imgs,1), Movie_fps)
end
fprintf(['\n---done.......\n '])