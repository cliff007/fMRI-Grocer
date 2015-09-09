%registration using DICE similarity (see wikipedia):               
%      Dice Coef = 2*intersect(A,B)/(absolute(A)+absolute(B))

function varargout=FG_dice_similarity_coefficient_3D(out_dir,img_g1, img_g2,text_or_No)
            %    %% original 2D version    
            %     function [OverlapImage DiceCoef] = DiceSimilarity2DImage(img1, img2)
            %     % This programs calculate and visualize the dice similarity (volume overlap) of 2D binary images.
            %     % This program is useful for quantifying the accuracy of 2D image
            %         %The steps are:
            %         %1. set one image non-zero values as 200
            %         img1(img1>0)=200;
            %         %2. set second image non-zero values as 300
            %         img2(img2>0)=300;
            %         %3. set overlap area 100
            %         OverlapImage = img2-img1;
            %         %4. count the overlap100 pixels
            %         [r,c,v] = find(OverlapImage==100);
            %         countOverlap100=size(r);
            %         %5. count the image200 pixels
            %         [r1,c1,v1] = find(img1==200);
            %         img1_200=size(r1);
            %         %6. count the image300 pixels
            %         [r2,c2,v2] = find(img2==300);
            %         img2_300=size(r2);
            %         %7. calculate Dice Coef
            %         DiceCoef = 2*countOverlap100/(img1_200+img2_300);
            %         %8. visualize the volumes by slicing 
            %         figure(1);image(OverlapImage);colormap(gray);title('Overlapping area used to calculate Dice Coef')

   %% 3D version for MRI images  
      if nargin==0
            img_g1 =  spm_select(inf,'any','Select the first group of images', [],pwd,'.*nii$|.*img$');
            img_g2 =  spm_select(size(img_g1,1),'any','Select the second group of images', [],pwd,'.*nii$|.*img$');
            out_dir =  spm_select(1,'dir','Select an output directory...', [],pwd);
            text_or_No='Yes';
      end
      
      if size(img_g1,1)~=size(img_g2,1)
         fprintf('\n the images number of two groups must be the same!\n')
         return
      end
      
      if FG_check_ifempty_return(out_dir), return ;end
      DiceCoef=[];
      overlay_name=[];
      
      for i=1:size(img_g1,1)
          img1=deblank(img_g1(i,:));
          img2=deblank(img_g2(i,:));
          
        [a,b,c,d]=FG_separate_files_into_name_and_path(img1);
        [a1,b1,c1,d1]=FG_separate_files_into_name_and_path(img2);
  
        [img1,img_mat1]=FG_read_vols(img1);
        [img2,img_mat2]=FG_read_vols(img2);       
        img1=FG_make_sure_binary_img(img1);
        img2=FG_make_sure_binary_img(img2);
        
      %1. set one image non-zero values as 200
        img1(img1>0)=200;
      %2. set second image non-zero values as 300
        img2(img2>0)=300;
      %3. set overlap area 100
        OverlapImage = img2-img1;
      %4. count the overlap100 pixels
        [r,c,v] = find(OverlapImage==100);
        countOverlap100=size(r);
      %5. count the image200 pixels
        [r1,c1,v1] = find(img1==200);
        img1_200=size(r1);
      %6. count the image300 pixels
        [r2,c2,v2] = find(img2==300);
        img2_300=size(r2);
      %7. calculate Dice Coef
        Coef=2*countOverlap100/(img1_200+img2_300);
        DiceCoef = [DiceCoef;Coef];
      %8. visualize the volumes by slicing       
        new_name=fullfile(out_dir,[b  '_' num2str(i) '_AND_' b1 '_' num2str(i) '.nii']); % to make names not to be too long; % cliff: what if the length of b is less than 5??
        overlay_name=strvcat(overlay_name,new_name);
        FG_write_vol(img_mat1,FG_make_sure_binary_img(OverlapImage),new_name);  
      


      end
      
      
      %9. output
      if strcmpi(text_or_No,'Yes')
          write_name1 = fullfile(out_dir,'Overlay_similarity.txt');
          write_name1=FG_check_and_rename_existed_file(write_name1);
          dlmwrite(write_name1, DiceCoef, 'delimiter', '', 'newline','pc');

          write_name2 = fullfile(out_dir,'Overlay_similarity_files.txt');
          write_name2=FG_check_and_rename_existed_file(write_name2);
          dlmwrite(write_name2, overlay_name, 'delimiter', '', 'newline','pc');
          
          write_name3=fullfile(out_dir,'Overlay_origin_files.txt');
          write_name3=FG_check_and_rename_existed_file(write_name3);
          dlmwrite(write_name3, strvcat(img_g1,'                ',img_g2), 'delimiter', '', 'newline','pc');

          fprintf('\nThe image overlay similarity coefficient is saved to %s \n',write_name1)
          fprintf('The overlay image is saved to %s \n',write_name2)    
      elseif strcmpi(text_or_No,'No')
          clc              
          fprintf('\nThe image overlay similarity coefficient are: \n') 
          varargout{1}=DiceCoef;
          varargout{2}=overlay_name;
          
      end

        
        
        
        
        
        