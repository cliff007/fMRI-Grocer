function [GC2,causf_flow,causd_ucdw]=FG_GCCA_single(imgs,brain,ROIs,Val_range_low,Val_range_up,NLAGS,PVAL,Fs,freqs,htype)
% this function is taking advantage of the scripts from:
    % http://www.anilseth.com/ (Granger Causal Connectivity Analysis: A MATLAB Toolbox) %
% made by cliff - Nov. 20. 2012

    a=which('ccaStartup');
    if isempty(a)
        fprintf('\n-------No GCCA toolbox is detected in Matlab path...\n')  
        return
    else
        ccaStartup;
    end

    if nargin==0
        %  initial parameters 
        PVAL    =   0.01;       % probability threshold for Granger causality significance
        NLAGS   =   -1;         % if -1, best model order is assessed automatically
        Fs      =   500;        % sampling frequency  (for spectral analysis only)
        freqs   =   [1:100];    % frequency range to analyze (spectral analysis only)
        Val_range_low=0;
        Val_range_up=inf;

        htype=questdlg('Voxel-wise or ROI-wise?', 'Hi...','Voxel-wise','ROI-wise','ROI-wise') ;

        imgs = spm_select(Inf,'any','Select images to be read', [],pwd,'.*img$|.*nii$');
        if isempty(imgs), return, end

        if  strcmpi(htype,'ROI-wise') 
            ROIs = spm_select([2,Inf],'any','Select ROIs(At least two for ROI-wise)', [],pwd,'.*img$|.*nii$');
            if isempty(ROIs), return, end
            if size(ROIs,1)<2, return, end
        else
            ROIs = spm_select(inf,'any','Select ROIs(If more than one, will do GCCA for ROIs one by one)', [],pwd,'.*img$|.*nii$'); 
            if isempty(ROIs), return, end
        end

        brain = spm_select(1,'any','Select a whole brain mask,or skip this step~', [],pwd,'.*img$|.*nii$');
    end

% initinate the parameters...
    fprintf('\n-------Extracting the ROI time-courses...\n')  
    TC=FG_get_meanCBF_TC_in_ROIs_singlesubDir_CMD(imgs,brain,ROIs,Val_range_low,Val_range_up);

