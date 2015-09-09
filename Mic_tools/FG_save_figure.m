function FG_save_figure(name,handle)

% way 1: save as
saveas() ;  % it use 'print' command inside
            % saveas(gca,filename,fileformat)

% way 2: print
````````````% print(dformat,rnum,fname)
            % print函数必须紧跟在plot函数之后使用

% way 3: getframe
a=getframe(handle) ;
% a=getframe(gca/gcf) ;
imwrite(a,name)


% 如果想要图片不显示而直接保存
set(figure(1),'visible','off');

