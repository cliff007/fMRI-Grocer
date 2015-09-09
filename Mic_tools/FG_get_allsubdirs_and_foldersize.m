function varargout=FG_get_allsubdirs_and_foldersize(rootdir,file_filter)
if nargin ==0
    rootdir = spm_select(1,'dir','Select the folder you want to lists the files', [],pwd);
    if FG_check_ifempty_return(rootdir), return; end
    
    prompt = {'Specify the file filters(e.g. "*.m", "CBF*")'};
    num_lines = 1;
   % def = {'*.nii'};
    def = {'*.*'};
    dlg_title='filters...';
    aa = inputdlg(prompt,dlg_title,num_lines,def);
    file_filter =aa{1};
end
 
% get the all subfolders
p = FG_genpath(rootdir);


% get the all subfolder size
total=0;
sum_record=[];
for i=1:size(p,1)
    b_sum=0;
%   disp(deblank(p(i,:)))
    tem=fullfile(deblank(p(i,:)),file_filter);
    d=dir(tem);
    for j=1:length(d)
        b_sum=b_sum+d(j).bytes;
    end
    if isempty(b_sum) % this is a special case in which we can't get the file size like named as "综述? 阿尔茨海默病的治疗现状与进展.pdf"
        uiwait(msgbox(['Something wrong in ---', deblank(p(i,:)), '--- We can not read the file size! Use NaN instead!'],'Hi...','error','modal'))
        b_sum=NaN;
    end
    sum_record=[sum_record;b_sum];
%   disp(['Size: ' num2str(b_sum)])
    total=total+b_sum  ;
end
%   disp(['The Total Sum is: ' num2str(total)])


% get the accumulated folder size
total_sum=sum_record;
    % get all the filesep number first, this can be used to check the whether the foders are nested
    filesep_n=[];
    for i=1:size(p,1)
        tem=regexp(deblank(p(i,:)),regexptranslate('escape',filesep));
        if ~isempty(tem)
            filesep_n=[filesep_n;length(find(tem))];
        else
            filesep_n=[filesep_n;0];
        end
    end

% search from the first one which is the root folder level, accumulate
% foder size
if size(p,1)>200
    fprintf('--------------Too many folders (totally %d),please wait....\n',size(p,1))
else
    fprintf('--------------Listing....\n')
end
for i=1:size(p,1)
    for j=(i+1):size(p,1)
        tem=regexp(deblank(p(j,:)),regexptranslate('escape',deblank(p(i,:))), 'once');
        if ~isempty(tem) && filesep_n(j)> filesep_n(i)  % make sure they are nested other than at the same foder level
            total_sum(i)=total_sum(i)+total_sum(j);
        else
            continue  % in this situation, continue to the next one
        end
    end
end

if nargout==0
    allfolders=p
    foldersizes=total_sum
end
    

if nargout==2
    varargout(1)= {p};
    varargout(2)= {total_sum};
elseif nargout==3
    varargout(1)= {p};  % all subfolders
    varargout(2)= {total_sum};  % accumulated folder size (which  include its subfolder size)
    varargout(3)= {sum_record};   %  indepent folder size (which  doesn't include its subfolder size)
end


fprintf('--------------done------------------\n')

