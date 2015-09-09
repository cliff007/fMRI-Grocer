function y=FG_roundn(p,n)
% y=FG_roundn(p,n)
% p can be sigle value or a vector
% n is the digits of the values after the decimal point you want to keep
y=round(10^n*p)/10^n ;