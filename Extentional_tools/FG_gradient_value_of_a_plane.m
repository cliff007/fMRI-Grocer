function varargout=FG_gradient_value_of_a_plane(V,nbins,varargin)
% output variables
%      1   line_xy_y
%      2   line_xy_x
%      3   line_yz_z
%      4   line_yz_y
%      5   line_xz_z
%      6   line_xz_x
% varargin can be x, y, z
if nargin<1
    img=spm_select(inf,'image','Select a image...');
    V=FG_read_vols(img);
    nbins=0;
    start_percentage=0.5;
elseif nargin<2 
    retrun
elseif nargin==2
    start_percentage=0.5;  %   default start_percentage=0.5, i.e. at the center of the plane
elseif nargin==3
    start_percentage=varargin{1};
end

[ Nx, Ny, Nz ] = size(V);
out={};

%% demo of SPM display
%             |------------|   |--------------------|   
%             |   cronoal  |   |      sagital       | 
%             |     xz     z   |         yz         z 
%             |            |   |                    | 
%             |---- x -----|   |-------- y ---------|  
% 
%             |------------| 
%             |            | 
%             |            | 
%             |    axial   y 
%             |     xy     | 
%             |            | 
%             |----  x ----|


% for j=1:6
%     plane=varargin{j};
%     switch plane
%         case 'xy-y' % the middle x of xy-plane
            x=round( start_percentage * Nx); z=round( start_percentage * Nz);
            line_xy_y = squeeze(V(x-nbins:x+nbins,:,z));  
            if nbins>0
                line_xy_y = mean(line_xy_y,1)'; 
            end
            out=[out;line_xy_y];
%         case 'xy-x' % the middle y of xy-plane
            y=round( start_percentage * Ny); z=round( start_percentage * Nz);
            line_xy_x = squeeze(V(:,y-nbins:y+nbins,z));  
            if nbins>0
                line_xy_x = mean(line_xy_x,2);
            end
            out=[out;line_xy_x];
%         case 'yz-z' % the middle y of yz-plane
            x=round( start_percentage * Nx); y=round( start_percentage * Ny); 
            line_yz_z = squeeze(V(x,y-nbins:y+nbins,:));
            if nbins>0
                line_yz_z= mean(line_yz_z,1)';  
            end
            out=[out;line_yz_z];
%         case 'yz-y' % the middle z of yz-plane
            x=round( start_percentage * Nx); z=round( start_percentage * Nz);
            line_yz_y = squeeze(V(x,:,z-nbins:z+nbins));
            if nbins>0
                line_yz_y = mean(line_yz_y,2);  
            end
            out=[out;line_yz_y]; 
%         case 'xz-z' % the middle z of xz-plane
            x=round( start_percentage * Nx); y=round( start_percentage * Ny);
            line_xz_z = squeeze(V(x-nbins:x+nbins,y,:));  
            if nbins>0
                line_xz_z = mean(line_xz_z,1)';  
            end
            out=[out;line_xz_z];
%         case 'xz-x' % the middle x of xz-plane
            y=round( start_percentage * Ny); z=round( start_percentage * Nz);
            line_xz_x = squeeze(V(:,y,z-nbins:z+nbins));  
            if nbins>0
                line_xz_x = mean(line_xz_x,2);  
            end
            out=[out;line_xz_x];
%     end    
% end

if nargout==1
    varargout=out;
end

%%% show the output figure
figure('name','Mid-plane values','Units', 'normalized', 'Position', [0.2 0.2 0.6 0.7],'Resize','on');
pfig = gcf;
% Don't show figure in batch runs
set(pfig,'Visible','off'); 

subplot(6,1,1);
plot(1:Nx,line_xy_x');
xlabel('x');
ylabel('xy-x value');
set(gca,'XTick',1:2:Nx);
ylim([min(line_xy_x) max(line_xy_x)+1]*1.05)
grid(gca,'on') 

subplot(6,1,2);
plot(1:Ny,line_xy_y');
xlabel('y');
ylabel('xy-y value');
set(gca,'XTick',1:2:Ny);
ylim([min(line_xy_y) max(line_xy_y)+1]*1.05)
grid(gca,'on') 

subplot(6,1,3);
plot(1:Nz,line_yz_z');
xlabel('z');
ylabel('yz-z value');
set(gca,'XTick',1:2:Nz);
ylim([min(line_yz_z) max(line_yz_z)+1]*1.05)
grid(gca,'on') 

subplot(6,1,4);
plot(1:Ny,line_yz_y');
xlabel('y');
ylabel('yz-y value');
set(gca,'XTick',1:2:Ny);
ylim([min(line_yz_y) max(line_yz_y)+1]*1.05)
grid(gca,'on') 

subplot(6,1,5);
plot(1:Nx,line_xz_x');
xlabel('x');
ylabel('xz-x value');
grid on;
set(gca,'XTick',1:2:Nx);
ylim([min(line_xz_x) max(line_xz_x)+1]*1.05)
grid(gca,'on') 


subplot(6,1,6);
plot(1:Nz,line_xz_z');
xlabel('z');
ylabel('xz-z value');
set(gca,'XTick',1:2:Nz);
ylim([min(line_xz_z) max(line_xz_z)+1]*1.05)
grid(gca,'on') 
        
set(pfig,'Visible','on'); 
saveas(pfig,fullfile(pwd,'Ref_motion.bmp'))
%%
%     close(pfig)
