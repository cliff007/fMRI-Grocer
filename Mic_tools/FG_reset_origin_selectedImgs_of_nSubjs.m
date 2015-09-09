function FG_reset_origin_selectedImgs_of_nSubjs(subjs,file_filter)
if nargin==0
	subjs = spm_select(inf,'dir', 'Select subject folders for reseting origins...',[],pwd,'.*'); 
    
	prompt = {'Specify a file filter:'};
    num_lines = 1;
    def = {'^sr.*img||^sr.*nii'};
    dlg_title='filter...';
    file_filter = inputdlg(prompt,dlg_title,num_lines,def); 
    if FG_check_ifempty_return(file_filter) , file_filter='return'; return; end
    file_filter=file_filter{1};
end

for i=1:size(subjs,1)
    imgs = spm_select('FPlist',deblank(subjs(i,:)),file_filter); 
    FG_reset_origin_selectedImgs(imgs);
end

fprintf('---All done...\n')