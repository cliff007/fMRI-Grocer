% gift matlab commands
function FG_ICA_easy_mode
    clear
    groups=spm_select(inf,'dir','Select the groups...');
    if isempty(groups),return,end
    for i_group=1:size(groups,1)
        [pth,g_name]=FG_sep_group_and_path(deblank(groups(i_group,:)));
        dirs_tem{i_group}=spm_select(inf,'dir',['Select the subject folders of - ' g_name ' -group'],[],deblank(groups(i_group,:)));  
        if isempty(dirs_tem{i_group}),return,end
        IC_n{i_group}=inputdlg({['IC number extracting for - ' g_name ' -group...'];'Prefixion for the ICs of this group'},'IC number and prefixion...',1,{'20';'group'});        
    end    
    
    clear pth g_name
    
    tem=FG_rootDir('FG_icatb_runAnalysis');
    wholeV_mask=spm_select(1,'image','Please select a whole brain mask...',[],fullfile(FG_rootDir('grocer'),'Templates'),'.*');
    wholeV_mask=FG_remove_potential_dot1_of_image_names(wholeV_mask);
    if isempty(wholeV_mask),return,end
%         wholeV_mask=fullfile(path,'whole_volume_mask.nii');

    ROI_mask=spm_select(inf,'image','Please select a ROI template(s) for spatial sorting...',[],tem,'.*');
    ROI_mask=FG_remove_potential_dot1_of_image_names(ROI_mask);
    if isempty(ROI_mask),return,end
%         ROI_mask=fullfile(path,'fat_artifact_template_1_inf.nii');

    
    para_template=spm_select(1,'.mat','Please select a ica_parameter_info template...',[],tem,'.*ica_parameter_info.mat');
    if isempty(para_template),return,end
