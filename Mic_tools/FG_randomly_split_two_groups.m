function FG_randomly_split_two_groups(all,file_or_folder,outdir)

if nargin==0
    file_or_folder=questdlg('File or Foloder do you want to deal with?','Hi....','File','hdr/img pair','Folder','File') ;
    if strcmp(file_or_folder,'File')
        all=spm_select(inf,'.*');
        if isempty(all),return;end
    elseif strcmp(file_or_folder,'Folder')
        all=spm_select(inf,'dir');
        if isempty(all),return;end
    elseif  strcmp(file_or_folder,'hdr/img pair')
        all=spm_select(inf,'.hdr');
        if isempty(all),return;end
    else
       return 
    end
    L=size(all,1);
    outdir=spm_select(1,'dir','Please select an output directory...');
else
    fprintf('\n---I only accept three inputs or non inputs...\n')
    return
end

    label_file=questdlg('Do you want to use a [Random_label_report.txt] that created by this function before to split groups?','Hi....','Yes','No','No') ;
    if strcmp(label_file,'No')
        a=equal_two(L);
    elseif strcmp(label_file,'Yes')
        label_f=spm_select(inf,'.txt','Please select the [Random_label_report.txt] file',[],pwd,'Random_label_report.*txt');
        a=load(label_f);
    end
g1=[];
g2=[];
labels=ones(L,1);
tar1=fullfile(outdir,'group1');
tar2=fullfile(outdir,'group2');
mkdir(tar1)
mkdir(tar2)

write_name=FG_check_and_rename_existed_file(fullfile(outdir,'Randomly_Split_report.txt'));
random_label_name=FG_check_and_rename_existed_file(fullfile(outdir,'Random_label_report.txt'));
random_labels=FG_check_and_rename_existed_file(fullfile(outdir,'Random_labels.txt'));
dlmwrite(random_label_name, a, 'delimiter', '', 'newline','pc'); 

for i=1:L
    if a(i)<mean(a)
        if strcmp(file_or_folder,'File') || strcmp(file_or_folder,'hdr/img pair')
            [c,d]=FG_separate_files_into_name_and_path (deblank(all(i,:)));
        elseif strcmp(file_or_folder,'Folder')
            [c,d]=FG_sep_group_and_path(deblank(all(i,:)));           
        end            
            
        %mkdir(fullfile(tar1,d))
        copyfile(deblank(all(i,:)),fullfile(tar1,d))        
        if  strcmp(file_or_folder,'hdr/img pair')
            copyfile(FG_corresponding_name_of_hdr_img_pair(deblank(all(i,:))),fullfile(tar1,FG_corresponding_name_of_hdr_img_pair(d)))             
        end
        g1=strvcat(g1,deblank(all(i,:)));        
    else
        if strcmp(file_or_folder,'File') || strcmp(file_or_folder,'hdr/img pair')
            [c,d]=FG_separate_files_into_name_and_path (deblank(all(i,:)));
        elseif strcmp(file_or_folder,'Folder')
            [c,d]=FG_sep_group_and_path(deblank(all(i,:)));
        end

        %mkdir(fullfile(tar2,d))
        copyfile(deblank(all(i,:)),fullfile(tar2,d))
        if  strcmp(file_or_folder,'hdr/img pair')
            copyfile(FG_corresponding_name_of_hdr_img_pair(deblank(all(i,:))),fullfile(tar2,FG_corresponding_name_of_hdr_img_pair(d)))              
        end
        g2=strvcat(g2,deblank(all(i,:)));
        labels(i,1)=2;
    end
end

dlmwrite(random_labels, labels, 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name,['-----------Group1: ' num2str(size(g1,1))], 'delimiter', '', 'newline','pc'); 
dlmwrite(write_name, g1, '-append', 'delimiter', '', 'newline','pc');
dlmwrite(write_name, ['-----------Group2: ' num2str(size(g2,1))], '-append',  'delimiter', '', 'newline','pc');
dlmwrite(write_name, g2, '-append', 'delimiter', '', 'newline','pc');

fprintf('\n---It is done! Check %s \n',write_name)

function a=equal_two(L)
a=int16(rand(L,1)*10);
L=size(a,1);
M=mean(a);
tem=a(a>=M);
if ~(size(tem,1) <= ceil(0.5*L) && size(tem,1) >= ceil(0.5*L)-1)
   a=equal_two(L);
end
