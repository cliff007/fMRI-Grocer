function varargout=FG_correlation_ROIs_ROIs(ROI_TCs,show_matrix)
%% ROI_TCs: each column is a ROI_TC
if nargin==0
    cd ('D:\FunImgRWSDFC\01_HZQ');
    imgs=FG_list_all_files('D:\FunImgRWSDFC\01_HZQ','*','*img');
    Vol_4D=FG_read_vols(imgs);
    ROI_TCs=Vol_4D(25:35,30,20,:);
    ROI_TCs=squeeze(ROI_TCs)';
    show_matrix=1;
end


fprintf('\nCaculating correlation coefficient of each pair of ROIs...')
ROI_corr = corrcoef(ROI_TCs);
if show_matrix==1
    ROI_corr=FG_set_half_diagonal_matrix_into_n(ROI_corr,0,'below');
    FG_show_correlation_matrix(ROI_corr)
end
fprintf('\....done...\n')


    if nargout~=0
        varargout={ROI_corr};
    end   
    


    
    
    
    
    
    
    
    
    
    
    
    