function img=warp_image(img,tau,interp_method,inverse_tau,extrap_val,center_position,tsize)

[fsize_y,fsize_x]=size(img);

if nargin<3||isempty(interp_method)
	interp_method='*cubic'; % '*linear' | '*nearest' | '*cubic' | '*spline'
end
if nargin<5||isempty(extrap_val)
	extrap_val=0; % number or 'replicate'
end
if nargin<6||isempty(center_position)
	center_position='center'; % 'center' or 'post' or 'pre'
end
if nargin<7||isempty(tsize)
	tsize=[fsize_y,fsize_x];
end

[X,Y]=meshgrid(1:fsize_x,1:fsize_y);
[Xp,Yp]=meshgrid(1:tsize(2),1:tsize(1));
if strcmp(center_position,'center')
	X=X-(fsize_x+1)/2; Y=Y-(fsize_y+1)/2;
	Xp=Xp-(tsize(2)+1)/2; Yp=Yp-(tsize(1)+1)/2;
elseif strcmp(center_position,'post')
	X=X-ceil((fsize_x+1)/2); Y=Y-ceil((fsize_y+1)/2);
	Xp=Xp-ceil((tsize(2)+1)/2); Yp=Yp-ceil((tsize(1)+1)/2);
elseif strcmp(center_position,'pre')
	X=X-floor((fsize_x+1)/2); Y=Y-floor((fsize_y+1)/2);
	Xp=Xp-floor((tsize(2)+1)/2); Yp=Yp-floor((tsize(1)+1)/2);
else
	error('center_position: ''center'' or ''post'' or ''pre''');
end
C=[Xp(:)'; Yp(:)'; ones(1,prod(tsize))];

if nargin<4||isempty(inverse_tau)||~strcmp(inverse_tau,'invert')
	Cp=tau\C;
else
	Cp=tau*C;
end

Xp=Cp(1,:)./Cp(3,:); Yp=Cp(2,:)./Cp(3,:);
Xp=reshape(Xp,tsize(1),tsize(2)); Yp=reshape(Yp,tsize(1),tsize(2));

if nargin<5||isempty(extrap_val)
	img=interp2(X,Y,img,Xp,Yp,interp_method,0);
elseif strcmp(extrap_val,'replicate')
	minX=min(min(X)); maxX=max(max(X));
	minY=min(min(Y)); maxY=max(max(Y));
	Xp(Xp<minX)=minX; Xp(Xp>maxX)=maxX;
	Yp(Yp<minY)=minY; Yp(Yp>maxY)=maxY;
	img=interp2(X,Y,img,Xp,Yp,interp_method);
else
	img=interp2(X,Y,img,Xp,Yp,interp_method,extrap_val);
end