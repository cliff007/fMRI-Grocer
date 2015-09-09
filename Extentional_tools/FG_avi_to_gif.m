function FG_avi_to_gif(aviName, gifName, numLoops, FPS)
% AVI_TO_GIF
%------------------------------------------------------------------
% Simple function to convert *.avi movies to animated *.gif files
% Usage: FG_AVI_TO_GIF(AVINAME, GIFNAME, NUMLOOPS, FPS)
%   NUMLOOPS - has to be between 1 and 65535
%------------------------------------------------------------------


warning off;

% read-in avi information
avi_inf = aviinfo(aviName);
num_frames = avi_inf.NumFrames;
if(numLoops < 1),
    numLoops = 1;
elseif(numLoops > 65535)
    numLoops = 65535;
end
if(FPS < 1),
    FPS = 1;
elseif(FPS > 100),
    FPS = 100;
end

% check if gif file already exists
writeMode = 'append';
button = 'No';
fid = fopen(gifName);
while(fid>0),
    fclose(fid);
    fid = -1;
    button = questdlg(['File ' gifName ' already exists. Do you want to overwrite?'],'Gif Overwrite?');
    if(numel(strmatch(button,'No'))),
        gifName = inputdlg('Enter new file name:','Save to Gif');
        fid = fopen(gifName);
    end    
end

% read-in one frame at a time
% and write to gif file

write_gray = true; %currently matlab does not support color GIF files.

wait_bar = waitbar(0,'Converting to Gif file...');
for frm=1:num_frames,
    if(frm == 1),
        writeMode = 'overwrite';
    else
        writeMode = 'append';
    end
    
    gif_data = [];
    Frm = aviread(aviName,frm);
    gif_data(:,:,:,1) = Frm(1).cdata;
    % check if user wants a gray-scale gif file
    if(write_gray),        
        if isrgb(Frm(1).cdata) % cliff
            gif_data = [];
            gif_data(:,:,:,1) = rgb2gray(Frm(1).cdata);
        end
    end
    
    % write (append) one frame at a time, this is especially useful when
    % the avifile is very large and may lead to 'out-of-memory' errors if
    % read at once.
    if(frm == 1),
        imwrite(gif_data, gifName,'LoopCount',numLoops,'WriteMode',writeMode,'DelayTime',1/FPS);
    else
        imwrite(gif_data, gifName,'LoopCount',numLoops,'WriteMode',writeMode,'DelayTime',1/FPS);
    end
    
    waitbar(frm/num_frames, wait_bar);
end
close(wait_bar);
