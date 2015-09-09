function FG_imgHistogram
%% this script based on SPM2/5/8	

clc
a=findobj('Tag','as_FG_hist');
if ~isempty(a)
    h=questdlg('Do you want to close all the figures has opened by me before?','Close all or not...','Yes','No','Yes');
    if strcmp(h,'Yes')
        % close all
        close (findobj('Tag','as_FG_hist'));
        clear a
    end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % start 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % selcet the gray-matter img
 % [the gray-matter img's voxel size & img dimention should be the same as the cbf imgs that will be selected later]
  % selcet the cbf imgs that will be masked by the selceted gray-matter mask
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       Filename = spm_select(inf,'any','Select the images to be read', [],pwd,'.*img$|.*nii$');
  else  
       Filename = spm_get(inf,'any','Select the images to be read'); 
  end

  if isempty(Filename)
      return
  end
   num=size(Filename,1);
   
  if strcmp(spm('ver',[],1),'SPM5')||strcmp(spm('ver',[],1),'SPM8')
       mask = spm_select(inf,'any','Select one or more same dimentions mask imgs, or skip this step~', [],pwd,'.*img$|.*nii$');
  else  
       mask = spm_get(inf,'any','Select  or more same dimentions mask imgs, or skip this step~'); 
  end
  
 if ~isempty(mask) 
    n_mask=size(mask,1);
 else
    n_mask=1;  % if no mask is selected, default is a whole brain mask
 end
  
  h_op=questdlg('Do you want to specify the x-axis ranger or bins right now, or you can click ''No'' to let it use the real value range within the ROI','Hi...','Yes','No','Yes');
 if strcmp(h_op,'Yes')    
    prompt = {'Enter the x-axis bins(e.g. 100) or the exact value range of the x-axis you want(e.g. -10:1:60)'};
     num_lines = 1;
     def = {'20:5:100'};
     dlg_title = ['x-bins specification'];
     bins = inputdlg(prompt,dlg_title,num_lines,def); 
     bins=eval(bins{1});
 end
 
h_extra=questdlg('Do you want to get some more potential useful info. about this histogram (e.g.percentile value) after showing the histogram?','Hi...','Yes','No','Yes');  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % files selcet   % end %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xls_col=FG_excel_column_gen(ceil((n_mask*num)/26));

for k=1:num 
    
    V=spm_vol(deblank(Filename(k,:)));
    dat = spm_read_vols(V);   % read the img
    [pathstr, name, ext, versn]=fileparts(Filename(k,:));
    
    for p=1:n_mask
       
        if isempty(mask)
            dat1=ones(size(dat)); % that means no mask is used
            name1='no mask';
        else        
            V1=spm_vol(deblank(mask(p,:)));
            dat1 = logical(spm_read_vols(V1));   % read the mask img  
            [pathstr1, name1, ext1, versn1]=fileparts(deblank(mask(p,:)));
        end

        masked_img=dat.*dat1;

        within_mask_vaild_values=[];
        within_mask_vaild_values=masked_img(find(dat1~=0));
        within_mask_vaild_values=within_mask_vaild_values(find(~isnan(within_mask_vaild_values)));


        h=figure('name',[name ' -Masked-By- ' name1]);
        set(h,'Tag','as_FG_hist'); 

        if strcmp(h_op,'No')  
            bins=unique(within_mask_vaild_values);
        end

        if length(bins)==1 % a number
            hist(within_mask_vaild_values,bins); % show all the values that is Non-Nan within the mask (include all vaild '0's if there is some) 
        elseif length(bins)>1 % a vector, then filter out the values out of this range
            within_mask_vaild_values=within_mask_vaild_values(find(within_mask_vaild_values>=bins(1)));
            within_mask_vaild_values=within_mask_vaild_values(find(within_mask_vaild_values<=bins(end)));
            hist(within_mask_vaild_values,bins);
        end

        ylabel(['Accumulation values in No.' num2str(k) ' Img']);
        xlabel('Voxel values');
        h_H = findobj(gca,'Type','patch');
        set(h_H,'FaceColor','r','EdgeColor','w') 

        % reset the figure position  --start              
            a=get(h,'Position');
            b=get(0,'ScreenSize') ;                
            if size(Filename,1)>1
                if (b(3)/size(Filename,1))<a(3)
                    set(h,'Position',[(k-1)*b(3)/size(Filename,1) a(2) b(3)/size(Filename,1) a(4)])
                else
                    set(h,'Position',[(k-1)*a(3) a(2) a(3) a(4)])
                end
            end
        % reset the figure position  --done

            tem=within_mask_vaild_values; 
            mode_n=FG_num_mode(tem); % maybe more than one "mode" value
            fprintf('\n\n\n ------- Statistic info. of image %s masked by %s ----------------------\n',name,name1)  ;
            for i=1:size(mode_n,1)
                fprintf('\n the mode value within this mask is %s \n',num2str(mode_n(i)))  ;  % function "mode" can be used only after Matlab2011
            end
            fprintf('\n the mean value within this mask is %s \n',num2str(mean(tem)))  ;
            fprintf('\n the median value within this mask is %s \n',num2str(median(tem)))  ;
            fprintf('\n the value range within this mask is [%s ~ %s]\n',num2str(min(tem)),num2str(max(tem)))  ; 
            
            if k==1 && p==1
                out_txt_name='Grocer_imghist_output_readme.txt';
                out_name='Grocer_imghist_output.csv';
                out_vars=[];
                dlmwrite(out_txt_name, '------------the data info within the "Grocer_imghist_output.csv"------------------- ', 'delimiter', '','newline','pc');
                dlmwrite(out_txt_name, char({'mode';'mean';'median';'min';'max'}), '-append','delimiter', '','newline','pc'); 
                dlmwrite(out_txt_name, '-------the columns is corresponding to the following files:', '-append','delimiter', '','newline','pc'); 
            end
            dlmwrite(out_txt_name, [deblank(name),'-maskedby-',deblank(name1)],'-append', 'delimiter', '','newline','pc');
            out_vars_tem=[];
            for i=1:length(mode_n)
                out_vars_tem=[out_vars_tem;mode_n(i)];
            end 
            filler=[NaN; NaN; NaN; NaN; ];
            out_vars_tem=[out_vars_tem; filler;mean(tem);filler; median(tem);filler; min(tem);filler;max(tem)];
            
            % dealing with the output variable's length
            if ~isempty(out_vars) && size(out_vars,1)~=size(out_vars_tem,1)
                row_n=size(out_vars,1)-size(out_vars_tem,1);
                if row_n<0
                    out_vars=FG_insertrows(out_vars,nan(abs(row_n),size(out_vars,2)),0);
                elseif row_n>0
                    out_vars_tem=FG_insertrows(out_vars_tem,nan(abs(row_n),1),0 );
                end
            end
            out_vars=[out_vars,out_vars_tem];
            
%             out_vars={[deblank(name),'-maskedby-',deblank(name1)],'mode',num2str(mode_n),'mean', ...
%                 num2str(mean(tem)),'median',num2str(median(tem)),'min',num2str(num2str(min(tem))),'max',num2str(num2str(max(tem)))}'       ;
% 
%             out_vars=[{[deblank(name),'-maskedby-',deblank(name1)]},'mode',num2str(mode_n),'mean', ...
%                 num2str(mean(tem)),'median',num2str(median(tem)),'min',num2str(num2str(min(tem))),'max',num2str(num2str(max(tem)))]'       ;
            % write into .csv file
%             out_vars=char(out_vars);                    
            
       %%=====================Supplement output================     
        
        if strcmp(h_extra,'Yes')          

           h_s1=questdlg('Do you want to search a percentile?','Hi...','Yes','No','Yes');
           if strcmp(h_s1,'Yes')
               value=inputdlg('Enter a percentage value to search the smallest/biggest percentile-value:','Hi...',1,{'0.1'}) ;
               percent_value=str2num(value{1});

               sorted_tem=sort(tem,'descend');
               fprintf('\n the %1.2d-Percentate percentile-value is %s \n',percent_value*100,num2str(sorted_tem(floor(length(tem)*percent_value))))

               sorted_tem=sort(tem,'ascend');
               fprintf('\n the %1.2d-Percentate percentile-value is %s \n--------------\n',(1-percent_value)*100,num2str(sorted_tem(floor(length(tem)*percent_value))))   
           end

       % you can also give a value to find the nearest value's position in the soreted_tem
           h_s2=questdlg('Do you want to enter a value to search its percentage position?','Hi...','Yes','No','Yes');
           if strcmp(h_s2,'Yes')                   
                in_num=inputdlg('Enter a value you want to search its percentage position:','Hi...',1,{'60'}) ;
                sorted_tem=sort(tem,'ascend');
                tem1=min(abs(sorted_tem-str2num(in_num{1})));
                pos=find((abs(sorted_tem-str2num(in_num{1})))==tem1,1,'first');
                fprintf('\n Value %s is at the first %s percentage position!\n--------------\n',in_num{1},num2str(pos/length(tem)*100))   
           end    
        end
    end
end

            csvwrite(out_name, out_vars)
            fprintf('\n -------the output file is :\n         %s \n',[pwd,filesep,out_name])