if  strcmpi(htype,'ROI-wise')  
    
    nvar = size(TC,2); % number of variables for ROI-wise; 
    N = size(TC,1);    % number of observations  , == N=size(imgs,1); 
    X=TC'; % transpose the TC matrix to make each row represent one variable  
    write_name=fullfile(FG_read_root_of_an_img(imgs),['GCCA_ROIWise_GCs_of_' num2str(nvar) '_ROIs.txt']);
    try 
        [GC2,causf_flow,causd_ucdw]=FG_run_whole_GCA(X,NLAGS,nvar,N,PVAL,Fs,freqs,htype) ;
    catch me
        me.message
    end

    dlmwrite(write_name,['The order of ROIs:'], 'delimiter', '', 'newline','pc'); 
    for i =1:nvar
        dlmwrite(write_name, ['          ', num2str(i), '  ', deblank(ROIs(i,:))], '-append', 'delimiter', '', 'newline','pc');
    end
    dlmwrite(write_name,['                        '], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,['G-causality networks in matrix form(Read as Column causes Row): '], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,['                        '], '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(write_name,num2str(GC2),  '-append', 'delimiter', '', 'newline','pc'); % Attention: this kind of writting is convinent
    
    
    fprintf('\n ---ROI-wise GCCA is done...\n')  

elseif  strcmpi(htype,'Voxel-wise') 
    fprintf('\n ---It may takes quite a long time.Be patient...\n') 
    Pause(5)
    
    nvar = 2; % number of variables for Voxel-wise;      
    n_ROIs=size(TC,2);   % number of ROIs; 
    N = size(TC,1);    % number of observations  , == N=size(imgs,1);  
    
    % make the brain mask
    if isempty(brain) || strcmp(brain,'Non-wholebrain_mask')
        V=spm_vol(deblank(imgs(1,:)));% read a piece cbf img
        dat = spm_read_vols(V);   
        brain_mask=ones(size(dat)); % that means no mask is used
        clear V dat;
        brain='Non-wholebrain_mask';
    else     
        V_brain = spm_vol(deblank(brain));
        brain_tem=spm_read_vols(V_brain);
        brain_tem(isnan(brain_tem))=0;
        brain_mask = double(logical(brain_tem));
    end    
    
    vaild_voxels=find(brain_mask);
    [V,Vmat]=FG_read_vols(imgs);   
    brain_mask_4D=repmat(brain_mask,[1,1,1,size(V,4)]);
    masked_V=V.*brain_mask_4D;
    write_name=fullfile(FG_read_root_of_an_img(imgs),'GCCA_VoxelWise_GCs_ROIs.txt');
    dlmwrite(write_name,['The order of ROIs:'], 'delimiter', '', 'newline','pc'); 
    
    for i=1:n_ROIs
        fprintf('\n ---Doing GCCA for ROI - %d ...\n',i)  
        ROI2Voxel=zeros(size(brain_mask));
        Voxel2ROI=zeros(size(brain_mask));
        for k=1:length(vaild_voxels)
            [a,b,c]=ind2sub(size(brain_mask),vaild_voxels(k));
            tem=squeeze (V(a,b,c,:))';
            X=[TC(:,i)';tem];
            clear tem
            
            try 
                [GC2,causf_flow,causd_ucdw]=FG_run_whole_GCA(X,NLAGS,nvar,N,PVAL,Fs,freqs,htype)   ;
                ROI2Voxel(a,b,c)=GC2(2,1);
                Voxel2ROI(a,b,c)=GC2(1,2);
            catch me
                me.message
                continue
            end
        end
        FG_write_vol(Vmat(1),ROI2Voxel,['GCCA_VoxelWise_ROI2Voxel_ROI_' num2str(i) '.img'])
        FG_write_vol(Vmat(1),Voxel2ROI,['GCCA_VoxelWise_Voxel2ROI_ROI_' num2str(i) '.img'])       
        dlmwrite(write_name, ['          ', num2str(i), '  ', deblank(ROIs(i,:))], '-append', 'delimiter', '', 'newline','pc');
    end    
    
    fprintf('\n ---Voxel-wise GCCA is done...\n')       
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% sub-functions %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [GC2,causf_flow,causd_ucdw]=FG_run_whole_GCA(X,NLAGS,nvar,N,PVAL,Fs,freqs,htype)   
            %-------- preliminary data checking
            NLAGS=FG_GCA_preliminary_data_checking(X,NLAGS) ;
            %--------analyze time-domain granger
            [GC2,causf_flow,causd_ucdw]=FG_GCA_time_domain(X,NLAGS,nvar,N,PVAL,htype);
%             if  strcmpi(htype,'ROI-wise')  
%                 %--------analyze frequency-domain granger
%                 FG_GCA_frequency_domain(X,NLAGS,nvar,N,Fs,freqs,htype)   
%             end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% preliminary data checking --------  
        function NLAGS=FG_GCA_preliminary_data_checking(X,NLAGS)   
            % detrend and demean data
            disp('detrending and demeaning data');
            X = cca_detrend(X);
            X = cca_rm_temporalmean(X);

            % check covariance stationarity
            disp('checking for covariance stationarity ...');
            uroot = cca_check_cov_stat(X,10);
            inx = find(uroot);
            if sum(uroot) == 0,
                disp('OK, data is covariance stationary by ADF');
            else
                disp('WARNING, data is NOT covariance stationary by ADF');
                disp(['unit roots found in variables: ',num2str(inx)]);
            end

            % check covariance stationarity again using KPSS test
            [kh,kpss] = cca_kpss(X);
            inx = find(kh==0);
            if isempty(inx),
                disp('OK, data is covariance stationary by KPSS');
            else
                disp('WARNING, data is NOT covariance stationary by KPSS');
                disp(['unit roots found in variables: ',num2str(inx)]);
            end

            % find best model order
            if NLAGS == -1,
                disp('finding best model order ...');
                [bic,aic] = cca_find_model_order(X,2,12);
                disp(['best model order by Bayesian Information Criterion = ',num2str(bic)]);
                disp(['best model order by Aikaike Information Criterion = ',num2str(aic)]);
                NLAGS = aic;
            end

            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% analyze time-domain granger --------  
        function [GC2,causf_flow,causd_ucdw]=FG_GCA_time_domain(X,NLAGS,nvar,N,PVAL,htype)
            % find time-domain conditional Granger causalities [THIS IS THE KEY FUNCTION]
            disp('finding conditional Granger causalities ...');
            ret = cca_granger_regress(X,NLAGS,1);   % STATFLAG = 1 i.e. compute stats

            % check that residuals are white
            dwthresh = 0.05/nvar;    % critical threshold, Bonferroni corrected
            waut = zeros(1,nvar);
            for ii=1:nvar,
                if ret.waut<dwthresh,
                    waut(ii)=1;
                end
            end
            inx = find(waut==1);
            if isempty(inx),
                disp('All residuals are white by corrected Durbin-Watson test');
            else
                disp(['WARNING, autocorrelated residuals in variables: ',num2str(inx)]);
            end

            % check model consistency, ie. proportion of correlation structure of the
            % data accounted for by the MVAR model
            if ret.cons>=80,
                disp(['Model consistency is OK (>80%), value=',num2str(ret.cons)]);
            else
                disp(['Model consistency is <80%, value=',num2str(ret.cons)]);
            end

            % analyze adjusted r-square to check that model accounts for the data (2nd
            % check)
            rss = ret.rss_adj;
            inx = find(rss<0.3);
            if isempty(inx)
                disp(['Adjusted r-square is OK: >0.3 of variance is accounted for by model, val=',num2str(mean(rss))]);
            else
                disp(['WARNING, low (<0.3) adjusted r-square values for variables: ',num2str(inx)]);
                disp(['corresponding values are ',num2str(rss(inx))]);
                disp('try a different model order');
            end

            % find significant Granger causality interactions (Bonferonni correction)
            [PR,q] = cca_findsignificance(ret,PVAL,1);
            disp(['testing significance at P < ',num2str(PVAL), ', corrected P-val = ',num2str(q)]);

            % extract the significant causal interactions only
            GC = ret.gc;
            GC2 = GC.*PR;

            % calculate causal connectivity statistics
            disp('calculating causal connectivity statistics');
            causd = cca_causaldensity(GC,PR);
            causf = cca_causalflow(GC,PR);

            disp(['time-domain causal density = ',num2str(causd.cd)]);
            disp(['time-domain causal density (weighted) = ',num2str(causd.cdw)]);

            % create Pajek readable file
            % cliff
%                 sfile= 'FG_GCCA_demo1_Test.net';
%                 cca_pajek(PR,GC,sfile);

            if  strcmpi(htype,'ROI-wise')              
                %-------------------------------------------------------------------------
                % plot time-domain granger results
                figure(1); clf reset;
                FSIZE = 8;
                colormap(flipud(bone));

                % plot raw time series
                for i=2:nvar,
                    X(i,:) = X(i,:)+(10*(i-1));
                end
                subplot(231);
                set(gca,'FontSize',FSIZE);
                plot(X');
                axis('square');
                set(gca,'Box','off');
                xlabel('time');
                set(gca,'YTick',[]);
                xlim([0 N]);
                title('Causal Connectivity Toolbox v2.0');

                % plot granger causalities as matrix
                subplot(232);
                set(gca,'FontSize',FSIZE);
                imagesc(GC2);
                axis('square');
                set(gca,'Box','off');
                title(['Granger causality, p<',num2str(PVAL)]);
                xlabel('from');
                ylabel('to');
                set(gca,'XTick',[1:N]);
                set(gca,'XTickLabel',1:N);
                set(gca,'YTick',[1:N]);
                set(gca,'YTickLabel',1:N);

                % plot granger causalities as a network
                subplot(233);
                cca_plotcausality(GC2,[],5);

                % plot causal flow  (bar = unweighted, line = weighted)
                subplot(234);
                set(gca,'FontSize',FSIZE);
                set(gca,'Box','off');
                mval1 = max(abs(causf.flow));
                mval2 = max(abs(causf.wflow));
                mval = max([mval1 mval2]);
                bar(1:nvar,causf.flow,'m');
                ylim([-(mval+1) mval+1]);
                xlim([0.5 nvar+0.5]);
                set(gca,'XTick',[1:nvar]);
                set(gca,'XTickLabel',1:nvar);
                title('causal flow');
                ylabel('out-in');
                hold on;
                plot(1:nvar,causf.wflow);
                axis('square');

                % plot unit causal densities  (bar = unweighted, line = weighted)
                subplot(235);
                set(gca,'FontSize',FSIZE);
                set(gca,'Box','off');
                mval1 = max(abs(causd.ucd));
                mval2 = max(abs(causd.ucdw));
                mval = max([mval1 mval2]);
                bar(1:nvar,causd.ucd,'m');
                ylim([-0.25 mval+1]);
                xlim([0.5 nvar+0.5]);
                set(gca,'XTick',[1:nvar]);
                set(gca,'XTickLabel',1:nvar);
                title('unit causal density');
                hold on;
                plot(1:nvar,causd.ucdw);
                axis('square');
            end
            
           causf_flow = causf.flow;
           causd_ucdw = causd.ucdw;
           
            
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% analyze frequency-domain granger --------  
        function FG_GCA_frequency_domain(X,NLAGS,nvar,N,Fs,freqs,htype) 

            SPECTHRESH = 0.2.*ones(1,length(freqs));    % bootstrap not used in this demo

            % find pairwise frequency-domain Granger causalities [KEY FUNCTION]
            disp('finding pairwise frequency-domain Granger causalities ...');
            [GW,COH,pp]=cca_pwcausal(X,1,N,NLAGS,Fs,freqs,0);

            % calculate freq domain causal connectivity statistics
            disp('calculating causal connectivity statistics');
            causd = cca_causaldensity_spectral(GW,SPECTHRESH);
            causf = cca_causalflow_spectral(GW,SPECTHRESH);

            totalcd = sum(causd.scdw);
            disp(['freq-domain causal density (weighted) = ',num2str(totalcd)]);
            
            
            if  strcmpi(htype,'ROI-wise')  
                %-------------------------------------------------------------------------
                % plot frequency-domain granger results
                figure(2); clf reset;
                FSIZE = 8;
                colormap(flipud(bone));

                % plot fft for each variable
                ct = 1;
                for i=1:nvar,
                    subplot(3,nvar,ct);
                    cca_spec(X(i,:),Fs,1);
                    title(['v',num2str(i)]);
                    if i==1,
                        ylabel('fft: amplitude');
                    end
                    ct = ct+1;
                    set(gca,'Box','off');
                end

                % plot causal density spectrum for each variable
                for i=1:nvar,
                    subplot(3,nvar,ct);
                    plot(causd.sucdw(i,:));
                    if i==1,
                        ylabel('unit cd');
                    end
                    ct = ct+1;
                    set(gca,'Box','off');
                end

                % plot causal flow spectrum for each variable
                for i=1:nvar,
                    subplot(3,nvar,ct);
                    plot(causf.swflow(i,:));
                    if i==1,
                        ylabel('unit flow');
                    end
                    ct = ct+1;
                    set(gca,'Box','off');
                end

                % plot network causal density
                figure(3); clf reset;
                plot(causd.scdw);
                set(gca,'Box','off');
                title(['spectral cd, total=',num2str(totalcd),', thresh=',num2str(SPECTHRESH)]);
                xlabel('Hz');
                ylabel('weighted cd');

                % plot causal interactions
                figure(4); clf reset;
                cca_plotcausality_spectral(GW,freqs);

                % plot coherence
                figure(5); clf reset;
                cca_plotcoherence(COH,freqs);
            end

