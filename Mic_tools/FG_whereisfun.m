function path=FG_whereisfun(fun_name)
tem=which(fun_name);
[path,fun,fix,d]=fileparts(tem);