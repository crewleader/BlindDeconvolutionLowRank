function u=projective_matrix_to_parameters(tau,transform_type)

if strcmp(transform_type,'translation')
	u=zeros(2,1);
	u=tau(1:2,3);
elseif strcmp(transform_type,'euclidean')
	u=zeros(3,1);
	u(1:2)=tau(1:2,3);
	u(3)=acos(tau(1,1));
	if tau(2,1)<0
		u(3)=-u(3);
	end
elseif strcmp(transform_type,'similarity')
	u=zeros(4,1);
	u(1:2)=tau(1:2,3);
	u(3)=tau(1,1)-1;
	u(4)=tau(2,1);
elseif strcmp(transform_type,'affine')
	u=zeros(6,1);
	u(1:2)=tau(1:2,3);
	u(3)=tau(1,1)-1;
	u(4)=tau(1,2);
	u(5)=tau(2,1);
	u(6)=tau(2,2)-1;
elseif strcmp(transform_type,'projective')
	u=zeros(8,1);
	u(1:2)=tau(1:2,3);
	u(3)=tau(1,1)-1;
	u(4)=tau(1,2);
	u(5)=tau(2,1);
	u(6)=tau(2,2)-1;
	u(7)=tau(3,1);
	u(8)=tau(3,2);
end