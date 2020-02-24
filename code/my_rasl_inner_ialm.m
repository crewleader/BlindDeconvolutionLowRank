function [L,E,dt,Y,mu]=my_rasl_inner_ialm(D,L,E,J,omega,lambda,Y,mu)

[m,n]=size(D);

tol=1e-7;
maxIter=1;

% initialize
mu_bar=mu*1e7;
rho=1.2172+1.8588*sum(sum(omega))/numel(omega);
d_norm=norm(D,'fro');

dt=cell(1,n);
for i=1:length(J)
	dt{i}=zeros(size(J{i},2),1);
end
dt_dual_matrix=zeros(m,n);

iter=0;
converged=false;
while ~converged
	iter=iter+1;
	
	temp_T=D+dt_dual_matrix-L+(1/mu)*Y;
	E=temp_T.*~omega+(1/(1+2*lambda/mu))*temp_T.*omega;
	
	temp_T=D+dt_dual_matrix-E+(1/mu)*Y;
	[U,S,V]=svd(temp_T,'econ');
	L=U*wthresh(S,'h',sqrt(2/mu))*V';
	
	temp_T=D-E-L+(1/mu)*Y;
	for i=1:n
		dt{i}=-J{i}'*temp_T(:,i);
		dt_dual_matrix(:,i)=J{i}*dt{i};
	end
	
	Z=D+dt_dual_matrix-L-E;
	Y=Y+mu*Z;
	
	mu=min(mu*rho,mu_bar);
	
	stoppingCriterion=norm(Z,'fro')/d_norm;
	if stoppingCriterion<=tol||iter>=maxIter
		converged=true;
	end
end