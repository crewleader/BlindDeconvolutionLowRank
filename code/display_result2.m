function drawbox=display_result2(true_img,output_img,lowrank_img,sparsity_img,output_psf,varea,num_psf)

[vsize_y,vsize_x]=size(true_img{1});

scaled_vsize_y=size(output_img{1},1)-size(output_psf{1},1)+1;
scaled_vsize_x=size(output_img{1},2)-size(output_psf{1},2)+1;

for i=1:num_psf
	output_img{i}=reshape(output_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
	output_img{i}=imresize(output_img{i},[vsize_y vsize_x],'Method','nearest');
	output_psf{i}=adjust_size(output_psf{i},max(size(output_psf{i}))-size(output_psf{i}));
	output_psf{i}=imresize(output_psf{i}./max(max(output_psf{i})),[vsize_y vsize_y],'Method','nearest');
	lowrank_img{i}=reshape(lowrank_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
	lowrank_img{i}=imresize(lowrank_img{i},[vsize_y vsize_x],'Method','nearest');
	sparsity_img{i}=reshape(sparsity_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
	sparsity_img{i}=imresize(sparsity_img{i},[vsize_y vsize_x],'Method','nearest');
end

drawbox=[];
for i=1:2:num_psf
	tempbox=output_img{i};
	tempbox=[tempbox lowrank_img{i}];
	tempbox=[tempbox sparsity_img{i}];
	tempbox=[tempbox output_psf{i}];
	tempbox=[tempbox output_img{i+1}];
	tempbox=[tempbox lowrank_img{i+1}];
	tempbox=[tempbox sparsity_img{i+1}];
	tempbox=[tempbox output_psf{i+1}];
	drawbox=[drawbox; tempbox];
end