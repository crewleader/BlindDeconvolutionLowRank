function [D,L,S,tau]=my_rasl_main(output_img,L,S,tau,base_psf,transform_type)

%% initialization
num_img=size(output_img,2);

thres=1e-7; % stopping condition of main loop
max_it=1000; % maximum iteration number of main loops
if num_img>=8
	lambdac=1; % lambda=lambdac/sqrt(m)
else
	lambdac=sqrt(8/num_img);
end

fsize=size(output_img{1});
xi=cell(1,num_img); follow_tau=cell(1,num_img);
identity_xi=projective_matrix_to_parameters(eye(3),transform_type);
for i=1:num_img
	% transformation matrix to parameters
	xi{i}=projective_matrix_to_parameters(tau{i},transform_type);
end

D=zeros(fsize(1)*fsize(2),num_img);
J=cell(1,num_img);
Q=cell(1,num_img);
R=cell(1,num_img);

dxf=fspecial('sobel')'/8; dyf=fspecial('sobel')/8;

%% start the main loop
iter=0;  % iteration number of outer loop in each scale
converged=0;
while ~converged
	iter=iter+1;
	
	for i=1:num_img
		% transformed image and derivatives with respect to affine parameters
		I=warp_image(output_img{i},tau{i},[],'invert');
		Ix=imfilter(I,dxf,'conv','replicate');
		Iy=imfilter(I,dyf,'conv','replicate');
		
		D(:,i)=I(:);
		
		% Compute Jacobian
		J{i}=image_jaco(Ix,Iy,fsize,xi{i},transform_type);
		% Using QR to orthogonalize the Jacobian matrix
		[Q{i},R{i}]=qr(J{i},0);
	end
	
	observed_fraction=sum(sum(D~=0))/numel(D);
	lambda=lambdac/sqrt(observed_fraction*max(size(D))); % for missing entry problem
	
	if iter==1
		Y=0;
		mu=1/norm(D);
		E=0;
	end
	
	%% RASL inner loop
	prev_L=L;
	[L,E,delta_xi,Y,mu]=my_rasl_inner_ialm(D,L,E,Q,(D~=0)&~S,lambda,Y,mu);
	
	if rank(L)==0
		error('Rank is 0 !!!')
	end
	
	for i=1:num_img
		delta_xi{i}=R{i}\delta_xi{i};
	end
	
	%% step in paramters
	for i=1:num_img
		follow_tau{i}=parameters_to_projective_matrix(identity_xi+delta_xi{i},transform_type);
		tau{i}=tau{i}*follow_tau{i};
		tau{i}=tau{i}./tau{i}(3,3);
	end
	tau=adjust_transform_to_base(tau,base_psf);
	for i=1:num_img
		L(:,i)=vec(warp_image(reshape(L(:,i),fsize),follow_tau{base_psf}));
		E(:,i)=vec(warp_image(reshape(E(:,i),fsize),follow_tau{base_psf}));
		Y(:,i)=vec(warp_image(reshape(Y(:,i),fsize),follow_tau{base_psf}));
	end
	for i=1:num_img
		% transformation matrix to parameters
		xi{i}=projective_matrix_to_parameters(tau{i},transform_type);
	end
	
	stoppingCriterion=norm(prev_L-L,'fro')/norm(L,'fro');
	if stoppingCriterion<=thres||iter>=max_it
		converged=true;
	end
end

for i=1:num_img
	% transformed image and derivatives with respect to affine parameters
	I=warp_image(output_img{i},tau{i},[],'invert');
	
	D(:,i)=I(:);
end