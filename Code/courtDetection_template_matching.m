function [ position ] = courtDetection_imgTemplate_matching( bwCourt, imgTemplate )
%COURTDETECTION_TEMPLATE_MATCHING Summary of this function goes here


%% calculate padding
bx = size(bwCourt, 2); 
by = size(bwCourt, 1);
tx = size(imgTemplate, 2); % used for bbox placement
ty = size(imgTemplate, 1);

%% fft
%c = real(ifft2(fft2(background) .* fft2(imgTemplate, by, bx)));

%// Change - Compute the cross power spectrum
Ga = fft2(bwCourt);
Gb = fft2(imgTemplate, by, bx);
%c = real(ifft2((Ga.*conj(Gb))./abs(Ga.*conj(Gb))));
c = normxcorr2(imgTemplate, bwCourt);

%% find peak correlation
[max_c, imax]   = max(abs(c(:)));
[ypeak, xpeak] = find(c == max(c(:)));
%figure; surf(c), shading flat; % plot correlation   

yoffSet = ypeak-size(imgTemplate,1);
xoffSet = xpeak-size(imgTemplate,2);


%% display best match

%// New - no need to offset the coordinates anymore
%// xpeak and ypeak are already the top left corner of the matched window
position = [xoffSet, yoffSet, tx, ty];
max_c
end

