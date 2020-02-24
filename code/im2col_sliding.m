function B=im2col_sliding(A,psize)

m=psize(1); n=psize(2);
B=zeros(m*n,(size(A,2)-n+1)*(size(A,1)-m+1));

count=0;
for j=1:size(A,2)-n+1
	for i=1:size(A,1)-m+1
		count=count+1;
		temp=A(i:i+m-1,j:j+n-1);
		B(:,count)=temp(:);
	end
end