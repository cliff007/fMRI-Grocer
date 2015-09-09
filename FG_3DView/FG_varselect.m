function Output_VarValue=FG_varselect
clc
% close all the existed figure that has been created by this script before
FigH_old = findobj( 'Type', 'figure', 'Tag', 'Varsselect' ) ;
if ishandle( FigH_old )
    close( FigH_old ) ;
end

% create a new figure
FigH = figure ;
scnsize=get(0,'screensize');
FG_font=10*sqrt(scnsize(3)*scnsize(4)/(1024*768));
set(FigH,'units','normalized','position',[0.5 0.35 0.3 0.2],...
    'menubar','none','name','Select the variables in the list','resize','off',...
    'numbertitle','off','color',[0.925 0.914 0.847],'tag','Varsselect');

% read and show a logo
    a=which('FG_varselect');
    [b,c,d,e]=fileparts(a);
    tubiao = imread([b filesep 'grocer.jpg']);    
    uicontrol(FigH,'style','radiobutton','units','normalized',...
        'pos',[0.025 0.3 0.265 0.48],'string','',...
        'cdata',tubiao,'bac',[0.925 0.914 0.847])

uicontrol(FigH,'style','text','units','normalized',...
    'pos',[0.475 0.73 0.35 0.15],'string','Select a variable',...
    'fontsize',FG_font,'fontweight','bold','fontunits','normalized')

s=evalin('base','whos');
Varsname=char(s.name);
if isempty(Varsname)
    Varsname='None variable in current base space'; % judge whether there is a var
    
    % invaild below rows because we just need to offer all the variables in
    % the workspace, rather than filtering variable types and dimentions
    
%         else
%             Varsclass=char(s.class);
%             Varssize=[];
%             Varsclasslog=[];
%             k=size(s,1);
%             for i=1:k
%                 Varssize(i,:)=s(i).size;
%                 Varsclasslog(i,:)=strncmpi(Varsclass(i,:),'double',6);
%             end
%             Varssize=min(Varssize')';
%             Varsname=Varsname(Varssize==1 & Varsclasslog,:);
%             if isempty(Varsname)
%                 Varsname='None variable in current base space';
%             end


end
setappdata(gcf,'Varsname',Varsname);

uicontrol(FigH,'style','popupmenu','units','normalized','pos',[0.35 0.33 0.59 0.337],'string',...
    Varsname,'fontsize',FG_font,'fontunits','normalized',...
    'backgroundcolor',[1 1 1],'tag','Vars_name','value',1)

% when you select a one variable and click OK to continue
uicontrol(FigH,'style','push','units','normalized','pos',[0.3 0.2 0.1 0.21],'string','OK',...
    'fontsize',FG_font,'fontweight','bold','fontunits','normalized','callback',...
    ['handles1=guidata(gcf);',...
    'value=get(handles1.Vars_name,''value'');'...
    'Varsname=getappdata(gcf,''Varsname'');'...
    'if ~strcmp(Varsname,''None variable in current base space'');'...
        'bs = Varsname(value,:);'...
        'Output_VarValue=eval(bs);'...
        'set(gcf,''userdata'',Output_VarValue);'...
    'end;'...
    'uiresume(gcbf);'...
    'evalin(''base'',''clear value Varsname bs handles1 Output_VarValue'');'])

% when you want to continue ignoring the variable you have selected, i.e.,
% just want to exit
uicontrol(FigH,'style','push','units','normalized','pos',[0.42 0.2 0.15 0.21],'string','Exit',...
    'fontsize',FG_font,'fontweight','bold','fontunits','normalized','callback',...
    ['set(gcf,''userdata'',[]);'...
    'uiresume(gcbf);'...
    'fprintf(''--Nothing output!'');evalin(''base'',''clear value Varsname bs handles1 Output_VarValue'');'])

% can't find a variable in the list
uicontrol(FigH,'style','push','units','normalized','pos',[0.59 0.2 0.4 0.21],'string','I Can''t find it',...
    'fontsize',FG_font,'fontweight','bold','fontunits','normalized','callback',@nofound)

handles1=guihandles(gcf);
guidata(gcf,handles1);

uiwait(gcf);
Output_VarValue=get(gcf,'userdata');
delete(gcf);

%% subfunction
function nofound(hobj,ed)  % while "ed" is just an unused variable for the function handle purpose
   set(gcf,'userdata',[]);
    uiresume(gcbf);
    fprintf(['\n========Solution 1=======\nThis maybe you want to draw some variable of another function in debuging mode!\n' ...
        'Please use: \n\n     assignin(''base'',''varname_output_to_base'',varname_in_function)\n\nfunction to assign' ...
        'the variables in that function workspace into the base workspace first!\nAnd then come back to do this again!\n\n']);
    
    
    fprintf(['\n=========Solution 2======\nOr Type ''FG_view3d_variable'' in the matlab command window to call this function...\n\n']);
    
   evalin('base','clear value Varsname bs handles1 Output_VarValue');
