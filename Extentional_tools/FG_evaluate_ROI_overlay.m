function varargout= FG_evaluate_ROI_overlay 

%     prompt = {'How many groups of ROIs are going to overlay (2 <= n <= 3) ?'};
%     dlg_title = 'ROI number...';
%     num_lines = 1;
%     def = {'2'};
%     ROI_n = inputdlg(prompt,dlg_title,num_lines,def);
%     ROI_n=str2num(ROI_n{1});
% 
%     if ROI_n>3 || ROI_n<=0
%         fprintf('\n----- I can only deal with the number of ROIs that ranges between 2 and 3 .......\n')
%         return
%     end

    for i=1:2  % ROI_n
        ROIs{i}=spm_select(inf,'image',['Select ROI images for group ' num2str(i) ' ...']);
        if isempty(ROIs{i}),return,end
        V{i}=FG_read_vols(ROIs{i});
    end
    
    if size(ROIs{1},1)~=size(ROIs{2},1)
       fprintf('\n---Error, different number of ROIs in these two groups.......\n')
       return
    else
       n_img=size(ROIs{1},1);
    end
    
    [all_pth,all_name]=FG_separate_files_into_name_and_path(ROIs{1}); 
    all_name=FG_remove_potential_dot1_of_image_names(all_name);
    fprintf('\n------------\n\n')
    
    for i=1:n_img
        a=V{1}(:,:,:,i);
        b=V{2}(:,:,:,i);
        a(isnan(a))=0;
        b(isnan(b))=0;
        a=double(logical(a));
        b=double(logical(b));
        shape_r(i,1) = FG_corr(a(:), b(:)) ;% FG_corr only accept row/column vectors
        c=a.*b;
        n_vox_overlay(i,1)=size(find(c),1);
        n_vox_a(i,1)=size(find(a),1);
        n_vox_b(i,1)=size(find(b),1);
        overlay_percent_a(i,1)=n_vox_overlay(i,1)*100/n_vox_a(i,1);
        overlay_percent_b(i,1)=n_vox_overlay(i,1)*100/n_vox_b(i,1);
%         fprintf('\n--For the ROI %d :\n  the shape correlation coefficient is %d \n',i,FG_roundn(shape_r,2))
%         fprintf('  the number of overlayed voxels is %d, while the voxel number of the first and second ROI is %d & %d \n',n_vox_overlay,n_vox_a,n_vox_b)
%         fprintf('  the percentage of overlayed voxels on the first ROI is %d %%\n',FG_roundn(overlay_percent_a,2))
%         fprintf('  the percentage of overlayed voxels on the second ROI is %d %%\n',FG_roundn(overlay_percent_b,2))
        
        fprintf('\n--For ROI %d ( %s ):\n  the shape correlation coefficient is %s \n',i,deblank(all_name(i,:)),num2str(shape_r(i,1),'%2.2f'))
        fprintf('  the number of overlayed voxels is %d, while the voxel number of the first and second ROI is %d & %d \n',n_vox_overlay(i,1),n_vox_a,n_vox_b(i,1))
        fprintf('  the percentage of overlayed voxels on the first ROI is %s %%\n',num2str(overlay_percent_a(i,1),'%2.2f'))
        fprintf('  the percentage of overlayed voxels on the second ROI is %s %%\n',num2str(overlay_percent_b(i,1),'%2.2f'))        
        
        
    end
    
    
   


    all_name=FG_add_characters_at_the_end(all_name,'     ');
    variable_names = cell2mat({repmat(' ',[1,size(all_name,2)]),'shape_r',repmat(' ',[1,5]),'overlay_percent_firstROI',repmat(' ',[1,5]),'overlay_percent_SecondROI',repmat(' ',[1,5]),'n_vox_overlay',repmat(' ',[1,5]),'n_vox_firstROI',repmat(' ',[1,5]),'n_vox_SecondROI';});
    variable_values = cell2mat({all_name,num2str(shape_r,'%10.2f'),repmat(' ',[size(all_name,1),5]), num2str(overlay_percent_a,'%10.2f'),repmat(' ',[size(all_name,1),5]), num2str(overlay_percent_b,'%10.2f'),repmat(' ',[size(all_name,1),5]), num2str(n_vox_overlay),repmat(' ',[size(all_name,1),5]),num2str(n_vox_a),repmat(' ',[size(all_name,1),5]), num2str(n_vox_b) });
    
    write_name=FG_check_and_rename_existed_file(fullfile(pwd,'Overlay_similarity_report_ByGrocer.txt'));
    dlmwrite(write_name, '', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name, variable_names,'-append', 'delimiter', '', 'newline','pc');
    for i=1:size(all_name,1)
        dlmwrite(write_name, variable_values(i,:),'-append', 'delimiter', '', 'newline','pc');
    end

    fprintf('\n-----The table of the output locates:\n %s  -------\n\n\n\n',write_name)
    
    if nargout~=0
        varargout={shape_r,overlay_percent_a,overlay_percent_b,n_vox_overlay,n_vox_a,n_vox_b}   ;
    end
% fprintf('\n---done.......\n')
    
    
    