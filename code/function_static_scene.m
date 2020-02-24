function function_static_scene(fixed_l,fixed_j)

clc
close all
fclose('all');

rng(0)

%% basic parameter
list_img=1:4;
list_psf=1:8;
list_num_multi_img=4; % the number of elements in a set
input_dir='../LevinEtalCVPR09Data/Levin09blurdata/';
result_dir='result/static_scene/';

if(~exist(result_dir,'dir'))
	mkdir(result_dir)
end
num_img=4; num_psf=8;

%% single-image blind deconvolultion parameter
params.psize_y=31; params.psize_x=31; % must be a odd number
params.gamma=0.6;
params.p=0;
params.beta=1/320;
params.thr_e=1/1500;
params.num_try=120;
params.base_psf=1;
params.resize_step=2^(1/2);
params.alpha_multiplier=2;
params.min_alpha=0.123;
params.num_scale=floor(log(min([params.psize_y params.psize_x])/3)/log(params.resize_step));
params.display=1;
params.lambda=0.088^2*params.gamma;
params.delta=0.04*params.gamma;
params.transform_type='projective'; % parametric tranformation model: 'translation'|'euclidean'|'similarity'|'affine'|'projective'

%% load dataset
true_img=cell(num_img,num_psf); true_psf=cell(num_img,num_psf); input_img=cell(num_img,num_psf);
for l=list_img
	for i=list_psf
		load([input_dir 'im0' num2str(4+l) '_flit0' num2str(i) '.mat'],'x'), true_img{l,i}=x; clear x
		load([input_dir 'im0' num2str(4+l) '_flit0' num2str(i) '.mat'],'f'), f=f(2:end-1,2:end-1); true_psf{l,i}=rot90(f,2); clear f
		true_psf{l,i}=adjust_size(true_psf{l,i},[params.psize_y params.psize_x]-size(true_psf{l,i}));
		true_psf{l,i}=adjust_psf_center_discrete(true_psf{l,i});
		load([input_dir 'im0' num2str(4+l) '_flit0' num2str(i) '.mat'],'y'), input_img{l,i}=y; clear y
	end
end

%% multi-image blind deconvolution
if nargin>=1 && ~isempty(fixed_l)
	list_img=fixed_l;
end
for l=list_img
	for m=list_num_multi_img
		num_set=length(list_psf)/m;
		list_set=1:num_set;
		if nargin>=2 && ~isempty(fixed_j)
			list_set=fixed_j;
		end
		for j=list_set
			list=list_psf(1+(j-1)*end/num_set:end/num_set+(j-1)*end/num_set);
			function_multi_image_deblurring(true_img(l,list),true_psf(l,list),input_img(l,list),params,l,j,result_dir)
		end
	end
end