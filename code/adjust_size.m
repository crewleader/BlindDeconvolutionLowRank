function target=adjust_size(source,size_diff,method)

if nargin<3
	method=0;
end

if length(size_diff)==1
	size_diff=[size_diff size_diff];
end

target=source;

if size_diff(1)>0
	target=padarray(target,[size_diff(1)/2 0],method,'pre');
	target=padarray(target,[size_diff(1)/2 0],method,'post');
elseif size_diff(1)<0
	target=target(1-size_diff(1)/2:end+size_diff(1)/2,:);
end

if size_diff(2)>0
	target=padarray(target,[0 size_diff(2)/2],method,'pre');
	target=padarray(target,[0 size_diff(2)/2],method,'post');
elseif size_diff(2)<0
	target=target(:,1-size_diff(2)/2:end+size_diff(2)/2);
end