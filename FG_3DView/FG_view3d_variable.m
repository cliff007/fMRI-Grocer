function FG_view3d_variable
%   
%     dlg_prompt={'Enter the 3D variable name in Matlab Workspace:   '};
%     dlg_name='3D variable...';
%     dlg_def={'dat'};
%     Ans=inputdlg(dlg_prompt,dlg_name,1,dlg_def); 
%      V_3d=Ans{1}  
   
    
    V_3d=FG_varselect;
    if ~isempty(V_3d) & isa(V_3d,'double')
        imlook3d(V_3d);   
  %  clear dlg_prompt dlg_name dlg_def Ans V_3d a3d
    elseif ~isempty(V_3d)  & ~isa(V_3d,'double')
        fprintf('\n-------Your selected variable is not a double precision variable!\n')
    end
