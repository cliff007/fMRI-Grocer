function FG_VBM8_batch_gen

try
    tpm_file=[FG_rootDir('spm') filesep 'toolbox' filesep 'Seg' filesep 'TPM.nii'];
catch me
    me.message
    fprintf('\n-----Please check SPM installation---\n')
    FG_rootDir('spm')
    return
end

try
    darteltpm_file=[FG_rootDir('spm_vbm8') filesep 'Template_1_IXI550_MNI152.nii'];   
catch me
    me.message
    fprintf('\n-----Please check VBM8 installation---\n')
    FG_rootDir('spm_vbm8')
    return
end

t1_imgs =  spm_select(inf,'any','Select all the T1 imgs', [],pwd,'.*img$|.*nii$');
if FG_check_ifempty_return(t1_imgs), return; end
 
write_name=FG_check_and_rename_existed_file('VBM8_batch_job.m')   ;


Parasmat = questdlg('Do you have a [VBM8_bathc_paras.mat] file to load? If you don''t, you can create it by using the sub-function in Grocer and come back here again! Otherwise, you will be guided to setup parameters step by step','Load VBM8 parameters...','Yes','No','Come back again','Yes') ;
if strcmp(Parasmat,'Yes')
    Parasmat =  spm_select(1,'.mat','Select all the T1 imgs', [],pwd);
    load(Parasmat)
