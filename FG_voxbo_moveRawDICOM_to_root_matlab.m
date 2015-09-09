function FG_voxbo_moveRawDICOM_to_root_matlab
clc
hi = questdlg('Please backup your original DICOM images before you continue to use this function!','Please backup your data first...','Continue','Cancel','Cancel');
if strcmpi(hi,'Cancel')
    fprintf('\n----Quit to backup data first...............................\n')
    return
end
%%
h=questdlg('**. It is going to move all raw DICOM-images to the root folder of each subject, are you sure to continue?','Move files....','Yes','Skip','Skip') ;

%%%%%%%% obsolete

            % switch h
            %     case 'Yes'
            % 
            %         anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
            %         if anyreturn, return;end
            %         
            %         for i=1:size(groups,1) 
            % %             [all_files,all_cell_files]=FG_list_all_files(deblank(groups(i,:)),'**','*');            
            %             tem=dir(fullfile(root_dir,deblank(groups(i,:))));            
            %             for k=3:size(tem,1)
            %                if tem(k).isdir==1      
            %                     try
            %                         movefile(fullfile(root_dir,deblank(groups(i,:)),tem(k).name,'*'),fullfile(root_dir,deblank(groups(i,:))))
            %                     catch me
            %                         me.message
            %                         continue
            %                     end
            %                end
            %             end
            %             
            %             try
            %                 delete(fullfile(root_dir,deblank(groups(i,:)),'DICOMDIR'))
            %             catch me
            %                 me.message
            %             end
            %             
            %             tem=dir(fullfile(root_dir,deblank(groups(i,:))));            
            %             for k=3:size(tem,1)
            %                if tem(k).isdir==1
            %                    try
            %                        FG_DelDir(fullfile(root_dir,deblank(groups(i,:)),deblank(tem(k).name)))
            %                    catch me
            %                        me.message
            %                        continue
            %                    end
            %                end
            %             end                 
            %         end
            % 
            %         fprintf('-------Files-moving is done............\n\n')
            %         
            %     case 'Skip'
            %         fprintf('------Skip the moving files..............\n\n')
            % end



switch h
    case 'Yes'
        fprintf('\n----Running...............................\n')
        anyreturn=FG_modules_selection('Select the root folder containing all the subject folders','Please select all subjects...','','^','r','g');
        if anyreturn, return;end
        
        for i=1:size(groups,1) 
%             [all_files,all_cell_files]=FG_list_all_files(deblank(groups(i,:)),'**','*');            

            all_folders=FG_genpath(fullfile(root_dir,deblank(groups(i,:))));
            
            for k=size(all_folders,1):-1:2   
                try
                    movefile(fullfile(deblank(all_folders(k,:)),'*.*'),deblank(all_folders(1,:)))
                catch me
                    me.message
                    continue
                end
            end

            all_folders=FG_genpath(fullfile(root_dir,deblank(groups(i,:)))); % regenerate all subfolders
            for k=size(all_folders,1):-1:2  
               try
                   FG_DelDir(deblank(all_folders(k,:)))
               catch me
                   me.message
                   continue
               end
            end                 
        end

        fprintf('-------Files-moving is done............\n\n')
        
    case 'Skip'
        fprintf('------Skip the moving files..............\n\n')
end
        
 