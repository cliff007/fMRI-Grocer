function varargout=FG_art_approximate_motion_judge(imgs,varargin)
%%  varargin can be either a pre-defined mask filename or an output folder
% varargouts are {out_idx;mvout_idx;glout_idx'};
% corresponding to  three outputs:   all the outliers; outliers based on motion; outliers based on intensity
% e.g.   [all_idx,motion_idx,intensity_idx]=FG_art_approximate_motion_judge(imgs)
if nargin==0
    imgs=spm_select(Inf,'image','Select images...',[],pwd,'^p.*');
%     mask=spm_select(1,'image','Select a mask...',[],pwd,'.*');
end

if exist(varargin{1}) ==2   % if it is a mask file
   mask= varargin{1};
elseif exist(varargin{1})==7 % if it is an output directory
   outdir= varargin{1};
end

nscans=size(imgs,1);
VY=spm_vol(imgs);
realignfile = 0;
GoRepair = 2;
repair1_flag =0;

if nargin==1 || exist(varargin{1})==7
    % option 1, spm_global
            maskY=FG_get_SPM_global_mask(imgs(1,:),outdir);
% %                 [a,b,c,d]=fileparts(deblank(imgs(1,:)));
% %                 Vmat_out=VY(1);
% %                 Vmat_out.fname=fullfile(a,'SPM_Global_mask.nii'); 
% %                 spm_write_vol(Vmat_out,maskY);
    % option 2     
%             maskY=FG_art_automask(VY(1).fname);
% %             [a,b,c,d]=fileparts(deblank(imgs(1,:)));
% %             Vmat_out=VY(1);
% %             Vmat_out.fname=fullfile(a,'Art_auto_mask.nii'); 
% %             spm_write_vol(Vmat_out,maskY);
            
elseif nargin==2 || exist(varargin{1})==2
    maskY=spm_read_vols(spm_vol(mask));
end

maskcount = sum(sum(sum(maskY)));  %  Number of voxels in mask.
voxelcount = prod(size(maskY));    %  Number of voxels in 3D volume.

for i = 1:nscans    
    Y = spm_read_vols(VY(i));
    Y = Y.*maskY;
    output = FG_art_centroid_paras(Y);
    centroiddata(i,1:3) = output(2:4);
    g(i) = output(1)*voxelcount/maskcount;
end
    
% If computing approximate translation alignment on the fly...
    %   centroid was computed in voxels
    %   voxel size is VY(1).mat(1,1), (2,2), (3,3).
    %   calculate distance from mean as our realignment estimate
    %   set rotation parameters to zero.

centroidmean = mean(centroiddata,1);
for i = 1:nscans
    mv0data(i,:) = - centroiddata(i,:) + centroidmean;
end
% THIS MAY FLIP L-R  (x translation)
mv_data(1:nscans,1) = mv0data(1:nscans,1)*VY(1).mat(1,1);
mv_data(1:nscans,2) = mv0data(1:nscans,2)*VY(1).mat(2,2);
mv_data(1:nscans,3) = mv0data(1:nscans,3)*VY(1).mat(3,3);
mv_data(1:nscans,4:6) = 0;

% Convert rotation movement to degrees
mv_data(:,4:6)= mv_data(:,4:6)*180/pi; 
fprintf('\n---Motion paras is extracted...\n')
% fprintf('\n%g voxels were in the auto generated mask.\n', maskcount)





% ------------------------
% Default values for outliers
% ------------------------
% When std is very small, set a minimum threshold based on expected physiological
% noise. Scanners have about 0.1% error when fully in spec. 
% Gray matter physiology has ~ 1% range, ~0.5% RMS variation from mean. 
% For 500 samples, expect a 3-sigma case, so values over 1.5% are
% suspicious as non-physiological noise. Data within that range are not
% outliers. Set the default minimum percent variation to be suspicious...
      Percent_thresh = 1.3; 
%  Alternatively, deviations over 2*std are outliers, if std is not very small.
      z_thresh = 2;  % Currently not used for default.
% Large intravolume motion may cause image reconstruction
% errors, and fast motion may cause spin history effects.
% Guess at allowable motion within a TR. For good subjects,
% would like this value to be as low as 0.3. For clinical subjects,
% set this threshold higher.
      mv_thresh = 0.5;  % try 0.3 for subjects with intervals with low noise
                        % try 1.0 for severely noisy subjects  


% ------------------------
% Compute default out indices by z-score, or by Percent-level is std is small.
% ------------------------ 
%  Consider values > Percent_thresh as outliers (instead of z_thresh*gsigma) if std is small.
    gsigma = std(g);
    gmean = mean(g);
    pctmap = 100*gsigma/gmean;
    mincount = Percent_thresh*gmean/100;
    %z_thresh = max( z_thresh, mincount/gsigma );
    z_thresh = mincount/gsigma;        % Default value is PercentThresh.
    z_thresh = 0.1*round(z_thresh*10); % Round to nearest 0.1 Z-score value
    zscoreA = (g - mean(g))./std(g);  % in case Matlab zscore is not available
    glout_idx = (find(abs(zscoreA) > z_thresh))';

% ------------------------
% Compute default out indices from rapid movement
% ------------------------ 
%   % Rotation measure assumes voxel is 65 mm from origin of rotation.

    delta = zeros(nscans,1);  % Mean square displacement in two scans
    for i = 2:nscans
        delta(i,1) = (mv_data(i-1,1) - mv_data(i,1))^2 +...
                (mv_data(i-1,2) - mv_data(i,2))^2 +...
                (mv_data(i-1,3) - mv_data(i,3))^2 +...
                1.28*(mv_data(i-1,4) - mv_data(i,4))^2 +...
                1.28*(mv_data(i-1,5) - mv_data(i,5))^2 +...
                1.28*(mv_data(i-1,6) - mv_data(i,6))^2;
        delta(i,1) = sqrt(delta(i,1));
    end

    
    % Also name the scans before the big motions (v2.2 fix)
    deltaw = zeros(nscans,1);
    for i = 1:nscans-1
        deltaw(i) = max(delta(i), delta(i+1));
    end
    delta(1:nscans-1,1) = deltaw(1:nscans-1,1);
    
    % Adapt the threshold  (v2.3 fix)
        delsort = sort(delta);
        if delsort(round(0.75*nscans)) > mv_thresh
            mv_thresh = min(1.0,delsort(round(0.75*nscans)));  % cliff: try to adjust motion threshold based on 75% images
            words = ['Automatic adjustment of movement threshold to ' num2str(mv_thresh)];
            disp(words)
            Percent_thresh = mv_thresh + 0.8;    % v2.4
        end
    
    mvout_idx = find(delta > mv_thresh)';
    
    % Total repair list
    out_idx = unique([mvout_idx glout_idx']);
    if repair1_flag == 1
        out_idx = unique([ 1 out_idx]);
    end

    % Initial deweight list before margins
    outdw_idx = out_idx; 
    % Initial clip list without removing large displacements
    clipout_idx = out_idx;
     

    
    
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% show the output figure
figure('name','GUI to identify outliers','Units', 'normalized', 'Position', [0.2 0.2 0.6 0.7],'Resize','off');
rng = max(g) - min(g);   % was range(g);
pfig = gcf;
% Don't show figure in batch runs
set(pfig,'Visible','off'); 

%             subplot(5,1,1);
%             plot(g);
%             %xlabel(['artifact index list [' int2str(out_idx') ']'], 'FontSize', 8, 'Color','r');
%             %ylabel(['Range = ' num2str(rng)], 'FontSize', 8);
%             ylabel('Global Avg. Signal');
%             xlabel('Red vertical lines are to depair. Green vertical lines are to deweight.');
% 
% 
%             %if ( global_type_flag == 1 ) title('Global Mean - Regular SPM'); end
%             %if ( global_type_flag == 2 ) title('Global Mean - Every Voxel'); end
%             %if ( global_type_flag == 3 ) title('Global Mean - User Defined Mask'); end
%             %if ( global_type_flag == 4 ) title('Global Mean - Generated
%             %ArtifactMask'); end
% 
%             % Add vertical exclusion lines to the global intensity plot
%             axes_lim = get(gca, 'YLim');
%             axes_height = [axes_lim(1) axes_lim(2)];
%             for i = 1:length(outdw_idx)   % Scans to be Deweighted
%                 line((outdw_idx(i)*ones(1, 2)), axes_height, 'Color', 'g');
%             end
%             if GoRepair == 2
%                 for i = 1:length(outdw_idx)   % Scans to be Deweighted
%                     line((outdw_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
%                 end
%             end


subplot(5,1,2);
%thresh_axes = gca;
%set(gca, 'Tag', 'threshaxes');
zscoreA = (g - mean(g))./std(g);  % in case Matlab zscore is not available
plot(abs(zscoreA));
ylabel('Std away from mean');
xlabel('Scan Number  -  horizontal axis');

thresh_x = 1:nscans;
thresh_y = z_thresh*ones(1,nscans);
line(thresh_x, thresh_y, 'Color', 'r');

%  Mark global intensity outlier images with vertical lines
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
for i = 1:length(glout_idx)
    line((glout_idx(i)*ones(1, 2)), axes_height, 'Color', 'r');
end


if realignfile == 1
	subplot(5,1,3);
    xa = [ 1:nscans];
	plot(xa,mv_data(:,1),'b-',xa,mv_data(:,2),'g-',xa,mv_data(:,3),'r-',...
       xa,mv_data(:,4),'r--',xa,mv_data(:,5),'b--',xa,mv_data(:,6),'g--');
    %plot(,'--');
	ylabel('ReAlignment');
	xlabel('Translation (mm) solid lines, Rotation (deg) dashed lines');
	legend('x-motion', 'y-motion', 'z-motion','pitch','roll','yaw',0);
	h = gca;
	set(h,'Ygrid','on');
elseif realignfile == 0
    subplot(5,1,3);
	plot(mv0data(:,1:3));
	ylabel('Alignment (voxels)');
	xlabel('Very approximate Early-Look of translation in voxels.');
	legend('x-motion', 'y-motion', 'z-motion');
	h = gca;
	set(h,'Ygrid','on');
end 



subplot(5,1,4);   % Rapid movement plot
plot(delta);
ylabel('Motion (mm/TR)');
xlabel('Rapid movement between Scans(~mm). Rotation assumes 65 mm from origin');
y_lim = get(gca, 'YLim');
legend('Fast motion',0);
h = gca;
set(h,'Ygrid','on');

thresh_x = 1:nscans;
thresh_y = mv_thresh*ones(1,nscans);
line(thresh_x, thresh_y, 'Color', 'r');
   
% Mark all movement outliers with vertical lines
subplot(5,1,4)
axes_lim = get(gca, 'YLim');
axes_height = [axes_lim(1) axes_lim(2)];
for i = 1:length(mvout_idx)
    line((mvout_idx(i)*ones(1,2)), axes_height, 'Color', 'r');
end

%keyboard;
h_rangetext = uicontrol(gcf, 'Units', 'characters', 'Position', [10 10 18 2],...
        'String', 'StdDev of data is: ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_rangenum = uicontrol(gcf, 'Units', 'characters', 'Position', [29 10 10 2], ...
        'String', num2str(gsigma), 'Style', 'text', ...
        'HorizontalAlignment', 'left',...
        'Tag', 'rangenum',...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshtext = uicontrol(gcf, 'Units', 'characters', 'Position', [25 8 18 2],...
        'String', 'Current std threshold', 'Style', 'text', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshnum = uicontrol(gcf, 'Units', 'characters', 'Position', [44 8 10 2],...
        'String', num2str(z_thresh), 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'threshnum');
h_threshmvtext = uicontrol(gcf, 'Units', 'characters', 'Position', [106 8 18 2],...
        'String', 'Motion threshold  (mm / TR):', 'Style', 'text', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshnummv = uicontrol(gcf, 'Units', 'characters', 'Position', [126 8 10 2],...
        'String', num2str(mv_thresh), 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'threshnummv');
h_threshtextpct = uicontrol(gcf, 'Units', 'characters', 'Position', [66 8 18 2],...
        'String', 'Current (% of mean) threshold ', 'Style', 'text', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0.8 0.8 0.8]);
h_threshnumpct = uicontrol(gcf, 'Units', 'characters', 'Position', [86 8 10 2],...
        'String', num2str(z_thresh*pctmap), 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'threshnumpct');
% h_deweightlist = uicontrol(gcf, 'Units', 'characters', 'Position', [150 6 1 1 ],...
%         'String', int2str(outdw_idx), 'Style', 'text', ...
%         'HorizontalAlignment', 'left', ...
%         'BackgroundColor', [0.8 0.8 0.8],...
%         'Tag', 'deweightlist');
% h_clipmvmtlist = uicontrol(gcf, 'Units', 'characters', 'Position', [152 6 1 1 ],...
%         'String', int2str(clipout_idx), 'Style', 'text', ...
%         'HorizontalAlignment', 'left', ...
%         'BackgroundColor', [0.8 0.8 0.8],...
%         'Tag', 'clipmvmtlist');
h_indextext = uicontrol(gcf, 'Units', 'characters', 'Position', [5 3.25 15 2],...
        'String', 'All outliers  ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'ForegroundColor', 'r');
h_indexedit = uicontrol(gcf, 'Units', 'characters', 'Position', [20 3.25 30 2],...
        'String', int2str(out_idx), 'Style', 'edit', ...
        'HorizontalAlignment', 'left', ...
        'Callback', 'art_outlieredit',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'indexedit');    

h_indextext1 = uicontrol(gcf, 'Units', 'characters', 'Position', [55 3.25 15 2],...
        'String', 'Motion  outliers  ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'ForegroundColor', 'r');
h_indexedit1 = uicontrol(gcf, 'Units', 'characters', 'Position', [72 3.25 30 2],...
        'String', int2str(mvout_idx), 'Style', 'edit', ...
        'HorizontalAlignment', 'left', ...
        'Callback', 'art_outlieredit',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'indexedit');   
    
h_indextext2 = uicontrol(gcf, 'Units', 'characters', 'Position', [105 3.25 15 2],...
        'String', 'Intensity outliers  ', 'Style', 'text', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'ForegroundColor', 'r');
h_indexedit2 = uicontrol(gcf, 'Units', 'characters', 'Position', [120 3.25 30 2],...
        'String', int2str(glout_idx'), 'Style', 'edit', ...
        'HorizontalAlignment', 'left', ...
        'Callback', 'art_outlieredit',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'Tag', 'indexedit');       
    
set(pfig,'Visible','on'); 
tem=deblank(imgs(1,:));
[a,b,c,d]=fileparts(tem);
% saveas(pfig,fullfile(a,'Ref_motion.bmp'))
% fprintf('\n---All are done...\n')
% %%
% % close(pfig)

if nargout~=0
    varargout={out_idx;mvout_idx;glout_idx'}; % three outputs, all the outliers; outliers based on motion; outliers based on intensity
end
