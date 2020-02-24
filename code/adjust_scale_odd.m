function img=adjust_scale_odd(img,scale,tsize,pad_method,interp_method)

if nargin<4||isempty(pad_method)
	pad_method=0;
end

if nargin<5||isempty(interp_method)
	interp_method='cubic';
end

scale_y=scale(1); scale_x=scale(2);
tsize_y=tsize(1); tsize_x=tsize(2);

[X,Y]=meshgrid(1:size(img,2),1:size(img,1));
center_y=(size(img,1)+1)/2; center_x=(size(img,2)+1)/2;
step_y=floor((center_y-1)*scale_y); step_x=floor((center_x-1)*scale_x);
[Xq,Yq]=meshgrid(center_x-step_x/scale_x:1/scale_x:center_x+step_x/scale_x,center_y-step_y/scale_y:1/scale_y:center_y+step_y/scale_y);
img=interp2(X,Y,img,Xq,Yq,interp_method,0);
img=adjust_size(img,[tsize_y,tsize_x]-size(img),pad_method);