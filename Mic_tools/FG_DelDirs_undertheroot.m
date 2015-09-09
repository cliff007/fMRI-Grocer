function FG_DelDirs_undertheroot(root,filter)
% filter = '*filter*';
if nargin~=2
   root=spm_select(1,'dir','Please select a root folder...');
   if isempty(root), return,end
   filter=inputdlg('Please enter the foder filter (e.g. *filter*, *filter, etc.)','Hi...',1,{'*'});
   filter=filter{1};
end
all=dir(fullfile(root,filter));
for i=1:size(all,1)
    try
        FG_DelDir(all(i).name)
    catch me
       disp(me.message)
       fprintf(['--is ''' all(i).name ''' a foder? \n'])
       
    end
end