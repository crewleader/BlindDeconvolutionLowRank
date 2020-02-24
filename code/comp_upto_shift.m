function ssde=comp_upto_shift(I1,I2)

maxshift=5;
subpixel=4;
cut=15;

shifts=-maxshift:1/subpixel:maxshift;
I2=I2(1+cut:end-cut,1+cut:end-cut);
I1=I1(1+cut-maxshift:end-cut+maxshift,1+cut-maxshift:end-cut+maxshift);
[N1,N2]=size(I2);
[gx,gy]=meshgrid(1-maxshift:N2+maxshift,1-maxshift:N1+maxshift);
[gx0,gy0]=meshgrid(1-maxshift:1/subpixel:N2+maxshift,1-maxshift:1/subpixel:N1+maxshift);
tI1=interp2(gx,gy,I1,gx0,gy0);

ssde=realmax;
for i=1:length(shifts)
	for j=1:length(shifts)
		xn=(1:N2)+shifts(i);
		yn=(1:N1)+shifts(j);
		xi=(xn+maxshift-1)*subpixel+1;
		yi=(yn+maxshift-1)*subpixel+1;
		ssde=min(ssde,sum(sum((tI1(yi,xi)-I2).^2)));
	end
end