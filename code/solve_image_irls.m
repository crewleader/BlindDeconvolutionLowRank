function x=solve_image_irls(x,filt1,I,L,S,gamma,we,exp_a,max_it,thres,thr_e)

dxf=[1,-1];
dyf=[1;-1];

for t=1:max_it
	dx=conv2(x,dxf,'valid');
	dy=conv2(x,dyf,'valid');
	
	weight_x=(thr_e+(dx).^2).^(exp_a/2-1);
	weight_y=(thr_e+(dy).^2).^(exp_a/2-1);
	
	prev_x=x;
	x=solve_image_L2_w(x,filt1,I,L,S,gamma,we,weight_x,weight_y,max_it,thres);
	if sum(sum((prev_x-x).^2))/numel(x)<thres
		break
	end
end