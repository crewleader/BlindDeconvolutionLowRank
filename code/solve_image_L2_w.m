function x=solve_image_L2_w(x,filt1,I,L,S,gamma,we,weight_x,weight_y,max_it,thres)

rfilt1=rot90(filt1,2);

dxf=[1,-1];
dyf=[1;-1];
drxf=rot90(dxf,2);
dryf=rot90(dyf,2);

b=conv2(I,rfilt1);
b=b+gamma*~S.*L;

Ax=conv2(conv2(x,filt1,'valid'),rfilt1);

Ax=Ax+we*conv2(conv2(x,dxf,'valid').*weight_x,drxf);
Ax=Ax+we*conv2(conv2(x,dyf,'valid').*weight_y,dryf);

Ax=Ax+gamma*~S.*x;

r=b-Ax;

iter=1;
conv2erged=false;
while iter<=max_it && ~conv2erged
	rho=(r(:)'*r(:));
	
	if (iter>1),                       % direction vector
		beta=rho/rho_1;
		p=r+beta*p;
	else
		p=r;
	end
	
	Ap=conv2(conv2(p,filt1,'valid'),rfilt1);
	
	Ap=Ap+we*conv2(conv2(p,dxf,'valid').*weight_x,drxf);
	Ap=Ap+we*conv2(conv2(p,dyf,'valid').*weight_y,dryf);
	
	Ap=Ap+gamma*~S.*p;
	
	q=Ap;
	alpha=rho/(p(:)'*q(:));
	x=x+alpha*p;                    % update approximation vector
	
	r=r-alpha*q;                      % compute residual
	
	rho_1=rho;
	
	iter=iter+1;
	if sum(sum((alpha*p).^2))/numel(p)<thres
		conv2erged=true;
	end
end