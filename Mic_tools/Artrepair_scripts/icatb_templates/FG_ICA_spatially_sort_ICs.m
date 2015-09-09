% gift matlab commands
function FG_ICA_spatially_sort_ICs(ICs,Templates)
    clear
    if nargin==0
        tem=FG_rootDir('FG_icatb_runAnalysis');
        ICs=spm_select(inf,'image','Please select a IC(s) for spatial sorting...',[],pwd,'.*');
        ICs=FG_remove_potential_dot1_of_image_names(ICs);
        if isempty(ICs),return,end

        Templates=spm_select(inf,'image','Please select a ROI template(s) for spatial sorting...',[],tem,'.*');
        Templates=FG_remove_potential_dot1_of_image_names(Templates);
        if isempty(Templates),return,end
        
        Wholemask=spm_select(1,'image','Select a brain mask that used to generate ICs; Or just close this window...',[],pwd,'.*');
        if ~isempty(Wholemask)
           brainmask =  FG_read_vols(deblank(Wholemask));
           brainmask(isnan(brainmask))=0;
           brainmask=double(logical(brainmask(:)));
        end
    end
    target_dir = pwd;
    first_dir=FG_separate_files_into_name_and_path(ICs(1,:));
    Templates=spm_check_orientations_and_resliceToTarget(Templates,ICs(1,:));   
     % sort ICs
            pure_ICs=ICs;
            pure_ICs=FG_remove_paths(pure_ICs);
            Templates_names=FG_remove_paths(Templates);

            mark_ICs=zeros(size(ICs,1),1);
            fprintf('\n-----IC soring is running...........   ----------\n')     
 
            write_name=fullfile(target_dir,'IC_potential_names_report.txt');
            write_name2=fullfile(target_dir,'IC_spatial_CorrelationCoefficient_report.txt');
            dlmwrite(write_name,['----------Potential IC names report for total ' num2str(size(Templates,1)) ' ROI-masks and ' num2str(size(ICs,1)) ' ICs, first image locates ' first_dir '------------------'], 'delimiter', '', 'newline','pc'); 
            dlmwrite(write_name2,['----------Spatial IC Correlation-Coefficient report for total ' num2str(size(Templates,1)) ' ROI-masks and ' num2str(size(ICs,1)) ' ICs, first image locates ' first_dir ' ------------------'], 'delimiter', '', 'newline','pc'); 
            
            for ROI_i=1:size(Templates,1)            
                template =  FG_read_vols(deblank(Templates(ROI_i,:))); 
                template =template(:);
                if ~isempty(Wholemask)
                   template = template.*brainmask;  % to be more accuracy, used the whole brain mask to theshold the ROI-template
                end
                % do spatial-match correlation
                all_r=[];
                for i=1:size(ICs,1)
                    data = FG_read_vols(deblank(ICs(i,:)));
                    data(isnan(data))=0;
                    data((1-data)<eps)=0;  % cliff: instead of using   data(data<1)=0, see: http://matlab.wikia.com/wiki/FAQ#Why_is_0.3_-_0.2_-_0.1_.28or_similar.29_not_equal_to_zero.3F
                    % cliff attention
                    % data(data>5)=0;  % this depend on the choice of the fat-template
                    data((data-1)>=eps)=1;  % cliff: instead of using   data(data>=1)=1, 
                    data=data(:);
                    % template(data ~= 1)=0;
                    r = icatb_corr(template(:),data);
                    all_r=[all_r;r];
                    % all_r_square=all_r.*all_r;
                end
                
                % the sorted order of ICs
                [sorted,Idx]=sort(all_r,'descend')  ;          
                pure_ICs(Idx,:);
                dlmwrite(write_name,['===  ' num2str(ROI_i)  ': ' deblank(Templates_names(ROI_i,:)) '  ===' ], '-append',  'delimiter', '', 'newline','pc');
                for i=1:1
                    dlmwrite(write_name,['                                      The most likely IC would be   ', pure_ICs(Idx(i),:) '   r=' num2str(sorted(i))], '-append',  'delimiter', '', 'newline','pc');
                end
                mark_ICs(Idx(i),1)=1;
                
                dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name2,[num2str(ROI_i) ': Spatial CC with    ' deblank(Templates_names(ROI_i,:)) '    are : '], '-append',  'delimiter', '', 'newline','pc');
                
                for i=1:size(ICs,1)
                    dlmwrite(write_name2,['      ', pure_ICs(Idx(i),:) '  r=' num2str(sorted(i))], '-append',  'delimiter', '', 'newline','pc');
                end
                dlmwrite(write_name2,'         ', '-append',  'delimiter', '', 'newline','pc');
                dlmwrite(write_name2,'         ', '-append',  'delimiter', '', 'newline','pc');
            end



fprintf('\n-----IC soring is done   ----------\n')     




