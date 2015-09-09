function any_retrun=FG_modules_selection(def_prom_root,def_prom_groups,def_folderfilter,def_filefilter, varargin)
% % %  Caution: 'varargin' can be placed behind the specific variables like
% % %  above, you can't put in like this (varargin, def_prom_root,def_prom_groups)
% % %  to make it work. In this way, 'varargin' will be treated as only one specific variable. 
        % root ----  r
        % group ----  g
        % folder ----  fo
        % file ----  fi
        % mean ----  me
        % T1 ----  t
        % slice ---- s  
        % mask ---- ma 
        % T1_sn ---- sn
        % def_prom_root ---- promotion of the root-selection module
        % def_prom_groups ----  promotion of the group-selection module  
        % def_folderfilter ----  default folder filter of the subj-foder selection module 
        % def_filefilter ---- default file filter of the subj-file selection module  
  % FG_modules_selection('','','','', varargin)     
  % FG_modules_selection('Select a root folder','','','^sr.*img$', varargin)  
  % [varargout]=FG_modules_selection('','','','','r','g','fo','fi','m','t','sn','mask','s') -- the full mode.    
if nargin < 5  % at least 5 input required
    clc
    fprintf('\n\tWarning: You need to specify what module(s) do you want to choose~~\n\n')
%     
    return
end

%% deal with the "varargin" %%%%%%%%%%%%%%%%%%
        j=0;
        input_checklist={'r';'g';'fo';'fi';'me';'t';'s';'ma';'sn'};  
        for i=1:nargin-4 % <==> i = 1: length(varargin);  % total input-variable number = length(varargin) + 2
            % check the inputlist first
            if ~any(strcmp(varargin{i},input_checklist))  % compare to function 'all'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%  refer to the function:  'inputname'
               fprintf('\n---Warning: I didn''t recognize what does ''%s'' mean!! Check it out please!\n',varargin{i}) 
               j=j+1;
               continue
            end
        end
            % if... break the function
            if j~=0
%                 
                return
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the necessary variables
opts=FG_module_settings_of_questdlg;
assignin('caller','opts',opts);
%%%%%%%%

any_retrun=0;
%% module selection
for i=1:nargin-4 % <==> i = 1: length(varargin);  % total input-variable number = length(varargin) + 4
    % check the inputlist first
    switch varargin{i}
        case 'r' % root
            if isempty(def_prom_root)  % deal with the input-variable "def_prom_root" 
                root_dir = FG_module_select_root;
            else
                root_dir = FG_module_select_root(def_prom_root);
            end
            if any(strcmpi('return',{root_dir})), any_retrun=any_retrun+1; return; end
         %   if FG_check_ifempty_return(root_dir),  return; end;            
            assignin('caller','root_dir',root_dir);
        case 'g' % group
            if isempty(def_prom_groups)  % deal with the input-variable "def_prom_groups"
                groups = FG_module_select_groups;
            else
                groups = FG_module_select_groups(def_prom_groups);
            end 
            if any(strcmpi('return',{groups})),  any_retrun=any_retrun+1;return; end
       %     if FG_check_ifempty_return(root_dir),  return; end
            assignin('caller','groups',groups) ;
        case 'fo' % folder
            if isempty(def_folderfilter) 
                [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,'*');
            else
                [h_folder,dirs_tem,folder_filter]=FG_module_select_subjects_undergroups(groups,opts,def_folderfilter);
            end
            if any(strcmpi('return',{h_folder,dirs_tem,folder_filter})), any_retrun=any_retrun+1; return; end
         %   if FG_check_ifempty_return(h_folder,dirs_tem,folder_filter),  return; end
           assignin('caller','h_folder', h_folder) ;
           assignin('caller','dirs_tem', dirs_tem) ;
           assignin('caller','folder_filter', folder_filter) ;           
        case 'fi' % file
            if isempty(def_filefilter) 
                [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,'^sr.*img$|^sr.*nii$');
            else
                [h_files,fun_imgs,file_filter]=FG_module_select_files_undersubjects(groups,opts,def_filefilter);
            end
            if any(strcmpi('return',{h_files,fun_imgs,file_filter})), any_retrun=any_retrun+1; return; end
         %   if FG_check_ifempty_return(fun_imgs),  return; end           
            assignin('caller','h_files', h_files) ;
            assignin('caller','fun_imgs', fun_imgs);
            assignin('caller','file_filter', file_filter) ;
        case 'me'  % mean
            [h_mean,mean_fun_imgs_tem,mean_file_filter]=FG_module_select_mean_Img(groups,opts,'^mean.*img$|^mean.*nii$');
            if any(strcmpi('return',{h_mean,mean_fun_imgs_tem,mean_file_filter})), any_retrun=any_retrun+1; return; end
           % if FG_check_ifempty_return(mean_fun_imgs),  return; end            
            assignin('caller','h_mean', h_mean);
            assignin('caller','mean_fun_imgs_tem', mean_fun_imgs_tem);
            assignin('caller','mean_file_filter', mean_file_filter);
            
        case 't' % T1
            [h_t1,t1_imgs_tem]=FG_module_select_T1_Img(groups,opts);
            if any(strcmpi('return',{h_t1,t1_imgs_tem})), any_retrun=any_retrun+1; return; end
          %  if FG_check_ifempty_return(t1_imgs_tem),  return; end
            assignin('caller','h_t1', h_t1);
            assignin('caller','t1_imgs_tem', t1_imgs_tem);
        case 's' % slice timing
            [h_SLTiming,Ans]=FG_module_select_slicetiming_paras(groups,opts);
            if any(strcmpi('return',{h_SLTiming,Ans})), any_retrun=any_retrun+1; return; end
            %  if FG_check_ifempty_return(Ans),  return; end
            assignin('caller','h_SLTiming', h_SLTiming);
            assignin('caller','Ans', Ans);
        case 'sn' % T1_sn
            [h_t1_sn,t1_imgs_sn_tem]=FG_module_select_T1_sn_file(groups,opts);
            if any(strcmpi('return',{h_t1_sn,t1_imgs_sn_tem})), any_retrun=any_retrun+1; return; end
         %   if FG_check_ifempty_return(t1_imgs_sn_tem),  return; end
            assignin('caller','h_t1_sn', h_t1_sn);
            assignin('caller','t1_imgs_sn_tem', t1_imgs_sn_tem);
        case 'ma' % mask
            [h_mask,mask_imgs_tem]=FG_module_select_masks(groups,opts) ; 
            if any(strcmpi('return',{h_mask,mask_imgs_tem})), any_retrun=any_retrun+1; return; end
        %    if FG_check_ifempty_return(mask_imgs_tem),  return; end
            assignin('caller','h_mask', h_mask);
            assignin('caller','mask_imgs_tem', mask_imgs_tem);
    end
end
    

