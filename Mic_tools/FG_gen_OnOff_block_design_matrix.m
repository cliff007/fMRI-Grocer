function FG_gen_OnOff_block_design_matrix(InorDe,loops,off_measurements,on_measurements)
%    Always "off" first as below
%                            |---------------|               |---------------|
%                            |               |               |               |
%             ---------------|               |---------------|               |---------------
%                     off     on (first-half)       off       on (second-half)
close all
clc
if nargin==0
    prompt = {'Is the off-block shown first(1: Yes; 0: No)?','Total trials of paired on-off blocks (e.g. fix-task1)','----------------------------------------Number of "off-volumes" in each trial','----------------------------------------Number of "on-volumes" in each trial','How many sub-blocks in "on-block"?'};
    dlg_title = 'Block design matrix...';
    num_lines = 1;
    def = {'1','10','5','10','2'};
    paras = inputdlg(prompt,dlg_title,num_lines,def);    
    InorDe=str2num(paras{1});
    loops=str2num(paras{2});
    off_measurements=str2num(paras{3});
    on_measurements=str2num(paras{4});
    subblocks=str2num(paras{5});
elseif nargin==2
    prompt = {'----------------------------------------Number of "off-volumes" in each trial','----------------------------------------Number of "on-volumes" in each trial','How many sub-blocks in "on-block"?'};
    dlg_title = 'Block volumes...';
    num_lines = 1;
    def = {'5','10','2'};
    paras = inputdlg(prompt,dlg_title,num_lines,def);    
    off_measurements=str2num(paras{1});
    on_measurements=str2num(paras{2});
    subblocks=str2num(paras{3});
end

%% initial variables
  all_onsets_Scans=[1:loops*(off_measurements+on_measurements)]-1;    
    
  if InorDe
      first_onoff_vec_plot=[ones(1,off_measurements), 2*ones(1,on_measurements)];      
  else
      first_onoff_vec_plot=[2*ones(1,on_measurements), ones(1,off_measurements)];
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
  
  
  
  
%% get the volume sequence of "on/off blocks"    
% an = a1+(n-1)d 
all_block_Vars=['on_onsets, off_onsets'];
% if InorDe    
   off_onsets=all_onsets_Scans(all_onoff_vec_plot==1);
   on_onsets=all_onsets_Scans(all_onoff_vec_plot==2);   
% else
%    off_onsets=all_onsets_Scans(all_onoff_vec_plot==2);
%    on_onsets=all_onsets_Scans(all_onoff_vec_plot==1);    
% end

all_on_starts=on_onsets(1:on_measurements:length(on_onsets));
if subblocks>1 
    if mod(length(all_on_starts),subblocks)==0   
       for i=1:subblocks           
           i_subblock_starts=all_on_starts(i:subblocks:length(all_on_starts));
           i_subblock_all=[];
           for j=1:length(i_subblock_starts)
               i_subblock_all=[i_subblock_all [i_subblock_starts(j):i_subblock_starts(j)+on_measurements-1]];
           end
           on_onset_subblock(i,:)=i_subblock_all;
           all_block_Vars=[all_block_Vars, 'on_onset_subblock_' num2str(i) ','];
       end
    else
       fprintf('the length of on-blocks can''t be divided in to %d subblocks',subblocks)
    end
end


%% get the onsets of the volume sequence of "on/off blocks"
      output_name='Block_design_onsets_Unit_Scan1.m';
%       output_name=FG_check_and_rename_existed_file('Block_design_onsets_Unit_Scan.m');
      dlmwrite(output_name, '% -- Block design onsets for each block, the Unit of the outputed onsets for SPM model specification is "Scans"---', 'delimiter', '','newline','pc');
      dlmwrite(output_name, 'clear','-append', 'delimiter', '','newline','pc');
      dlmwrite(output_name, ['onsets_of_onblock=[' num2str(on_onsets,'%10.0f') ']'';'], '-append','delimiter', '','newline','pc');
      dlmwrite(output_name, ['onsets_of_offblock=[' num2str(off_onsets,'%10.0f') ']'';'], '-append','delimiter', '','newline','pc');
      
      if subblocks>1 && mod(length(all_on_starts),subblocks)==0  
          for i=1:subblocks
              dlmwrite(output_name, ['on_onset_subblock_' num2str(i) '=[' num2str(on_onset_subblock(i,:),'%10.0f') ']'';'], '-append','delimiter', '','newline','pc');
          end  
      end

      dlmwrite(output_name, '           ', '-append','delimiter', '','newline','pc');
      dlmwrite(output_name, 'save Block_design_onsets_Unit_Scan.mat', '-append','delimiter', '','newline','pc');
%       eval(['save(''Block_design_onsets_Unit_Scan.mat'',' all_block_Vars(1:end-1) ');'])
      


fprintf('\n====Run "Block_design_onsets_Unit_Scan.m" in the current folder to create corresponding .mat file\n')






