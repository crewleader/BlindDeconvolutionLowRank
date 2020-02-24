clc
clear
close all
fclose('all');

for l=1:4
	for n=1:2
		load(['result\shaking_scene\non_blind_result_4_' num2str(l) '_' num2str(n) '.mat'])

		[vsize_y,vsize_x]=size(true_img{1});

		scaled_vsize_y=size(output_img{1},1)-size(output_psf{1},1)+1;
		scaled_vsize_x=size(output_img{1},2)-size(output_psf{1},2)+1;
		
		for i=1:num_psf
			output_img{i}=reshape(output_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
			output_img{i}=imresize(output_img{i},[vsize_y vsize_x],'Method','nearest');
			true_psf{i}=adjust_size(true_psf{i},max(size(true_psf{i}))-size(true_psf{i}));
			true_psf{i}=adjust_size(true_psf{i},[27 27]-size(true_psf{i}));
			true_psf{i}=imresize(true_psf{i}./max(max(true_psf{i})),[vsize_y vsize_y],'Method','nearest');
			output_psf{i}=adjust_size(output_psf{i},max(size(output_psf{i}))-size(output_psf{i}));
			output_psf{i}=adjust_size(output_psf{i},[27 27]-size(output_psf{i}));
			output_psf{i}=imresize(output_psf{i}./max(max(output_psf{i})),[vsize_y vsize_y],'Method','nearest');
			lowrank_img{i}=reshape(lowrank_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
			lowrank_img{i}=imresize(lowrank_img{i},[vsize_y vsize_x],'Method','nearest');
			sparsity_img{i}=reshape(sparsity_img{i}(logical(varea{i})),scaled_vsize_y,scaled_vsize_x);
			sparsity_img{i}=imresize(sparsity_img{i},[vsize_y vsize_x],'Method','nearest');
		end
		
		for i=1:num_psf
			imwrite(input_img{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_input_img.png'])
			imwrite(true_img{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_true_img.png'])
			imwrite(output_img{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_output_img.png'])
% 			imwrite(lowrank_img{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_lowrank_img.png'])
% 			imwrite(sparsity_img{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_sparsity_img.png'])
			imwrite(true_psf{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_true_psf.png'])
			imwrite(output_psf{i},['presentation\shaking\' num2str(l) '_' num2str((n-1)*4+i) '_output_psf.png'])
		end
	end
end