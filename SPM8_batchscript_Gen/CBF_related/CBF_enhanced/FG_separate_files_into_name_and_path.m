function [pathes, names,new_names,new_full_names]=FG_separate_files_into_name_and_path(fun_imgs,fix,judge,varargin)
% the input "fun_imgs" should be a char array or a cell array

if nargin==0
  fun_imgs=spm_select(inf,'any','Select all the fun_imgs of one subject', [],pwd,'.*');  
  fix='';
  judge='prefix';  % or 'suffix'
elseif nargin==1
  fix='';
  judge='prefix';  % or 'suffix'  
elseif nargin==2
  judge='prefix';  % or 'suffix'     
end

if nargin==4
    new_ext=varargin{1}; % for extention replacement, varargin should like ".nii" , ".img"
end

if iscell(fun_imgs), fun_imgs=char(fun_imgs); end
if FG_check_ifempty_return(fun_imgs) ,fun_imgs='return';  return; end

pathes=[];
names=[];
new_names=[];
new_full_names=[];

for i=1:size(fun_imgs,1)
    [a,b,c,d]=fileparts(fun_imgs(i,:));
    if exist('new_ext','var')
        c=new_ext;
    end
    
    pathes{i}=a;
    names{i}=[b c]; 
    if strcmpi(judge,'prefix')
        new_names{i}=[fix b c];
        new_full_names{i}=fullfile(a,new_names{i});       
    elseif strcmpi(judge,'subfix')
        new_names{i}=[b fix c];
        new_full_names{i}=fullfile(a,new_names{i});
    end
end
new_names=char(new_names);

% new_full_names=cat(2,char(pathes),new_names); % now a cell array again

if ischar(fun_imgs), pathes=char(pathes); names=char(names);new_names=char(new_names); new_full_names=char(new_full_names);end
