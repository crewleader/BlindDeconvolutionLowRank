function y=conv2fft(x,k,domain)

if nargin < 3
	domain = 'full';
end

[x_size_y,x_size_x] = size(x);
[k_size_y,k_size_x] = size(k);
f_size_y = x_size_y + k_size_y - 1;
f_size_x = x_size_x + k_size_x - 1;

nomin1 = fft2(x,f_size_y,f_size_x);
nomin2 = fft2(k,f_size_y,f_size_x);
y = real(ifft2(nomin1.*nomin2));

if strcmp(domain,'same')
	s_size_y = floor(k_size_y/2);
	s_size_x = floor(k_size_x/2);
	e_size_y = ceil(k_size_y/2)-1;
	e_size_x = ceil(k_size_x/2)-1;
	y = y(1+s_size_y:end-e_size_y,1+s_size_x:end-e_size_x);
elseif strcmp(domain,'valid')
	s_size_y = k_size_y-1;
	s_size_x = k_size_x-1;
	e_size_y = k_size_y-1;
	e_size_x = k_size_x-1;
	y = y(1+s_size_y:end-e_size_y,1+s_size_x:end-e_size_x);
end