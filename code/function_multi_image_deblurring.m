function function_multi_image_deblurring(true_img,true_psf,input_img,params,l,m,result_dir)

addpath('../decolor/gco-v3.0/matlab')

resize_step=params.resize_step;
alpha_multiplier=params.alpha_multiplier;
num_scale=params.num_scale;
psize_y=params.psize_y; psize_x=params.psize_x;
gamma=params.gamma;
p=params.p;
beta=params.beta;
thr_e=params.thr_e;
num_try=params.num_try;
base_psf=params.base_psf;
display=params.display;
lambda=params.lambda;
delta=params.delta;
transform_type=params.transform_type;

if display
	if ispc
		figure('outerposition',[-6 32 1934 1169],'name',[num2str(l) '_' num2str(m)])
	else
		figure('outerposition',[1602 42 1918 1128],'name',[num2str(l) '_' num2str(m)])
	end
end

[vsize_y,vsize_x]=size(input_img{1});
fsize_y=vsize_y+psize_y-1; fsize_x=vsize_x+psize_x-1;
num_psf=length(input_img);
fileID=fopen([result_dir 'result_' num2str(num_psf) '_' num2str(l) '_' num2str(m) '.txt'],'w');

min_alpha=params.min_alpha/fsize_y/fsize_x;

fprintf('* %dth image %dth set\n',l,m);
fprintf(fileID,'* %dth image %dth set\n',l,m);

