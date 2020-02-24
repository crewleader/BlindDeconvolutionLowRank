function [xshift,yshift]=adjust_psf_center_discrete2(psf)
[X,Y]=meshgrid(1:size(psf,2),1:size(psf,1));
xc1=sum(sum(psf.*X));
yc1=sum(sum(psf.*Y));
xc2=floor(size(psf,2)/2)+1;
yc2=floor(size(psf,1)/2)+1;
xshift=round(xc2-xc1);
yshift=round(yc2-yc1);