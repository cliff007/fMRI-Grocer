function FG_gen_MultiBlock_design_matrix(blocks_a_loop,loops,InorDe)
%    Always "off" first as below
%                            |---------------|               |---------------|
%                            |               |               |               |
%             ---------------|               |---------------|               |---------------
%                     off     on (first-half)       off       on (second-half)
close all
% if nargin==0
%     prompt = {'TR','How many blocks of each loop?','Total loops of paired all blocks..................................','Increased or Decreased blocks(1:increased; 0: decreased)?'};
%     dlg_title = 'Block design matrix...';
%     num_lines = 1;
%     def = {'2.56','2','10','1'};
%     paras = inputdlg(prompt,dlg_title,num_lines,def);    
%     TR=str2num(paras{1});
%     blocks_a_loop=str2num(paras{2});
%     loops=str2num(paras{3});
%     InorDe=str2num(paras{4});
% end

if nargin==0
    prompt = {'How many conditions of each trial (e.g. fix-task1)?','How many trials of a complete scan..................................','Show in an increased or decreased way(1:increased; 0: decreased)?'};
    dlg_title = 'Block design matrix...';
    num_lines = 1;
    def = {'2','10','1'};
    paras = inputdlg(prompt,dlg_title,num_lines,def);    
    blocks_a_loop=str2num(paras{1});
    loops=str2num(paras{2});
    InorDe=str2num(paras{3});
   
end

    if blocks_a_loop==2
       FG_gen_OnOff_block_design_matrix(InorDe,loops)
       return
    end

    measurements=FG_inputdlg_selfdefined(blocks_a_loop,'---------------------------------------- Number of volumes of block ','Volumes of each block...','10');
    measurements=FG_convert_cellnum_2_num(measurements);    

    % The Onset times for SPM start at time 0 (the beginning of the first non-dummy scan is time 0, or tr 0).
        all_onsets_Scans=[1:sum(measurements)*loops]-1;    
    %     all_onsets_Second=all_onsets_Scans*TR;
        first_onoff_vec_plot=[];


      for i=1:blocks_a_loop
          if InorDe==1
              first_onoff_vec_plot=[first_onoff_vec_plot, ones(1,measurements(i))*i];  
          else
              first_onoff_vec_plot=[first_onoff_vec_plot, ones(1,measurements(i))*(blocks_a_loop-i+1)];  
          end
      end

      %% plot the block design matrix
      all_onoff_vec_plot=repmat(first_onoff_vec_plot,1,loops);  
      figure
      plot(1:size(all_onoff_vec_plot,2),all_onoff_vec_plot,'-rs','LineWidth',1.5, ...
                                                            'MarkerEdgeColor','b',...
                                                            'MarkerFaceColor','g',...
                                                            'MarkerSize',6)
      set(gca,'YTick',[1:3])
      set(gca,'YTickLabel',{1 2 3})
      set(gca,'XTick',[all_onsets_Scans(mod(all_onsets_Scans,5)==0)])
      set(gca,'XTickLabel',{all_onsets_Scans(mod(all_onsets_Scans,5)==0)})




    %% get the onsets of the volume sequence of "on/off blocks"
    % The Onset times for SPM start at time 0 (the beginning of the first
    % non-dummy scan is time 0, or tr 0).
      all_block_Vars=[];
      output_name=FG_check_and_rename_existed_file('Block_design_onsets_Unit_Scan.m');
      dlmwrite(output_name, '% -- Block design onsets for each block, the Unit of the outputed onsets for SPM model specification is "Scans"---', 'delimiter', '','newline','pc');
      dlmwrite(output_name, 'clear','-append', 'delimiter', '','newline','pc');

      for i=1:blocks_a_loop
%           if InorDe==1
             eval(['onsets_of_block_' num2str(i) '=all_onsets_Scans(all_onoff_vec_plot==' num2str(i) ');']);   
%           else
%              eval(['onsets_of_block_' num2str(i) '=all_onsets_Scans(all_onoff_vec_plot==' num2str(blocks_a_loop-i+1) ');']);  
%           end
          all_block_Vars=[all_block_Vars '''' 'onsets_of_block_' num2str(i)  ''','];
          dlmwrite(output_name, ['onsets_of_block_' num2str(i)  '=[' num2str(eval(['onsets_of_block_' num2str(i)]),'%10.0f') ']'';'], '-append','delimiter', '','newline','pc');
      end  

      dlmwrite(output_name, '           ', '-append','delimiter', '','newline','pc');
      dlmwrite(output_name, 'save Block_design_onsets_Unit_Scan.mat', '-append','delimiter', '','newline','pc');
%       eval(['save(''Block_design_onsets_Unit_Scan.mat'',' all_block_Vars(1:end-1) ');'])
      


fprintf('\n====Run "Block_design_onsets_Unit_Scan.m" in the current folder to create corresponding .mat file\n')



  
  
  
  
  
  
