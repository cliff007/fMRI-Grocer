function varargout=FG_fill_inside_Graymatter(graymatter,DEMOorNO)
    if nargin==0
       graymatter=spm_select(1,'image','Select an image') ;
       DEMOorNO=1;
    end
%     spm_image('Init',graymatter)
    Vmat=spm_vol(graymatter);
    V=spm_read_vols(Vmat);
    [a,b,c,Vmat.fname]=FG_separate_files_into_name_and_path(Vmat.fname,'Filled_','prefix');
    fontSize=16;
    %% fill the gray matter with function "imfill.m" which support 3D binary image
        grayImage=V;

%         subplot(2, 3, 1);
%         imshow(grayImage, []);
%         title('Original Grayscale Image', 'FontSize', fontSize);
%         set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

        binaryImage = grayImage>0  ;
%         subplot(2, 3, 3);
%         imshow(binaryImage, []);
%         title('Binary Image', 'FontSize', fontSize);

        % Fill the image.
        filledImage = imfill(binaryImage,8, 'holes'); %% connectivity for 8
%         subplot(2, 3, 4);
%         imshow(filledImage, []);
%         title('Filled Binary Image', 'FontSize', fontSize);

        % Negate it so the center is black.
        filledImage = ~filledImage;   % binarized
        filledImage = ~filledImage;   % reversed
%         subplot(2, 3, 5);
%         imshow(filledImage, []);
%         title('Negated Filled Binary Image', 'FontSize', fontSize);

%         % Multiply by original.
%         % finalImage = croppedImage .* uint8(filledImage);
%         finalImage = grayImage .* filledImage;
%         subplot(2, 3, 6);
%         imshow(filledImage, []);
%         title('Final Image', 'FontSize', fontSize);
        Vo =filledImage;

    spm_write_vol(Vmat,Vo);
    
    if DEMOorNO==1
        spm_image('Init',Vmat.fname)
    end
    
    if nargout==1
        varargout(1)={Vmat.fname};
    end