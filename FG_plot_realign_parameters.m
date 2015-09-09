function FG_plot_realign_parameters(files)

    if ~exist('files','var')
        files= spm_select(inf,'.txt','Select a rp_*.txt file', [],pwd,'.*txt');
        if isempty(files),return;  end 

        dlg_prompt={'Specify the threshold of the translation (mm)';'Specify the threshold of the rotation (degree)'};
        dlg_name='(Hi...)';
        dlg_def={'3', '3'};
        thre=inputdlg(dlg_prompt,dlg_name,1,dlg_def,'on');   
        thre1=str2num(thre{1});
        thre2=str2num(thre{2}); 
    end
    

    % display results
    % translation and rotation over time series
    %-------------------------------------------------------------------    
    
   for i_file=1:size(files,1) 
        file=deblank(files(i_file,:));
%         [a,b_name,c,d]=fileparts(file);
        fid = fopen(file, 'r'); 
%         Params = textscan(fid, '%f %f %f %f %f %f %*[^\n]');
%         Params = cell2mat(Params);
          Params=spm_load(file);
        
        fg=spm_figure('Create','rp','Graphics','on');

        ax=axes('Position',[0.1 0.35 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
        plot(Params(:,1:3),'Parent',ax)
        s = ['x translation';'y translation';'z translation'];
        %text([2 2 2], Params(2, 1:3), s, 'Fontsize',10,'Parent',ax)
        legend(ax, s, 0)
        set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
        set(get(ax,'Xlabel'),'String','image');
        set(get(ax,'Ylabel'),'String','mm');

        ax=axes('Position',[0.1 0.05 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
        plot(Params(:,4:6)*180/pi,'Parent',ax)
        s = ['pitch';'roll ';'yaw  '];
        %text([2 2 2], Params(2, 4:6)*180/pi, s, 'Fontsize',10,'Parent',ax)
        legend(ax, s, 0)
        set(get(ax,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
        set(get(ax,'Xlabel'),'String','image');
        set(get(ax,'Ylabel'),'String','degrees');

        % find out the volumes that abs(translation)>=3mm, abs(rotation)>=3
        % degree    
            tem1=[]; tem2=[];pos_tem1=[];pos_tem2=[];
            tem1=Params(:,1:3); tem1_1=Params(:,1);tem1_2=Params(:,2);tem1_3=Params(:,3);
            tem2=Params(:,4:6); tem2_1=Params(:,4);tem2_2=Params(:,5);tem2_3=Params(:,6);   
            pos_tem1=zeros(size(tem1)); % set a original position matrix
            pos_tem2=zeros(size(tem1));
            t=zeros(size(tem1,1),1);
            
            for i=1:size(tem1,2)
                t1=tem1(:,i)>=thre1;
                t2=tem1(:,i)<=-thre1;
                t=t1+t2; 
                pos_tem1(:,i)=t;
            end

            for i=1:size(tem2,2)
                t1=tem2(:,i)>=thre2;
                t2=tem2(:,i)<=-thre2;
                t=t1+t2; 
                pos_tem2(:,i)=t;
            end   
            
            fprintf('\nFor the #%d motion-paramater file    "%s"',i_file,file) ;
            fprintf('\nThe Volume-No. that x-translation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem1(:,1)==1)), repmat('    ',size(find(pos_tem1(:,1)==1))), num2str(tem1_1(find(pos_tem1(:,1)==1)))]
            fprintf('\nThe Volume-No. that y-translation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem1(:,2)==1)), repmat('    ',size(find(pos_tem1(:,2)==1))), num2str(tem1_2(find(pos_tem1(:,2)==1)))]   
            fprintf('\nThe Volume-No. that z-translation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem1(:,3)==1)), repmat('    ',size(find(pos_tem1(:,3)==1))), num2str(tem1_3(find(pos_tem1(:,3)==1)))]  

            fprintf('\nThe Volume-No. that x-rotation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem2(:,1)==1)), repmat('    ',size(find(pos_tem2(:,1)==1))), num2str(tem2_1(find(pos_tem2(:,1)==1)))]  
            fprintf('\nThe Volume-No. that y-rotation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem2(:,2)==1)), repmat('    ',size(find(pos_tem2(:,2)==1))), num2str(tem2_2(find(pos_tem2(:,2)==1)))] 
            fprintf('\nThe Volume-No. that z-rotation bigger than  the threshold and their corrsponding values are:')
            [num2str(find(pos_tem2(:,3)==1)), repmat('    ',size(find(pos_tem2(:,3)==1))), num2str(tem2_3(find(pos_tem2(:,3)==1)))]   

   end
   
%     % print realigment parameters
%     spm_print
