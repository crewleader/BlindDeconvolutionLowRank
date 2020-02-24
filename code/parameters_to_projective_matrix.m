function tau=parameters_to_projective_matrix(u,transform_type)
tau=eye(3);
if strcmp(transform_type,'translation')
	tau(1:2,3)=[u(1); u(2)];
elseif strcmp(transform_type,'euclidean')
	tau(1:2,3)=[u(1); u(2)];
	tau(1:2,1:2)=[cos(u(3)) -sin(u(3)); sin(u(3)) cos(u(3))];
elseif strcmp(transform_type,'similarity')
	tau(1:2,3)=[u(1); u(2)];
	tau(1:2,1:2)=[1+u(3) -u(4); u(4) 1+u(3)];
elseif strcmp(transform_type,'affine')
	tau(1:2,3)=[u(1); u(2)];
	tau(1:2,1:2)=[1+u(3) u(4); u(5) 1+u(6)];
elseif strcmp(transform_type,'projective')
	tau(1:2,3)=[u(1); u(2)];
	tau(1:2,1:2)=[1+u(3) u(4); u(5) 1+u(6)];
	tau(3,1:2)=[u(7) u(8)];
end