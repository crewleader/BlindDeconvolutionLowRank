function [psf,img,xshift,yshift]=adjust_psf_center_discrete(psf,img)
[X,Y]=meshgrid(1:size(psf,2),1:size(psf,1));
xc1=sum(sum(psf.*X));
yc1=sum(sum(psf.*Y));
xc2=floor(size(psf,2)/2)+1;
yc2=floor(size(psf,1)/2)+1;
xshift=round(xc2-xc1);
yshift=round(yc2-yc1);
psf=interp2(X,Y,psf,X-xshift,Y-yshift,'nearest',0);
if nargin>=2
	maxshift=max(abs(xshift),abs(yshift));
	img=adjust_size(img,2*maxshift,'replicate');
	[X,Y]=meshgrid(1:size(img,2),1:size(img,1));
	img=interp2(X,Y,img,X+xshift,Y+yshift,'nearest',0);
	img=adjust_size(img,-2*maxshift);
else
	img=[];
end