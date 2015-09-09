function FG_read_and_save_OnsetTxt_into_Grocer_needed
txtfiles=spm_select(inf,'.txt|.m$','Select the *.txt or *.m files storing row-vector onsets', [],pwd,'.*');
root_dir=spm_select(1,'dir','Select an output folder for the created onset files', [],pwd);
for i=1:size(txtfiles,1)
    FG_onset=FG_read_txt_row_by_row(deblank(txtfiles(i,:)));
    FG_onset=eval(FG_onset);
    [pth,filename]=FG_separate_files_into_name_and_path(deblank(txtfiles(i,:)));
    filename=filename(1,1:end-4); % remove the original subfix
    save_onsets_output(FG_onset,root_dir,filename)
end

fprintf('\n----done---\n')

% subfunctions
function save_onsets_output(FG_onset,root_dir,filename)
   save(fullfile(root_dir, [filename '_FG_onset.mat']),'FG_onset')
   %% save as .m file
  output_name=fullfile(root_dir, [filename '_FG_onset.m']);
  dlmwrite(output_name, ['% -- The onset of ' root_dir filename ' ---'], 'delimiter', '','newline','pc');
  dlmwrite(output_name, ['FG_onset=[' num2str(FG_onset,'%10.2f') '];'], '-append','delimiter', '','newline','pc');
  dlmwrite(output_name, '           ', '-append','delimiter', '','newline','pc');
  
  dlmwrite(output_name, ['save ' filename,'_onsets.mat'], '-append','delimiter', '','newline','pc');
  