elseif strcmp(Parasmat,'No')
                %% Setup the important Estimation options
                Affine_regulation = questdlg('What kind of brain model are you going to choose?','Affine regulation...','European Brains','East Asian Brains','Average sized template','European Brains') ;
                    if strcmp(Affine_regulation,'European Brains')
                        Affine_regulation='mni';
                    elseif strcmp(Affine_regulation,'East Asian Brains')
                        Affine_regulation='eastern';
                    elseif strcmp(Affine_regulation,'Average sized template')
                        Affine_regulation='subj';
                    else
                        return
                    end

                %%%%%%%%%%%% Setup the important Writing options 
                    %%%%% native space output
                    native_space = questdlg('Do you want to create images in native space?',' Nataive space...','No','Yes','No') ;
                    if strcmp(native_space,'No')
                        native_gray='0';
                        native_white='0';
                        native_csf='0';
                    elseif strcmp(native_space,'Yes')
                        native_space_img = questdlg('What do you want to create in in native space?','Native space...','Gray matter only','Gray + White matter','Gray + White + CSF','Gray + White matter') ;
                        if strcmp(native_space_img,'Gray matter only')
                            native_gray='1';
                            native_white='0';
                            native_csf='0';
                        elseif strcmp(native_space_img,'Gray + White matter')
                            native_gray='1';
                            native_white='1';
                            native_csf='0';
                        elseif strcmp(native_space_img,'Gray + White + CSF')
                            native_gray='1';
                            native_white='1';
                            native_csf='1';
                        else
                            return
                        end
                    end

                    %%%%% normalized space output
                    normalized_space = questdlg('Do you want to create images in normalized space?',' Normalized space...','No','Yes','No') ;
                    if strcmp(normalized_space,'No')
                        normalized_gray='0';
                        normalized_white='0';
                        normalized_csf='0';
                    elseif strcmp(normalized_space,'Yes')
                        normalized_space_img = questdlg('What do you want to create in in normalized space?',' Normalized space...','Gray matter only','Gray + White matter','Gray + White + CSF','Gray + White matter') ;
                        if strcmp(normalized_space_img,'Gray matter only')
                            normalized_gray='1';
                            normalized_white='0';
                            normalized_csf='0';
                        elseif strcmp(normalized_space_img,'Gray + White matter')
                            normalized_gray='1';
                            normalized_white='1';
                            normalized_csf='0';
                        elseif strcmp(normalized_space_img,'Gray + White + CSF')
                            normalized_gray='1';
                            normalized_white='1';
                            normalized_csf='1';
                        else
                            return
                        end
                    end

                    %%%%% Modulated normalized space output
                  Modulated_Normalized = questdlg('Do you want to modulated normalize brain segments?',' Modulated Normalized...','No','Yes','No') ;
                    if strcmp(Modulated_Normalized,'No')
                        Modulated_Normalized_gray='0';
                        Modulated_Normalized_white='0';
                        Modulated_Normalized_csf='0';
                    elseif strcmp(Modulated_Normalized,'Yes')
                        Modulated_Normalized_format = questdlg('What kind of modulated normalized method do you want to use?',' Modulated Normalized...','Affine + non-linear(SPM8 default)','Non-linear only','Non-linear only') ;
                            if strcmp(Modulated_Normalized_format,'Affine + non-linear(SPM8 default)')
                                Modulated_Normalized_format='1';
                            elseif strcmp(Modulated_Normalized_format,'Non-linear only')
                                Modulated_Normalized_format='2';
                            else
                                return
                            end      

                        Modulated_Normalized_img = questdlg('What brain segments do you want to modulated normalized?',' Dartel Export...','Gray matter only','Gray + White matter','Gray + White + CSF','Gray + White matter') ;
                            if strcmp(Modulated_Normalized_img,'Gray matter only')
                                Modulated_Normalized_gray=Modulated_Normalized_format;
                                Modulated_Normalized_white='0';
                                Modulated_Normalized_csf='0';
                            elseif strcmp(Modulated_Normalized_img,'Gray + White matter')
                                Modulated_Normalized_gray=Modulated_Normalized_format;
                                Modulated_Normalized_white=Modulated_Normalized_format;
                                Modulated_Normalized_csf='0';
                            elseif strcmp(Modulated_Normalized_img,'Gray + White + CSF')
                                Modulated_Normalized_gray=Modulated_Normalized_format;
                                Modulated_Normalized_white=Modulated_Normalized_format;
                                Modulated_Normalized_csf=Modulated_Normalized_format;
                            else
                                return
                            end
                    else
                        return
                    end

                    %%%%% Dartel Export output  
                 DartelExport = questdlg('Do you want to export data into a form that can be used with DARTEL?',' Dartel Export...','No','Yes','No') ;
                    if strcmp(DartelExport,'No')
                        DartelExport_gray='0';
                        DartelExport_white='0';
                        DartelExport_csf='0';
                    elseif strcmp(DartelExport,'Yes')
                        DartelExport_format = questdlg('What kind of DARTEL format do you want to export?',' Dartel Export...','Rigid(SPM8 default)','Affine','Rigid(SPM8 default)') ;
                            if strcmp(DartelExport_format,'Rigid(SPM8 default)')
                                DartelExport_format='1';
                            elseif strcmp(DartelExport_format,'Affine')
                                DartelExport_format='2';
                            else
                                return
                            end      

                        DartelExport_img = questdlg('What do you want to export into Dartel fromat?',' Dartel Export...','Gray matter only','Gray + White matter','Gray + White + CSF','Gray + White matter') ;
                            if strcmp(DartelExport_img,'Gray matter only')
                                DartelExport_gray=DartelExport_format;
                                DartelExport_white='0';
                                DartelExport_csf='0';
                            elseif strcmp(DartelExport_img,'Gray + White matter')
                                DartelExport_gray=DartelExport_format;
                                DartelExport_white=DartelExport_format;
                                DartelExport_csf='0';
                            elseif strcmp(DartelExport_img,'Gray + White + CSF')
                                DartelExport_gray=DartelExport_format;
                                DartelExport_white=DartelExport_format;
                                DartelExport_csf=DartelExport_format;
                            else
                                return
                            end
                    else
                        return
                    end   


                        %%%%% PVE label native and normalized output  
                 PVELabel_native_space = questdlg('Do you want to create PVE label images in native space?',' PVE-Label nataive space...','No','Yes','No') ;
                    if strcmp(PVELabel_native_space,'No')
                        PVELabel_native_space_val='0';
                    elseif strcmp(PVELabel_native_space,'Yes')
                        PVELabel_native_space_val='1';   
                    else
                        return
                    end   


                 PVELabel_normalized_space = questdlg('Do you want to create PVE label images in normalized space?',' PVE-Label normalized space...','No','Yes','No') ;
                    if strcmp(PVELabel_normalized_space,'No')
                        PVELabel_normalized_space_val='0';
                    elseif strcmp(PVELabel_normalized_spacee,'Yes')
                        PVELabel_normalized_space_val='1';   
                    else
                        return
                    end       

                         %%%%% PVE label Dartel export output     
                 PVELabel_DartelExport = questdlg('Do you want to export PVE label data into a form that can be used with DARTEL?','  PVE-Label Dartel Export...','No','Yes','No') ;
                    if strcmp(PVELabel_DartelExport,'No')
                        PVELabel_DartelExport_format='0';
                    elseif strcmp(PVELabel_DartelExport,'Yes')
                        PVELabel_DartelExport_format = questdlg('What kind of DARTEL format do you want to export?',' Dartel Export...','Rigid(SPM8 default)','Affine','Rigid(SPM8 default)') ;
                            if strcmp(PVELabel_DartelExport_format,'Rigid(SPM8 default)')
                                PVELabel_DartelExport_format='1';
                            elseif strcmp(PVELabel_DartelExport_format,'Affine')
                                PVELabel_DartelExport_format='2';
                            else
                                return
                            end      
                    else
                        return
                    end    



                          %%%%% Jacobian image output    
                  Jacobian_img = questdlg('Do you want to create Jacobian image?','Jacobian image...','Yes','No','No') ;
                    if strcmp(Jacobian_img,'No')
                        Jacobian_val='0';
                    elseif strcmp(Jacobian_img,'Yes')
                        Jacobian_val='1';
                    else
                        return
                    end  
