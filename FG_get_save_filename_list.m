function FG_get_save_filename_list

root_dir = FG_module_select_root;
if any(strcmpi('return',{root_dir})), return; end

%fileNames = spm_select(Inf,'.img|.hdr','Select mutiple imgs', [],pwd,'.*');
fileNames = spm_select(Inf,'.*','Select mutiple imgs', [],pwd,'.*');  
      if isempty(fileNames)
        return
     end   
fileNames=spm_str_manip(fileNames,'dc');  % take use of the "spm_str_manip" function
 
    if size(fileNames,1)==1   % in this condition, [spm_str_manip(spm_str_manip(dirs,'dh'),'dc')] can't get the subject dirctories
       i=size(fileNames,2); 
       success=0;
       for j=i:-1:1
           if fileNames(j)==filesep
               success=1;
               break
           end
       end
       
       if success==1
           fileNames=fileNames(j+1:end);
       end
    end 
    
    tem=[];
	for i=1:size(fileNames,1)
        tem(i,:)=[' ' fileNames(i,:)];
    end
    fileNames=tem;
    
	a=[1:size(fileNames,1)]';
	b=[num2str(a) fileNames]
    
   %% get the root_dir name 
       i=size(root_dir,2); 
       success=0;
       for j=i-1:-1:1
           if root_dir(j)==filesep
               success=1;
               break
           end
       end
       if success==1
          c_dir=root_dir(j+1:end-1);
       end
    
	dlmwrite(fullfile(root_dir,[c_dir '_selected_filenames.txt']), b, 'delimiter', '', 'newline','pc');
