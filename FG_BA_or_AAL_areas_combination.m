function FG_BA_or_AAL_areas_combination
%%%% based on DPARSFA_run.m

a=which('fmri_grocer.m');
[DPARSF_path,b,c,d]=fileparts(a);
   ProgramPath = DPARSF_path;

  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       Template_I = spm_select(1,'.*','Select the AAL/Brodmann template or some other multiple labeling masks', [],[DPARSF_path filesep 'Templates']);
  end
  
         if isempty(Template_I)
             return
         end
         
         [a,b,c,d]=fileparts(Template_I);
 
    dlg_prompt={'Enter the region labels you want to combine within [](Do not enter any ''0'' before a non-zeor num., such as ''09'')'};
    dlg_name='Region labels to be combined';
    dlg_def={'[1 2 3 30]'};
    Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def);   
    
    regs=eval(Ans{1});
    
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       root_dir = spm_select(1,'dir','Select a folder you want to save your result', [],pwd);
  end 
  if isempty(root_dir),return; end
%   cd (root_dir)
 
V=spm_vol(Template_I);
Vmat=spm_read_vols(V);

Vmat_1=ismember(Vmat,regs);
V.fname=fullfile(root_dir,[b '_areas_' Ans{1},'_combination.nii']);
tem=spm_write_vol(V,Vmat_1);
 


if exist(tem.fname,'file')
   fprintf('\n\n====\n %s has been created...\n\n',tem.fname);
    h=questdlg('Do you want to transfer the combined .nii files into hdr/img pairs?','Next step...','Yes','No','No');
    if strcmp(h,'Yes')
        a=spm_vol(tem.fname);
        b=spm_read_vols(a);
        [pathes, names,new_names,new_full_names]=FG_separate_files_into_name_and_path(tem.fname,'','prefix','.img');
        a.fname=new_full_names;
        spm_write_vol(a,b);
        fprintf('\n\n====\n %s has been created...\n\n',new_full_names);
    end
else
    fprintf('\n\n==\nCombination of the selected areas %s of %s has not been created! \nCheck out what is wrong with your template or your input ared number...\n\n',Ans{1},b);
    return;
end


