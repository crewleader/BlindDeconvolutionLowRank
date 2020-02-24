clc
clear
close all
fclose('all');

%% basic parameter
list_img=1:4;
list_psf=1:8;
list_num_multi_img=[4 8];

num_img=4; num_psf=8;

for m=list_num_multi_img
	mean_img_sse=0;
	count=0;
	for l=list_img
		num_set=length(list_psf)/m;
		list_set=1:num_set;
		for n=list_set
			if exist(['result\static_scene\non_blind_result_' num2str(m) '_' num2str(l) '_' num2str(n) '.mat'],'file')==2
				load(['result\static_scene\non_blind_result_' num2str(m) '_' num2str(l) '_' num2str(n) '.mat'],'img_sse','psf_sse','k','j')
				if k==0 && j==120
					disp(img_sse)
					mean_img_sse=mean_img_sse+img_sse;
					count=count+1;
				else
					disp([num2str(m) '_' num2str(l) '_' num2str(n) '_imperfect'])
				end
			else
				disp([num2str(m) '_' num2str(l) '_' num2str(n) '_noexist'])
			end
		end
	end
	mean_img_sse=mean_img_sse/count;
	fprintf('final result, img_sse=%f\n',mean_img_sse);
end