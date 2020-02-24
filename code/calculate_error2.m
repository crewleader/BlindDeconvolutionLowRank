function [img_sse,psf_sse]=calculate_error2(true_img,output_img,true_psf,output_psf,varea,num_img)

[vsize_y,vsize_x]=size(true_img{1});
[psize_y,psize_x]=size(true_psf{1});

scaled_vsize_y=size(output_img{1},1)-size(output_psf{1},1)+1;
scaled_vsize_x=size(output_img{1},2)-size(output_psf{1},2)+1;

for i=1:num_img
	output_img{i}=reshape(output_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
	output_img{i}=imresize(output_img{i},[vsize_y vsize_x],'Method','nearest');
	true_psf{i}=adjust_size(true_psf{i},59-size(true_psf{i}));
	output_psf{i}=imresize(output_psf{i},[psize_y psize_x],'Method','nearest');
	output_psf{i}(output_psf{i}<0)=0;
	output_psf{i}=output_psf{i}./sum(sum(output_psf{i}));
	output_psf{i}=adjust_size(output_psf{i},59-size(output_psf{i}));
end

%% Levin's method (SSE)
img_sse=zeros(1,num_img); psf_sse=zeros(1,num_img);
for i=1:num_img
	img_sse(i)=comp_upto_shift(output_img{i},true_img{i});
	psf_sse(i)=comp_upto_shift(output_psf{i},true_psf{i});
end
img_sse=mean(img_sse); psf_sse=mean(psf_sse);