else
    fprintf('\n-----It seeems you want to create [VBM8_bathc_paras.mat] file and come back again ----')
    return
end  
    
    
    % build the batch header
    dlmwrite(write_name,'%-----------------------------------------------------------------------', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name, '% Job configuration created by fMRI-Grocer-2014(Senhua Zhu)', '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,'%-----------------------------------------------------------------------', '-append', 'delimiter', '', 'newline','pc'); 

    dlmwrite(write_name,'matlabbatch{1}.spm.tools.vbm8.estwrite.data = {', '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('''',t1_imgs, ',1'''), '-append', 'delimiter', '', 'newline','pc');             
    dlmwrite(write_name,'};', '-append', 'delimiter', '', 'newline','pc');


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.tpm = {''', tpm_file, '''};'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.ngaus = [2 2 2 3 4 2];'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = 0.0001;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm = 60;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg = ''',Affine_regulation,''';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.warpreg = 4;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp = 3;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp.normhigh.darteltpm = {''', darteltpm_file ,'''};'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf = 0.15;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print = 1;'), '-append', 'delimiter', '', 'newline','pc'); 

    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native = ',native_gray,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped = ',normalized_gray,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.modulated = ',Modulated_Normalized_gray,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.dartel = ',DartelExport_gray,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native = ',native_white,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped = ',normalized_white,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.modulated = ',Modulated_Normalized_white,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.dartel = ',DartelExport_white,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native = ',native_csf,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped = ',normalized_csf,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.modulated = ',Modulated_Normalized_csf,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.dartel = ',DartelExport_csf,';'), '-append', 'delimiter', '', 'newline','pc'); 


    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped = 1;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.affine = 0;'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = ',PVELabel_native_space_val,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped = ',PVELabel_normalized_space_val,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.dartel = ',PVELabel_DartelExport_format,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.jacobian.warped =',Jacobian_val,';'), '-append', 'delimiter', '', 'newline','pc'); 
    dlmwrite(write_name,strcat('matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps = [0 0];'), '-append', 'delimiter', '', 'newline','pc'); 

    fprintf('\n-----Check the created job file(.m): %s \n-----Then run the job file in either SPM8 or Grocer!\n',write_name)
  