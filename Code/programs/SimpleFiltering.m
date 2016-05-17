%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Image Filtering
%
%       ima_out = SimpleFiltering(ima,type,cutoff)
%
% This function high or low pass filter an image
%
%       ima : real input image
%       type : 0 for high, 1 for low
%       cutoff: cutoff frequency in [0,1]. 0 is corresponds to the minimum frequency and 1
%					 to the maximum frequency.
%       ima_out : output real
%
%
% Yvan Petillot, December 2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imafft = SimpleFiltering(ima,type,cutoff, cutoff1)

% First convert ima to double
ima = double(ima);
% Create new figure
%figure(1)
% Display ima
%imagesc(ima);
%axis image;
%title('Original image');
%pause(0.1);
%drawnow;
% Get FFT:
imafft = fftshift(fft2(fftshift(ima)));
s = size(ima);

switch(type)
    % High pass filter
    case 0
        maxr = 0.5*sqrt(s(1)^2+s(2)^2);
        cutoff = maxr*cutoff;
        
        for i = 1 : s(1)
            for j = 1 : s(2)
                r = sqrt((i-1-s(1)/2)^2+(j-1-s(2)/2)^2);
                if ( r < cutoff)
                    imafft(i,j) = 0;
                end
            end
        end
    case 1
        maxr = 0.5*sqrt(s(1)^2+s(2)^2);
        cutoff = maxr*cutoff;
        
        for i = 1 : s(1)
            for j = 1 : s(2)
                r = sqrt((i-1-s(1)/2)^2+(j-1-s(2)/2)^2);
                if ( r > cutoff)
                    imafft(i,j) = 0;
                end
            end
        end
        %x = log(1+abs(imafft));
        %freq = mat2gray(x);
        %imshow(freq);
        %n = (freq >= 0.5 & freq <= 0.9);
        %n = mat2gray(n);
        %imwrite(freq, 'mask1.jpg');
        %n = mat2gray(rgb2gray(imread('mask1.jpg')));
        %imafft = imafft .* (n.^2);
end

% Display filtered spectrum
%figure(2);
%imagesc(log(1+abs(imafft)));
%axis image;
%display('Press any key to proceed');
%pause;
%figure(3);
%ima_out = fftshift(ifft2(fftshift(imafft)));
%keyboard;
%imagesc(abs(ima_out));
%axis image;
%title('Filtered image');
