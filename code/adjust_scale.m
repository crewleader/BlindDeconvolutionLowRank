function img=adjust_scale(img,scale,tsize,extrap_val,interp_method,center_position)

if nargin<4 || isempty(extrap_val)
	extrap_val=0; % number or 'replicate'
end

if nargin<5 || isempty(interp_method)
	interp_method='*cubic'; % '*linear' | '*nearest' | '*cubic' | '*spline'
end

if nargin<6 || isempty(center_position)
	center_position='center'; % 'center' or 'post' or 'pre'
end

tau=[scale(2) 0 0; 0 scale(1) 0; 0 0 1];
img=warp_image(img,tau,interp_method,[],extrap_val,center_position,tsize);