function y=FG_num_mode(p) 
% p should be a column vector or row vector
p=p(:);
p=FG_roundn(p,1) ; % keep only 1 digit after the dot
k=sort(unique(p));
if (length(k)==1)
   y=p(1);
else
   B=hist(p,k);
   L=max(B);
   y=k(L==B);
end