%         para_template=fullfile(path,'fatTemplate_ica_parameter_info.mat');

    % load(para_template);


    
    for i_group=1:size(groups,1)
        clear sesInfo;
        load(para_template);
        
        root_first=deblank(groups(i_group,:));
        Dirs=dirs_tem{i_group};
        
        if isempty(root_first),return,end
        if isempty(Dirs),return,end    
        
        %     sesInfo.userInput.numComp= 20;
        sesInfo.userInput.numComp = eval(IC_n{i_group}{1});
        sesInfo.userInput.ICA_Options{20} = eval(IC_n{i_group}{1});  % {20} is specially design for Infomax algorithm
        
        numRedSteps = sesInfo.userInput.numReductionSteps;
        PCBefore = sesInfo.userInput.numComp;    
        [minTp, minTpInd] = min(sesInfo.userInput.diffTimePoints);
        PCBefore = round(min([minTp, 1.5*PCBefore]));
        % Autofill components
        if numRedSteps == 1
            sesInfo.userInput.numOfPC1 = sesInfo.userInput.numComp;
            sesInfo.userInput.numOfPC2 = 0;
            sesInfo.userInput.numOfPC3 = 0;
        elseif numRedSteps == 2
            sesInfo.userInput.numOfPC1 = PCBefore; %sesInfo.userInput.numComp;
            sesInfo.userInput.numOfPC2 = sesInfo.userInput.numComp;         % cliff: read the line 1531 in "icatb_setup_analysis.m"   
            sesInfo.userInput.numOfPC3 = 0;
        else
            sesInfo.userInput.numOfPC1 = PCBefore; %sesInfo.userInput.numComp;
            sesInfo.userInput.numOfPC2 = PCBefore; %sesInfo.userInput.numComp;
            sesInfo.userInput.numOfPC3 = sesInfo.userInput.numComp;
        end
        clear numRedSteps PCBefore minTp minTpInd
        
        
        % set target dir
        tem=deblank(groups(i_group,:));
        target_dir=[tem(1,1:end-1) '_ICA_Output_' IC_n{i_group}{1} '_' deblank(IC_n{i_group}{2})];  
        delete(fullfile(target_dir,'*'));
        clear tem
        
        mkdir (target_dir)
        cd (target_dir)
        sesInfo.userInput.pwd=target_dir;    
        
        
        
        sesInfo.userInput.numOfSub = size(Dirs,1);
        sesInfo.userInput.numOfGroups1 = size(Dirs,1);
        sesInfo.userInput.prefix= deblank(IC_n{i_group}{2});
        sesInfo.userInput.param_file=fullfile(sesInfo.userInput.pwd,[sesInfo.userInput.prefix '_ica_parameter_info.mat']);
        
        test=[];
        for i_dir=1:size(Dirs,1)
                Dir=deblank(Dirs(i_dir,:));
                imgs=spm_select('FPList',Dir,'.*img|.*nii');    
                spm_check_orientations(spm_vol(imgs)); % check dimentions and orientations within subjects                
                test=strvcat(test,imgs(1,:));                
              
                sesInfo.userInput.files(1,i_dir).name=imgs;   
                sesInfo.userInput.diffTimePoints(1,i_dir)= size(imgs,1);   
        end
        spm_check_orientations(spm_vol(test)); % check dimentions and orientations across subjects
        
        wholeV_mask = spm_check_orientations_and_resliceToTarget(wholeV_mask,test(1,:));    
        ROI_mask=spm_check_orientations_and_resliceToTarget(ROI_mask,test(1,:));   
        
        sesInfo.userInput.maskFile= wholeV_mask;
        sesInfo.userInput.scaleType= 2; % z-score
        V=FG_read_vols(wholeV_mask); % use in the next spatial-sorting
        V(isnan(V))=0;
        V=double(logical(V(:)));
        sesInfo.userInput.mask_ind= find(V);  % mask area indices
        
        [tem_data, HInfo, tem_XYZ] = icatb_loadData(wholeV_mask);
        sesInfo.userInput.HInfo= HInfo;
        
        clear Mat imgs tem_XYZ tem_data HInfo   
        
        eval(['save ''' sesInfo.userInput.param_file ''' sesInfo'])
        
%         param_file=sesInfo.userInput.param_file;
        

    %%% run analysis
        groupICAStep='all';
        FG_icatb_runAnalysis(sesInfo, groupICAStep) ;

    %%% sort the ICs
            
        % unzip IC.zip
            zip_ICs=spm_select('FPList',target_dir,'mean_component_ica_s_all*.*zip');
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
            pure_ICs=ICs;
            pure_ICs=FG_remove_paths(pure_ICs);
            ROI_mask_names=FG_remove_paths(ROI_mask);
            
            mark_ICs=zeros(size(ICs,1),1);
            
            first_dir=FG_separate_files_into_name_and_path(ICs(1,:));    
            write_name=fullfile(target_dir,[sesInfo.userInput.prefix 'IC_potential_names_report.txt']);
            write_name2=fullfile(target_dir,[sesInfo.userInput.prefix 'IC_spatial_CorrelationCoefficient_report.txt']);
            dlmwrite(write_name,['----------Potential IC names report for total ' num2str(size(ROI_mask,1)) ' ROI-masks and ' num2str(size(ICs,1)) ' ICs, first image locates ' first_dir ' ------------------'], 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name2,['----------Spatial IC Correlation-Coefficient report for total ' num2str(size(ROI_mask,1)) ' ROI-masks and ' num2str(size(ICs,1)) ' ICs, first image locates ' first_dir ' ------------------'], 'delimiter', '', 'newline','pc'); 
            
            for ROI_i=1:size(ROI_mask,1)            
                template =  FG_read_vols(deblank(ROI_mask(ROI_i,:))); 
%                 % for spatial-match correlation
%                 template =template(:);
%                 template = template.*V(:);
                % for dice coefficient
                template = template.*reshape(V,size(template,1),size(template,2),size(template,3));                
                
                
                %                 % do spatial-match correlation
                %                 all_r=[];
                %                 for i=1:size(ICs,1)
                %                     data = FG_read_vols(deblank(ICs(i,:)));
                %                     data(isnan(data))=0;
                %                     data((1-data)<eps)=0;  % cliff: instead of using   data(data<1)=0, see: http://matlab.wikia.com/wiki/FAQ#Why_is_0.3_-_0.2_-_0.1_.28or_similar.29_not_equal_to_zero.3F
                %                     % cliff attention
                %                     % data(data>5)=0;  % this depend on the choice of the fat-template
                %                     data((data-1)>=eps)=1;  % cliff: instead of using   data(data>=1)=1, 
                %                     data=data(:);
                %                     % template(data ~= 1)=0;
                %                     r = icatb_corr(template(:),data);
                %                     all_r=[all_r;r];
                %                     % all_r_square=all_r.*all_r;
                %                 end                
                
                % do dice similarity coefficient calculation
                all_r=[];
                for i=1:size(ICs,1)
                        data = FG_read_vols(deblank(ICs(i,:)));
                        data(isnan(data))=0;
                        data((1-data)<eps)=0;  % cliff: instead of using   data(data<1)=0, see: http://matlab.wikia.com/wiki/FAQ#Why_is_0.3_-_0.2_-_0.1_.28or_similar.29_not_equal_to_zero.3F      
                      %1. set one image non-zero values as 200
                        data(data>0)=200;
                      %2. set second image non-zero values as 300
                        template(template>0)=300;
                      %3. set overlap area 100
                        OverlapImage = template-data;
                      %4. count the overlap100 pixels
                        [r,c,v] = find(OverlapImage==100);
                        countOverlap100=size(r);
                      %5. count the image200 pixels
                        [r1,c1,v1] = find(data==200);
                        img1_200=size(r1);
                      %6. count the image300 pixels
                        [r2,c2,v2] = find(template==300);
                        img2_300=size(r2);
                      %7. calculate Dice Coef
                        Coef=2*countOverlap100/(img1_200+img2_300);
                        all_r=[all_r;Coef];
                end
                              
                
                % the sorted order of ICs
                [sorted,Idx]=sort(all_r,'descend')  ;          
                pure_ICs(Idx,:);
                dlmwrite(write_name,['===  ' num2str(ROI_i)  ': ' deblank(ROI_mask_names(ROI_i,:)) '  ===' ], '-append',  'delimiter', '', 'newline','pc');
                for i=1:1
                    dlmwrite(write_name,['                                      The most likely IC would be   ', pure_ICs(Idx(i),:) '   r=' num2str(sorted(i))], '-append',  'delimiter', '', 'newline','pc');
                end
                mark_ICs(Idx(i),1)=1;
                
                dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name2,[num2str(ROI_i) ': Spatial CC with    ' deblank(ROI_mask_names(ROI_i,:)) '    are : '], '-append',  'delimiter', '', 'newline','pc');
                
                for i=1:size(ICs,1)
                    dlmwrite(write_name2,['      ', pure_ICs(Idx(i),:) '  r=' num2str(sorted(i))], '-append',  'delimiter', '', 'newline','pc');
                end
                dlmwrite(write_name2,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name2,'         ', '-append',  'delimiter', '', 'newline','pc');
            end
            
            % delete all the "noise" ICs
            for i_del=1:size(mark_ICs,1)
                if ~mark_ICs(i_del)
                    delete(deblank(ICs(i_del,:)))
                    delete(FG_corresponding_name_of_hdr_img_pair(deblank(ICs(i_del,:))))
                end
            end
            
            
            fprintf('\n-------ICA for the %d / %d groups is done-------\n',i_group,size(groups,1))   
    end

fprintf('\n-----All set!--\n')     




