function Vec=FG_combine_two_str_vectors(vec1,vec2)
if size(vec1,1)~=size(vec2,1)
    fprintf('\nThe length of the vectors must be the same.\n')
    return
end

if size(vec1,1)<1
    fprintf('\nThe length of the vectors must be bigger than 1.\n')
    return
end

Vec=[];

for i=1:size(vec1,1)
    Vec=strvcat(Vec,[deblank(vec1(i,:)),deblank(vec2(i,:))]);
end