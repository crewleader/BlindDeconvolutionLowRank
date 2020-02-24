clc
clear
close all

num_img=4;
num_psf=4;
num_set=2;

input_dir='result\static_scene\';
result_dir='result_img\static_scene\';

if(~exist(result_dir,'dir'))
	mkdir(result_dir)
end

for i=1:num_img
	for j=1:num_set
		load([input_dir 'non_blind_result_4_' num2str(i) '_' num2str(j) '.mat'],'true_img','true_psf','input_img','output_img','output_psf','lowrank_img','sparsity_img','elapsed_time','varea')
		T=true_img;
		K=true_psf;
		I=input_img;
		O=output_img;
		P=output_psf;
		L=lowrank_img;
		S=sparsity_img;
		t=elapsed_time;
		for k=1:num_psf
			true_img=T{k};
			true_psf=K{k};
			input_img=I{k};
			output_img=reshape(O{k}(logical(varea{k})),size(true_img));
			output_psf=P{k};
			lowrank_img=reshape(L{k}(logical(varea{k})),size(true_img));
			sparsity_img=reshape(S{k}(logical(varea{k})),size(true_img));
			sse=comp_upto_shift(output_img,true_img);
			save([result_dir 'im0' num2str(i) '_ker0' num2str((j-1)*num_psf+k) '.mat'],'true_img','true_psf','input_img','output_img','output_psf','lowrank_img','sparsity_img','sse','t')
		end
	end
end