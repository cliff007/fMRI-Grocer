% gift matlab commands
function FG_ICA_artifact_control_scripts2(root_first,Dirs)
clear
if nargin==0
    groups=spm_select(inf,'dir','Select the groups');
    for i_group=1:size(groups,1)
        dirs_tem{i_group}=spm_select(inf,'dir',['Select the subject folders of ' num2str(i_group) 'group'],[],deblank(groups(i_group,:)));
    end
end

for i_group=1:size(groups,1)
    if nargin==0
        root_first=deblank(groups(i_group,:));
    end
        % root_first=spm_select(1,'dir','Select the root folder of all subjects');

        if isempty(root_first),return,end
        cd (root_first)
        write_name=fullfile(root_first,'quality_control_report.txt');
        write_name2=fullfile(root_first,'quality_control_report_largest_r.txt');
        dlmwrite(write_name,['----------ICA artifact-detection reports------------------'], 'delimiter', '', 'newline','pc'); 
        t=which('artifact_label');
        [path,name,ext,ent]=FG_fileparts(t);

        wholeV_mask=fullfile(path,'whole_volume_mask.nii');
        % art_mask=fullfile(path,'fat_artifact_template.nii');
        % cliff attention
        % art_mask=fullfile(path,'fat_artifact_template_1_5.nii');
        art_mask=fullfile(path,'fat_artifact_template_1_inf.nii');
        para_template=fullfile(path,'fatTemplate_ica_parameter_info.mat');
        clear ent ext name path t   % tem_dir
        load(para_template);

        if nargin==0
            Dirs=dirs_tem{i_group};
        end
            % Dirs=spm_select(inf,'dir','Select the subject dirs under the root folder');
            if isempty(Dirs),return,end            
            for i_dir=1:size(Dirs,1)
                %%% settings
                    Dir=deblank(Dirs(i_dir,:));
                    imgs=spm_select('FPList',Dir,'.*img|.*nii');             
                    
                    
                  %% cliff: create brain mask based on the original images                    
                    brain_bg_skull=FG_image_quality_evaluation_ASL_ICA_based(imgs);    %%
                    
                    
                    
                    sesInfo.userInput.files.name=imgs;

                    target_dir=[Dir(1,1:end-1) '_ICA_Output'];  
                    [head,last]=FG_sep_group_and_path(Dir);
                    head=[head(1:end-1) '_corrected'];
                    last=[last '_corrected'];
                    corrected_dir=fullfile(head,last);
                    mkdir(corrected_dir)
                    
                    sesInfo.userInput.pwd=target_dir;
                    mkdir (sesInfo.userInput.pwd)
                    sesInfo.userInput.prefix= 'Fat_artifact';
                    sesInfo.userInput.param_file=fullfile(sesInfo.userInput.pwd,[sesInfo.userInput.prefix '_ica_parameter_info.mat']);
                    sesInfo.userInput.diffTimePoints= size(imgs,1);
                    sesInfo.userInput.numComp= 20;
                    sesInfo.userInput.maskFile= wholeV_mask;
                    sesInfo.userInput.scaleType= 2;

                    [V,Mat]=FG_read_vols(wholeV_mask);
                    sesInfo.userInput.mask_ind= [1:numel(V)]';
                    clear Mat V imgs
                    eval(['save ' sesInfo.userInput.param_file ' sesInfo'])
                    param_file=sesInfo.userInput.param_file;

                %%% run analysis
                    groupICAStep='all';
                    FG_icatb_runAnalysis(sesInfo, groupICAStep) ;

                %%% sort the ICs
                    % load template
                    template =  icatb_loadData(art_mask); 
                    template =template(:);
                    % unzip IC.zip
                    zip_ICs=spm_select('FPList',target_dir,'.*zip');
                    ICs=unzip(zip_ICs,target_dir);
                    ICs=char(ICs');
                    % remove timecourse.img/hdr
                    Outlier=[];
                    for i=1:size(ICs,1)
                       a=regexp(ICs(i,:),'timecourses', 'once');
                       if ~isempty(a)
                         Outlier=[Outlier,i];
                       end
                    end

                    for j=1:size(Outlier,2)
                        delete(deblank(ICs(Outlier(j),:)))
                    end

                    ICs(Outlier,:)=[];
                    ICs(1:2:end,:)=[];

                    % do spatial-match correlation
                    pure_ICs=ICs;
                    pure_ICs=FG_remove_paths(pure_ICs);

                    all_r=[];
                    for i=1:size(ICs,1)
                        data = icatb_loadData(deblank(ICs(i,:)));
                        data(isnan(data))=0;
                        data(data<1)=0;
                        % cliff attention
                        % data(data>5)=0;  % this depend on the choice of the fat-template
                        data(data>=1)=1;
                        data=data(:);
                        % template(data ~= 1)=0;
                        r = icatb_corr(template(:),data);
                        all_r=[all_r;r];
                        % all_r_square=all_r.*all_r;
                    end


                    % write txt file
                     dlmwrite(write_name,['---report for:' Dir], '-append',  'delimiter', '', 'newline','pc'); 
                     dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                     dlmwrite(write_name2,['--- r report for:' Dir], '-append',  'delimiter', '', 'newline','pc'); 
                     dlmwrite(write_name2,'         ', '-append',  'delimiter', '', 'newline','pc');

                    % find the most match component
        %             Idx = find(all_r==max(all_r));
        %             display(['the most matched component is : ' pure_ICs(Idx(1),:)])
        %             dlmwrite(write_name,['the most matched component is : ' pure_ICs(Idx(1),:), ' r=' num2str(max(all_r))], '-append',  'delimiter', '', 'newline','pc');
        %             dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');

                    % the sorted order of ICs
                    [sorted,Idx]=sort(all_r,'descend')  ;          
                    pure_ICs(Idx,:);
                    dlmwrite(write_name,'the first 5 sorted components are : ', '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,['      ', pure_ICs(Idx(1),:) '  r=' num2str(sorted(1))], '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,['      ', pure_ICs(Idx(2),:) '  r=' num2str(sorted(2))], '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,['      ', pure_ICs(Idx(3),:) '  r=' num2str(sorted(3))], '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,['      ', pure_ICs(Idx(4),:) '  r=' num2str(sorted(4))], '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,['      ', pure_ICs(Idx(5),:) '  r=' num2str(sorted(5))], '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                    dlmwrite(write_name2,num2str(sorted(1)), '-append',  'delimiter', '', 'newline','pc');
                    
                    % according to our experience, 
                    % if the largest spatial-correlation coefficient bigger than 0.2, 
                    % then try to do the correction:  remove artifact IC in ICA
                    if sorted(1)>0.2
                        tem=pure_ICs(Idx(1),:);
                        comp_num=tem(end-6:end-4);
                        icatb_removeArtifact(param_file, corrected_dir, 1, 1, str2num(comp_num));
                        % move corrected files up two level and delete the redundant folders
                        movefile(fullfile(corrected_dir,'Sub_001','1','*.*'), corrected_dir);
                        FG_DelDir(fullfile(corrected_dir,'Sub_001'))
                    end
                    
                    % separate out the potential artifact-ROI
                    [Vs,Vmats]=FG_read_vols(strvcat(ICs(Idx(1),:),deblank(brain_bg_skull(2,:))));
                    ic=Vs(:,:,:,1);
                    bg=Vs(:,:,:,2);
                    ic(ic>5)=0; ic(ic<1)=0;ic(1<ic<=5)=1;
                    bg(bg~=0)=0;
                    roi=bg.*ic;
                    FG_write_vol(Vmats(1),roi,fullfile(target_dir, 'artifactROI.nii'))
                    
                    FG_enhanced_spm_check_registration( strvcat( ...
                                                                ICs(Idx(1),:), ...
                                                                ICs(Idx(2),:), ...
                                                                deblank(brain_bg_skull(1,:)), ...
                                                                fullfile(target_dir, 'artifactROI.nii'), ...
                                                                deblank(brain_bg_skull(2,:)), ...
                                                                art_mask ...
                                                                ) ...
                                                            );
        %             spm_orthviews('Window',1,spm_input('Range','+1','e','',2))
        %             spm_orthviews('Window',1,[1;5]);
        %             spm_orthviews('Window',[1 2 3]); % only specify subplot number, means 'auto'
                    spm_orthviews('Window',[1 2],[1;5]);  % [1 2 3] is the subplot number, [1;5] is the intensity range % cliff attention
                    spm_orthviews('reposition',[-52 -33 -41])  % [-52 -33 -41] is the mm-cordinate
                    spm_orthviews('Interp',0);
        %             FG_scale_orthviews(1, 5)


                    [g,d]=FG_sep_group_and_path(Dir);
                    saveas(gcf,fullfile(root_first,[d '_first2ICs_AND_ArtifactTemplate.bmp']));
                    close (gcf); 
                    pause(0.01)  % release the memory to close the figure
        %             delete([sesInfo.userInput.prefix '*component_ica*.*'])
        %             delete([sesInfo.userInput.prefix '*timecourses_ica*.*'])

                    % delete all the other unzipped component images
                    del_names=FG_remove_extentions(ICs);
                    del_names=FG_add_characters_at_the_end(del_names,'*.*');
                    for i_del=6:20
                        delete(deblank(del_names(Idx(i_del),:)))
                    end
                    

            end
end

fprintf('\n-------All done!-------\n')




