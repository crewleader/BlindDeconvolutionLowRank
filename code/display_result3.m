function drawbox=display_result3(true_img,output_img,true_psf,output_psf,varea,num_psf)

[vsize_y,vsize_x]=size(true_img{1});

scaled_vsize_y=size(output_img{1},1)-size(output_psf{1},1)+1;
scaled_vsize_x=size(output_img{1},2)-size(output_psf{1},2)+1;

for i=1:num_psf
	output_img{i}=reshape(output_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
	output_img{i}=imresize(output_img{i},[vsize_y vsize_x],'Method','nearest');
	true_psf{i}=adjust_size(true_psf{i},max(size(true_psf{i}))-size(true_psf{i}));
	true_psf{i}=imresize(true_psf{i}./max(max(true_psf{i})),[vsize_y vsize_y],'Method','nearest');
	output_psf{i}=adjust_size(output_psf{i},max(size(output_psf{i}))-size(output_psf{i}));
	output_psf{i}=imresize(output_psf{i}./max(max(output_psf{i})),[vsize_y vsize_y],'Method','nearest');
end

drawbox=[];
for i=1:2:num_psf
	tempbox=true_img{i};
	tempbox=[tempbox output_img{i}];
	tempbox=[tempbox true_psf{i}];
	tempbox=[tempbox output_psf{i}];
	tempbox=[tempbox true_img{i+1}];
	tempbox=[tempbox output_img{i+1}];
	tempbox=[tempbox true_psf{i+1}];
	tempbox=[tempbox output_psf{i+1}];
	drawbox=[drawbox; tempbox];
end