% Matlab中FFT变换实现频谱分析的基本代码如下：

function FG_spectral_analysis_CBF(CBFs,brain_mask)
% test directory: image resolution is 75*95*68
% cd ('D:\KuaiPan\Dropbox\paper work\Manuscripts\4 CBF-ICA=Half Done=\all_avged_wMeanCBF')
% cd ('D:\KuaiPan\Dropbox\PaperWork\Manuscripts\4 CBF-ICA=Half Done=\all_avged_wMeanCBF\')
% cd ('E:\Spectral_analyis_demo_data\ep2d_pcasl_ToPN_Resting\20131210_K4_TOPN_ASL_S001')
% cd('E:\Spectral_analyis_demo_data\006_ep2d_bold_moco_TR2560_iPAT2_REST_150\20150105_K4_TOPO_AC_S001')

if nargin==0
    % select image files 
    CBFs=spm_select(inf,'.img|.nii','Select images that you want to deal with ', [],pwd,'^.*');
    if isempty(CBFs), return,end
    brain_mask=spm_select(1,'.img|.nii','Select the whole brain mask ', [],fullfile(FG_rootDir('grocer'),'Templates'),'.*');
    if isempty(brain_mask), return,end
    ROIs=spm_select(inf,'.img|.nii','Select ROIs that you want to apply ', [],'D:\KuaiPan\Dropbox\PaperWork\Manuscripts\1 concurrent CBF and BOLD【Done】religion data\named ICs_Pics\ICs ROIs_for_CBF','.*');
    if isempty(ROIs), return,end
end

    prompt = {'Enter your scan TR:'};
    dlg_title = 'TR...';
    num_lines = 1;
    def = {'8'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    TR=str2num(answer{1});


% close all
pause(0.5)

% TC=FG_get_meanCBF_TC_in_ROIs_singlesubDir_CMD(CBFs,brain_mask,brain_mask,0,inf);
[Vs,Vmats]=FG_read_vols(CBFs); Vmat=Vmats(1); clear Vmats
Vs=FG_make_sure_NaN_to_zero_img(Vs);
Dim1=size(Vs,1);
Dim2=size(Vs,2);
Dim3=size(Vs,3);
Dim4=size(Vs,4);


[Vmask,Vmat_mask]=FG_read_vols(brain_mask); clear Vmat_mask
Vmask=FG_make_sure_binary_img(Vmask);
mask_voxles=find(Vmask(:)); % use to select voxels in the mask later
Vmask=repmat(Vmask,[1,1,1,Dim4]);

% mask the Vs
Vs=Vs.*Vmask; % or Vs(~Vmask)=0;
clear Vmask

%     TR=2;           % the sampling time of fMRI sequence
    fs=1/TR;        % the sampling frequency    
     
    N=Dim4;   % get the length of signal
    paddedN=FG_rest_nextpow2_one35(N); % use an additional function to replace 2^nextpow2(N);   %% cliff
    t = (0:(N-1))*TR;    % the Time vector according to the [TR] and [N]
    f_precision = fs/paddedN;
    f_t=(0:(paddedN-1))*f_precision ; f_t=f_t';
    
%%%%%%%%%%%    
%%%%%%%%%%% 1. for a single voxel
%%%%%%%%%%% 
        x=squeeze(Vs(25,70,45,:));  % the signal of a voxel in a fMRI scan %% a kind of brain size: [79 95 68]

        % plot the Time-domain curve
        figure(1)
        subplot(151);plot(t,x);        
        title('Signal of Time-domain x(t)');
        xlabel('t')
        ylabel('x(t)')


        %%% rewritten by cliff
        Y = fft(detrend(double(x)),paddedN);    %% it is suggested to remove the linear treand before fft
        magY = abs(Y);   % get the two times' amplitude of the spectrum of the signal
%         % plot the Amplitude of specturm of detrended
%         figure(1);
%         subplot(152); 
%         plot(f_t(1:ceil(paddedN/2)),magY(1:ceil(paddedN/2)));   % plot(f_t,magY);        % plot the continuous curve of the amplitude   
%         title('The Amplitude of the whole Signal Frequency (detrended)');
%         xlabel('Frequency (Hz)')
%         ylabel('Amplitude - |Y(f)|')
%         grid on
        
        % plot the power specturm
        powerY=magY.^2/Dim4;
        figure(1);
        subplot(143); 
%         plot(f_t,powerY);
        plot(f_t(1:ceil(paddedN/2)),powerY(1:ceil(paddedN/2)))
        title('The Power of the whole Signal Frequency (detrended)');
        xlabel('Frequency (Hz)')
        ylabel('Power - |Y(f)|') 
        grid on
        
        % plot the Amplitude of specturm of undetrended
        Y_undetrend = fft(double(x),paddedN);    %% it is suggested to remove the linear treand before fft
        magY_undetrend = abs(Y_undetrend);   % get the two times' amplitude of the spectrum of the signal
        figure(1);
        subplot(144); plot(f_t(1:ceil(paddedN/2)),magY_undetrend(1:ceil(paddedN/2)));   % plot(f_t,magY);        % plot the continuous curve of the amplitude   
        title('The Amplitude of the whole Signal Frequency (undetrended)');
        xlabel('Frequency (Hz)')
        ylabel('Amplitude - |Y(f)|')
        grid on
        max_y_lim=get(gca,'YLim');
        
        
        % % plot the Amplitude of specturm of detrended in the undetreand ylim
        figure(1);
        subplot(142); 
        plot(f_t(1:ceil(paddedN/2)),magY(1:ceil(paddedN/2)));   % plot(f_t,magY);        % plot the continuous curve of the amplitude   
        title('The Amplitude of the whole Signal Frequency (detrended)');
        ylim(max_y_lim)
        xlabel('Frequency (Hz)')
        ylabel('Amplitude - |Y(f)|')
        grid on
        
        
        
%%%%%%%%%%%        
%%%%%%%%%%% 2. for the whole 4-D brain 
%%%%%%%%%%%         
        Vs_4D=Vs; clear Vs
        file_prefix_Vs='Vs_';
        file_prefix_FFT='Y_';
        file_prefix_magFFT='magY_';
        file_prefix_FFT_d='Y_d_';
        file_prefix_magFFT_d='magY_d_';
        min_points_of_Dim1=10;
        
        % save 4D big matrix into pieces on the disk
        [tem_dir,N_pieces]=FG_Save_4D_matrix_into_Pieces_along_Dim1(Vs_4D, file_prefix_Vs, min_points_of_Dim1);

        % FFT for each piece of the small 4D dataset on the disk
        for i=1:N_pieces
            V_tem=FG_Load_4D_Pieces_of_Dim1(tem_dir,file_prefix_Vs,i);
            V_tem = cat(4,V_tem,zeros(size(V_tem,1),Dim2,Dim3,paddedN - N));	%padded with zero
            V_tem = double(V_tem);
            
            % fft
        %% for undetrend
            Y_tem = fft(V_tem,[],4);    %% 
            %Y_tem=Y_tem(:,:,:,1:N);
            Y_tem=Y_tem(:,:,:,1:paddedN);
            
            % get the magnitude of the spectrum
            magY_tem = abs(Y_tem);   % get the two times' amplitude of the spectrum of the signal
            
            % Save results into files on the disk
            theFile =fullfile(tem_dir, sprintf([file_prefix_FFT '%.8d'], i));		
            save(theFile, 'Y_tem'); 	
            
            theFile =fullfile(tem_dir, sprintf([file_prefix_magFFT '%.8d'], i));		
            save(theFile, 'magY_tem'); 	
            
         %% for detrend
            theMean=mean(V_tem,4);
            %V_tem_detrend=V_tem-repmat(theMean,[1,1,1, N]); % it is suggested to remove the linear treand before fft
            V_tem_detrend=V_tem-repmat(theMean,[1,1,1,paddedN]); % it is suggested to remove the linear treand before fft
            
            Y_tem_detrend = fft(V_tem_detrend,[],4);    %% 
            %Y_tem_detrend=Y_tem_detrend(:,:,:,1:N);
            Y_tem_detrend=Y_tem_detrend(:,:,:,1:paddedN);
            
            % get the magnitude of the spectrum
            magY_tem_detrend = abs(Y_tem_detrend);   % get the two times' amplitude of the spectrum of the signal
            
            % Save results into files on the disk
            theFile =fullfile(tem_dir, sprintf([file_prefix_FFT_d '%.8d'], i));		
            save(theFile, 'Y_tem_detrend'); 	
            
            theFile =fullfile(tem_dir, sprintf([file_prefix_magFFT_d '%.8d'], i));		
            save(theFile, 'magY_tem_detrend'); 	

            
        end

        clear Y_tem_detrend magY_tem_detrend V_tem_detrend V_tem Vs_4D
        clear Y_tem magY_tem V_tem V_tem Vs_4D
        
        Y_4D_detrend=FG_combine_4D_Pieces_of_Dim1_into_big4D(tem_dir, file_prefix_FFT_d, min_points_of_Dim1, Dim1);	
        Y_4D=FG_combine_4D_Pieces_of_Dim1_into_big4D(tem_dir, file_prefix_FFT, min_points_of_Dim1, Dim1);	        
        new_name = FG_simple_rename_untouch(Vmat.fname,'FFT_spectural_d.nii');
%         FG_write_vol(Vmat,mean(Y_4D,4),new_name);
        fprintf('\n.................the range of FFT is %s ~ %s \n',num2str(min(min(min(min(Y_4D_detrend))))),num2str(max(max(max(max(Y_4D_detrend))))))
        clear Y_4D_detrend
        
        
        magY_4D_detrend=FG_combine_4D_Pieces_of_Dim1_into_big4D(tem_dir, file_prefix_magFFT_d, min_points_of_Dim1, Dim1);	
        magY_4D=FG_combine_4D_Pieces_of_Dim1_into_big4D(tem_dir, file_prefix_magFFT, min_points_of_Dim1, Dim1);	
        new_name = FG_simple_rename_untouch(Vmat.fname,'FFT_mag_spectural_d.nii');
%         FG_write_vol(Vmat,mean(magY_4D,4),new_name);
        fprintf('\n.................the range of FFT_mag is %s ~ %s \n',num2str(min(min(min(min(magY_4D_detrend))))),num2str(max(max(max(max(magY_4D_detrend))))))
        
        magY_2D_detrend=reshape(magY_4D_detrend,[Dim1*Dim2*Dim3,Dim4]);
        magY_2D=reshape(magY_4D,[Dim1*Dim2*Dim3,Dim4]);
        
        tem_magY_2D_detrend=magY_2D_detrend(mask_voxles,:);
        tem_magY_2D=magY_2D(mask_voxles,:);
        
        figure(2)
        subplot(133);
        plot(f_t(1:paddedN/2),2*mean(tem_magY_2D_detrend(:,1:paddedN/2),1)) % multiply 2 just because I only plot half of the spectrum, so I make all enery to the plotted half part 
        title('The averaged spectrum of whole brain(detrended)');
        xlabel('Frequency (Hz)')
        ylabel('Amplitude') 
        grid on
        
        subplot(132);
        plot(f_t(1:paddedN/2),2*mean(tem_magY_2D(:,1:paddedN/2),1)) % multiply 2 just because I only plot half of the spectrum, so I make all enery to the plotted half part 
        title('The averaged spectrum of whole brain(undetrended)');
        xlabel('Frequency (Hz)')
        ylabel('Amplitude') 
        grid on
        max_y_lim=get(gca,'YLim');
        
        figure(2)
        subplot(131);
        plot(f_t(1:paddedN/2),2*mean(tem_magY_2D_detrend(:,1:paddedN/2),1)) % multiply 2 just because I only plot half of the spectrum, so I make all enery to the plotted half part 
        title('The averaged spectrum of whole brain(detrended)');
        xlabel('Frequency (Hz)')
        ylabel('Amplitude') 
        ylim(max_y_lim)
        grid on        
        
        clear tem_magY_2D_detrend tem_magY_2D

       maskVs=FG_read_vols(ROIs);
       [tt, name_ROIs]=FG_separate_files_into_name_and_path(ROIs);
       clear tt
        for i=1:size(maskVs,4)
            fprintf('\n..........The averaged spectrum of ROI %s \n',num2str(i))
            figure(i+2)
            tem=squeeze(maskVs(:,:,:,i));
            tem=FG_make_sure_binary_img(tem(:));
            ROI_voxels=find(tem);
            
            magY_2D_tem_detrend=magY_2D_detrend(ROI_voxels,:);% remove all the voxels that is out of the ROI
            magY_2D_tem=magY_2D(ROI_voxels,:);% remove all the voxels that is out of the ROI
            
            subplot(141);
            plot(f_t(1:paddedN/2),2*mean(magY_2D_tem_detrend(:,1:paddedN/2),1))
            title(['The averaged spectrum of ' deblank(name_ROIs(i,:)) ' detrended']);
            xlabel('Frequency (Hz)')
            ylabel('Amplitude') 
            grid on
            
            subplot(142);
            plot(f_t(1:paddedN/2),2*mean(magY_2D_tem(:,1:paddedN/2),1))
            title(['The averaged spectrum of ' deblank(name_ROIs(i,:)) ' undetrended']);
            xlabel('Frequency (Hz)')
            ylabel('Amplitude') 
            grid on
  
            subplot(143);
            plot(magY_2D_tem')
            title(['All undetrended Amplitude of this ROI']);
            xlabel('Frequency (Hz)')
            ylabel('Amplitude') 
            grid on         
 
            subplot(144);
            plot(magY_2D_tem_detrend')
            title(['All detrended Amplitude of this ROI']);
            xlabel('Frequency (Hz)')
            ylabel('Amplitude') 
            grid on   
            
            clear magY_2D_tem_detrend magY_2D_tem
        end        
       
        clear magY_2D_detrend
        clear magY_2D_detrend
        % delete the temp folder created during the data analysis
        rmdir(tem_dir,'s')