%% multi-scale blind deconvolultion
t=tic;
for k=num_scale:-1:0
	%% resize image
	if k~=0
		scaled_psize_y=round_odd(psize_y/resize_step^k); scaled_psize_x=round_odd(psize_x/resize_step^k);
		scaled_vsize_y=round(vsize_y/resize_step^k); scaled_vsize_x=round(vsize_x/resize_step^k);
	else
		scaled_psize_y=psize_y; scaled_psize_x=psize_x;
		scaled_vsize_y=vsize_y; scaled_vsize_x=vsize_x;
	end
	scaled_fsize_y=scaled_vsize_y+scaled_psize_y-1; scaled_fsize_x=scaled_vsize_x+scaled_psize_x-1;
	if k==num_scale
		scaled_input_img=cell(1,num_psf); output_img=cell(1,num_psf); output_psf=cell(1,num_psf); varea=cell(1,num_psf); tau=cell(1,num_psf);
		for i=1:num_psf
			scaled_input_img{i}=imresize(input_img{i},[scaled_vsize_y scaled_vsize_x]);
			output_img{i}=adjust_size(scaled_input_img{i},[scaled_fsize_y-scaled_vsize_y scaled_fsize_x-scaled_vsize_x]);
			varea{i}=adjust_size(true(scaled_vsize_y,scaled_vsize_x),[scaled_fsize_y-scaled_vsize_y,scaled_fsize_x-scaled_vsize_x]);
			output_psf{i}=adjust_size(1,[scaled_psize_y scaled_psize_x]-1);
			tau{i}=eye(3);
		end
	else
		scale_y=scaled_vsize_y/size(scaled_input_img{1},1); scale_x=scaled_vsize_x/size(scaled_input_img{1},2);
		for i=1:num_psf
			scaled_input_img{i}=imresize(input_img{i},[scaled_vsize_y scaled_vsize_x]);
			output_img{i}=adjust_scale(output_img{i},[scale_y scale_x],[scaled_fsize_y scaled_fsize_x]);
			varea{i}=adjust_size(true(scaled_vsize_y,scaled_vsize_x),[scaled_fsize_y-scaled_vsize_y,scaled_fsize_x-scaled_vsize_x]);
			output_psf{i}=adjust_scale(output_psf{i},[scale_y scale_x],[scaled_psize_y scaled_psize_x]);
			output_psf{i}=solve_psf_constrained(output_psf{i},scaled_input_img{i},output_img{i},beta,varea{i});
			tau{i}=[scale_x 0 0; 0 scale_y 0; 0 0 1]*tau{i}*[1/scale_x 0 0; 0 1/scale_y 0; 0 0 1];
		end
	end
	
	%% initialize graph cuts
	hMRF=cell(1,num_psf);
	for i=1:num_psf
		hMRF{i}=[];
	end
	
	%% initialize lowrank image
	Dtau=cell(1,num_psf); L=cell(1,num_psf); S=cell(1,num_psf); lowrank_img=cell(1,num_psf); sparsity_img=cell(1,num_psf);
	for i=1:num_psf
		L{i}=reshape(cell2mat(output_img),scaled_fsize_y*scaled_fsize_x,num_psf);
		S{i}=false(scaled_fsize_y*scaled_fsize_x,num_psf);
		lowrank_img{i}=reshape(L{i}(:,i),scaled_fsize_y,scaled_fsize_x);
		sparsity_img{i}=reshape(S{i}(:,i),scaled_fsize_y,scaled_fsize_x);
	end
	
	%% lowrank approximation & moving object detection
	for i=1:num_psf
		tau=adjust_transform_to_base(tau,i);
		[Dtau{i},L{i},S{i},tau]=my_rasl_main(output_img,L{i},S{i},tau,i,transform_type);
		[S{i},hMRF{i}]=graph_cuts(S{i},hMRF{i},Dtau{i},L{i},lambda/(2*gamma),(0.5^k)*delta/(2*gamma),[scaled_fsize_y scaled_fsize_x]);
	end
	
	%% apply translation (sub-pixel alignment)
	tau=adjust_transform_to_base(tau,base_psf);
	for i=1:num_psf
		translate_tau=[1 0 tau{i}(1,3)-round(tau{i}(1,3)); 0 1 tau{i}(2,3)-round(tau{i}(2,3)); 0 0 1];
		output_img{i}=warp_image(output_img{i},translate_tau,[],'invert');
		L_img=mat2cell(reshape(L{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
		S_img=mat2cell(reshape(S{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
		for o=1:num_psf
			L_img{o}=warp_image(L_img{o},translate_tau,[],'invert');
			S_img{o}=warp_image(S_img{o},translate_tau,'*nearest','invert');
		end
		L{i}=reshape(cell2mat(L_img),scaled_fsize_y*scaled_fsize_x,num_psf);
		S{i}=reshape(cell2mat(S_img),scaled_fsize_y*scaled_fsize_x,num_psf);
		output_psf{i}=warp_image(output_psf{i},translate_tau);
		output_psf{i}=solve_psf_constrained(output_psf{i},scaled_input_img{i},output_img{i},beta,varea{i});
		tau{i}=[1 0 -tau{i}(1,3)+round(tau{i}(1,3)); 0 1 -tau{i}(2,3)+round(tau{i}(2,3)); 0 0 1]*tau{i};
		lowrank_img{i}=reshape(L{i}(:,i),scaled_fsize_y,scaled_fsize_x);
		sparsity_img{i}=reshape(S{i}(:,i),scaled_fsize_y,scaled_fsize_x);
	end
	
	%% blind deconvolution
	alpha=min_alpha*alpha_multiplier^(k-0.5);
	for j=1:num_try
		%% lowrank approximation & moving object detection
		for i=1:num_psf
			tau=adjust_transform_to_base(tau,i);
			[Dtau{i},L{i},S{i},tau]=my_rasl_main(output_img,L{i},S{i},tau,i,transform_type);
			[S{i},hMRF{i}]=graph_cuts(S{i},hMRF{i},Dtau{i},L{i},lambda/(2*gamma),(0.5^k)*delta/(2*gamma),[scaled_fsize_y scaled_fsize_x]);
		end
		
		%% apply translation (sub-pixel alignment)
		tau=adjust_transform_to_base(tau,base_psf);
		for i=1:num_psf
			translate_tau=[1 0 tau{i}(1,3)-round(tau{i}(1,3)); 0 1 tau{i}(2,3)-round(tau{i}(2,3)); 0 0 1];
			output_img{i}=warp_image(output_img{i},translate_tau,[],'invert');
			L_img=mat2cell(reshape(L{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
			S_img=mat2cell(reshape(S{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
			for o=1:num_psf
				L_img{o}=warp_image(L_img{o},translate_tau,[],'invert');
				S_img{o}=warp_image(S_img{o},translate_tau,'*nearest','invert');
			end
			L{i}=reshape(cell2mat(L_img),scaled_fsize_y*scaled_fsize_x,num_psf);
			S{i}=reshape(cell2mat(S_img),scaled_fsize_y*scaled_fsize_x,num_psf);
			output_psf{i}=warp_image(output_psf{i},translate_tau);
			output_psf{i}=solve_psf_constrained(output_psf{i},scaled_input_img{i},output_img{i},beta,varea{i});
			tau{i}=[1 0 -tau{i}(1,3)+round(tau{i}(1,3)); 0 1 -tau{i}(2,3)+round(tau{i}(2,3)); 0 0 1]*tau{i};
			lowrank_img{i}=reshape(L{i}(:,i),scaled_fsize_y,scaled_fsize_x);
			sparsity_img{i}=reshape(S{i}(:,i),scaled_fsize_y,scaled_fsize_x);
		end
		
		%% blind deconvolution
		for i=1:num_psf
			%% sharp image step
			output_img{i}=solve_image_irls(output_img{i},output_psf{i},scaled_input_img{i},lowrank_img{i},sparsity_img{i},gamma,alpha,p,200,1e-6,thr_e);
			
			%% blur step
			output_psf{i}=solve_psf_constrained(output_psf{i},scaled_input_img{i},output_img{i},beta,varea{i});
		end
		
		%% adjust base psf to center (discrete)
		for i=1:num_psf
			[xshift,yshift]=adjust_psf_center_discrete2(output_psf{i});
			translate_tau=[1 0 xshift; 0 1 yshift; 0 0 1];
			output_img{i}=warp_image(output_img{i},translate_tau,'*nearest','invert');
			L_img=mat2cell(reshape(L{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
			S_img=mat2cell(reshape(S{i},scaled_fsize_y,scaled_fsize_x*num_psf),scaled_fsize_y,repmat(scaled_fsize_x,1,num_psf));
			for o=1:num_psf
				L_img{o}=warp_image(L_img{o},translate_tau,'*nearest','invert');
				S_img{o}=warp_image(S_img{o},translate_tau,'*nearest','invert');
			end
			L{i}=reshape(cell2mat(L_img),scaled_fsize_y*scaled_fsize_x,num_psf);
			S{i}=reshape(cell2mat(S_img),scaled_fsize_y*scaled_fsize_x,num_psf);
			output_psf{i}=warp_image(output_psf{i},translate_tau,'*nearest');
			output_psf{i}=solve_psf_constrained(output_psf{i},scaled_input_img{i},output_img{i},beta,varea{i});
			tau{i}=[1 0 -xshift; 0 1 -yshift; 0 0 1]*tau{i};
			tau=adjust_transform_to_base(tau,base_psf);
			lowrank_img{i}=reshape(L{i}(:,i),scaled_fsize_y,scaled_fsize_x);
			sparsity_img{i}=reshape(S{i}(:,i),scaled_fsize_y,scaled_fsize_x);
		end
		
		elapsed_time=floor(toc(t));
		drawbox=display_result2(true_img,output_img,lowrank_img,sparsity_img,output_psf,varea,num_psf);
		imwrite(drawbox,[result_dir 'blind_result_' num2str(num_psf) '_' num2str(l) '_' num2str(m) '.png']);
		if display
			imshow(drawbox), drawnow
		end
		[img_sse,psf_sse]=calculate_error2(true_img,output_img,true_psf,output_psf,varea,num_psf);
		fprintf('%dth scale %dth blind, img_sse=%f, psf_sse=%f, time=%d\n',k,j,img_sse,psf_sse,elapsed_time);
		fprintf(fileID,'%dth scale %dth blind, img_sse=%f, psf_sse=%f, time=%d\n',k,j,img_sse,psf_sse,elapsed_time);
		save([result_dir 'blind_result_' num2str(num_psf) '_' num2str(l) '_' num2str(m)])
		
		%% non-blind deconvolution
		for i=1:num_psf
			output_img{i}=solve_image_irls(output_img{i},output_psf{i},scaled_input_img{i},lowrank_img{i},sparsity_img{i},0,alpha,p,200,1e-6,thr_e);
		end
		
		elapsed_time=floor(toc(t));
		drawbox=display_result3(true_img,output_img,true_psf,output_psf,varea,num_psf);
		imwrite(drawbox,[result_dir 'non_blind_result_' num2str(num_psf) '_' num2str(l) '_' num2str(m) '.png']);
		if display
			imshow(drawbox), drawnow
		end
		[img_sse,psf_sse]=calculate_error2(true_img,output_img,true_psf,output_psf,varea,num_psf);
		fprintf('%dth scale non-blind, img_sse=%f, psf_sse=%f, time=%d\n',k,img_sse,psf_sse,elapsed_time);
		fprintf(fileID,'%dth scale non-blind, img_sse=%f, psf_sse=%f, time=%d\n',k,img_sse,psf_sse,elapsed_time);
		save([result_dir 'non_blind_result_' num2str(num_psf) '_' num2str(l) '_' num2str(m)])
		
		alpha=max(min_alpha,alpha*exp(-log(2)/num_try));
	end
end

fclose(fileID);