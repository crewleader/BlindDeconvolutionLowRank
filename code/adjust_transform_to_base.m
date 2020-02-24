function tau=adjust_transform_to_base(tau,baseImage)

baseTau=tau{baseImage};
for i=1:length(tau)
	tau{i}=tau{i}/baseTau;
	tau{i}=tau{i}./tau{i}(3,3);
end
tau{baseImage}=eye(3);