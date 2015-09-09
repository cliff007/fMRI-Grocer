function FG_copy_out_delete_in_for_DTI_PANDA
        h_op=questdlg('What do you want to do?','Hi....','Copy out...','Move out...','Copy out...') ;
        if isempty(h_op), return; end
        root_dir = FG_module_select_root('Select the root folder of the PANDA-based DTI output');
        
        
        out_dir = FG_module_select_root('Select a folders to hold the outputs','N');  
        if FG_check_ifempty_return(out_dir), return; end

        
%         prompt = {'How many file filters do you want to specify:'};
%         num_lines = 1;
%         def = {'1'};
%         dlg_title='filter num....';
%         file_filter_n = inputdlg(prompt,dlg_title,num_lines,def);
%         file_filter_n =str2num(file_filter_n{1});
%      % enter the file filters   
%         dlg_prompt={};
%         dlg_prompt1={};
%         dlg_prompt2={};  
%         dlg_title='filter...';
%         for i=1:file_filter_n
%             dlg_prompt1=[dlg_prompt1,['file filter',num2str(i),'----------------------------------']];
%             dlg_prompt2=[dlg_prompt2,'CBF*.*'];
%         end  
%         file_filters =inputdlg(dlg_prompt1,dlg_title,num_lines,dlg_prompt2);

%           file_filters ={'*LDHs_4normalize_to_target_2mm_s6mm*.*','*FA_4normalize_to_target_2mm_s6mm*.*','*MD_4normalize_to_target_2mm_s6mm*.*'};       
          file_filters ={'*FA_4normalize_to_target_2mm_s6mm*.*','*MD_4normalize_to_target_2mm_s6mm*.*', ...                % voxel-wised
                         '*FA_4normalize_to_target_1mm*.*WMlabel','*FA_4normalize_to_target_1mm*.*WMtract','*MD_4normalize_to_target_1mm*.*WMlabel','*MD_4normalize_to_target_1mm*.*WMtract'};%, ...            % atlas-wised
                         %'*FA_4normalize_to_target_1mm_skeletonised*.*','*MD_4normalize_to_target_1mm_skeletonised*.*'};   %  TBSS-wised
%           file_filters1=FG_convert_cellVector_2_strVector_basedon_row(file_filters);
          file_filters1=file_filters;
          tem=regexprep(file_filters1,regexptranslate('escape','*.*WM'),regexptranslate('escape','_WM'));
          tem=regexprep(tem,regexptranslate('escape','*.*'),regexptranslate('escape',''));
          folder_names=regexprep(tem,regexptranslate('escape','*'),regexptranslate('escape',''));

          
          for i=1:size(file_filters,2) 
%               if i==1 || i==2
%                   tem=file_filters{i};
%                   tem=regexprep(tem,regexptranslate('escape','*.*WM'),regexptranslate('escape','_WM'));
%                   FG_convert
%                   tem_out=fullfile(out_dir,file_filters{i}(2:end-3));
%               elseif i==3 || i==4
%                   tem=file_filters{i}(2:end-3);
%                   tem(1 end-9:end-7)=[];
%                   tem_out=fullfile(out_dir,);
%               end
              tem_out=fullfile(out_dir,folder_names{i});
              mkdir(tem_out)
              FG_copy_out_delete_in_without_foderStructure(h_op,root_dir,file_filters(i),tem_out)
          end
          
          ;