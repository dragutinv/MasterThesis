function [ imgOut ] = improv_lines_fourier( courtImage )
%IMPROV_LINES_FOURIER Enhance lines using Fourier

cform = makecform('srgb2lab');
lab_he = applycform(courtImage,cform);

imafft=SimpleFiltering(lab_he(:,:,1), 1, 0.511111);

figure(2);
imagesc(log(1+abs(imafft)));
axis image;
pause;
ima_out = fftshift(ifft2(fftshift(imafft)));
imgOut = abs(ima_out);


end

