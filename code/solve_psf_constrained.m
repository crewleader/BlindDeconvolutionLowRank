function filt1=solve_psf_constrained(filt1,I,x,we,varea)

[psize_y,psize_x]=size(filt1);
[vsize_y,vsize_x]=size(I);

%% cut boundary
I=adjust_size(I,size(filt1)-1);
x=reshape(x(logical(varea)),vsize_y,vsize_x);
I=reshape(I(logical(varea)),vsize_y,vsize_x);
I=adjust_size(I,1-size(filt1));

%% create quadratic problem
A=im2col_sliding(x,[psize_y psize_x])';
	
k=rot90(filt1,2); k=k(:);
b=I(:);

%% solve quadratic problem
options=optimoptions('quadprog','Display','off');
k=quadprog(A'*A+we*eye(psize_y*psize_x),-A'*b,[],[],ones(1,psize_y*psize_x),1,zeros(psize_y*psize_x,1),[],k,options);

filt1=reshape(k,psize_y,psize_x);
filt1=rot90(filt1,2);