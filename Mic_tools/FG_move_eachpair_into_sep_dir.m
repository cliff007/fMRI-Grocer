function FG_move_eachpair_into_sep_dir

clc
root_dir = FG_module_select_root('Select the root folder of your imgs');

imgs = spm_select(inf,'any','Select all the functional imgs(*.img/*.nii) under the root folder', [],pwd,'.*img|.*nii');
if isempty(imgs), return; end  
    
%[a,b,c,d]=fileparts(imgs)    
imgs=spm_str_manip(imgs,'dc');  % take use of the "spm_str_manip" function
  if size(imgs,1)==1
      [a,b,c,d]=fileparts(imgs);
      imgs=[b c];
  end
  
 h=questdlg('Do you want to specify a series of subj folder names for the the new folders that will be created?','Do you have an old folder structure?','I do have an old folder structure','No','No') ;   
 pause(0.5)
 if strcmp(h,'No')
            % create all the timepoint folders
            for i=1:size(imgs,1)
%                 if i<10
%                     mkdir(['Sub0' num2str(i)]) ;
%                 elseif i>9 & i<100
%                     mkdir(['Sub' num2str(i)]) ;
%                 end

                %% take advantage of "sprintf" function to deal with these cases
                mkdir (['Sub' num2str(sprintf('%0.5d',i))]) % at most to deal with 99999 files at one time. It shoud be enough for most of cases
            end

            fprintf('\n---- Moving files....')
            for j=1:size(imgs,1)
                    [a,b,c,d]=fileparts(deblank(imgs(j,:)));
                    if strcmpi(c,'.img')
%                         if j<10
%                             movefile([b c],[ 'Sub0' num2str(j) filesep]) ;
%                             movefile([b '.hdr'],[ 'Sub0' num2str(j) filesep]) ;
%                         elseif j>9 & j<100
%                             movefile([b c],[ 'Sub' num2str(j) filesep]) ; 
%                             movefile([b '.hdr'],[ 'Sub' num2str(j) filesep]) ;
%                         end
                        movefile([b c],['Sub' num2str(sprintf('%0.5d',j)) filesep]) ; 
                        movefile([b '.hdr'],['Sub' num2str(sprintf('%0.5d',j)) filesep]) ;                             
                    elseif strcmpi(c,'.nii')
%                         if j<10
%                             movefile([b c],[ 'Sub0' num2str(j) filesep]) ;
%                         elseif j>9 & j<100
%                             movefile([b c],[ 'Sub' num2str(j) filesep]) ; 
%                         end                         
                       movefile([b c],['Sub' num2str(sprintf('%0.5d',j)) filesep]) ;                          
                    end                        
            end
            
 elseif strcmp(h,'I do have an old folder structure')
     ref_dirs = spm_select(inf,'dir','Select the subj folders to save your fun. imgs(same num as your selected fun. imgs)', [],pwd);
     if isempty(ref_dirs)
         return
     end
     if size(imgs,1)~=size(ref_dirs,1)
        fprintf('\n---- Folder num is different from your selected imgs num!!\n\n')
        return
     end
     
     ref_dirs=spm_str_manip(spm_str_manip(ref_dirs,'dh'),'dc');  % take use of the "spm_str_manip" function

    if size(ref_dirs,1)==1   % in this condition, [spm_str_manip(spm_str_manip(ref_dirs,'dh'),'dc')] can't get the group dirctories
       i=size(ref_dirs,2); 
       success=0;
       for j=i:-1:1
           if ref_dirs(j)==filesep
               success=1;
               break
           end
       end
       if success==1
           ref_dirs=ref_dirs(j+1:end);
       end
    end
    
    
    % create all the timepoint folders
    for i=1:size(ref_dirs,1)
        mkdir(deblank(ref_dirs(i,:))) ;
    end

    fprintf('\n---- Moving files....')
    for j=1:size(imgs,1)
        [a,b,c,d]=fileparts(deblank(imgs(j,:)));
        if strcmpi(c,'.img')
            movefile([b c],[deblank(ref_dirs(j,:)) filesep]) ; 
            movefile([b '.hdr'],[deblank(ref_dirs(j,:)) filesep]) ;
        elseif strcmpi(c,'.nii')
            movefile([b c],[deblank(ref_dirs(j,:)) filesep]) ; 
        else % for other files rather than just the image file
            movefile([b c],[deblank(ref_dirs(j,:)) filesep]) ; 
        end
    end    
    
 end

fprintf('\n---- All set!\n\n')
