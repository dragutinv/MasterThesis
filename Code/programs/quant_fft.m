%
% Quantification of the Fourier Transform
%
%       [ima,imafft,mag_quant,phi_quant] = quant_fft(ima_in,max_level,nb_levels_mag,nb_levels_ophi)
%
% This function calculates the complex Fourier transform
% and the associated magnitude and phase (mag, phi) of the input real
% image ima_in. It then reduces the number of quantization levels to
% nb_levels.
%
%       ima_in : real input image
%       max_level: maximum value for both magnitude and phase
%       nb_levels_mag: Number of quantization levels for magnitude
%		nb_levels_phi: Number of quantization levels for phase.
%       imafft  : output quantized spectrum image (mag and phase are quantized!)
%                 real and imaginary part can be accessed through real
%                 and imag function (see help real, imag)

%		  ima		 : Equivalent reconstructed image in space domain.
%
%       mag_quant,phi_quant: Quantized magnitude and phase of the fourier transform
%
% Yvan Petillot, January 2002
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ima,imafft,mag_quant,phi_quant] = quant_fft(ima_in,max_level,nb_levels_mag,nb_levels_phi)

ima_in = double(ima_in);
[imafft,mag,phi] = fft2d(ima_in);


% Quantify phase and magnitude
phi_quant = quant(phi,nb_levels_phi,max_level);
phi_quant = phi_quant/max_level*2*pi;

%phi_quant = phi;
mag_quant = quant(mag,nb_levels_mag,max_level);

%mag_quant = mag;

imafft = mag_quant .* exp(j*phi_quant);
ima = abs(fftshift(ifft2(fftshift(imafft))));

% figure;
% subplot(1, 4, 1);
% imagesc(ima_in);
% axis image;
% title('Input image');
% colormap(gray); 
% 
% subplot(1, 4, 2);
% imagesc(log(1+mag_quant));
% title(strcat('Magnitude quantisation:', num2str(nb_levels_mag)));
% axis image;
% 
% subplot(1, 4, 3);
% imagesc(phi_quant);
% title(strcat('Phase quantisation:', num2str(nb_levels_phi)));
% axis image;
% 
% subplot(1, 4, 4);
% imagesc(ima);
% axis image;
% title('Output image');
% colormap(gray); 


function out = quant(in,nb_levels,max_level)

interval = round(max_level/nb_levels);
% Find min of the input;

mini = min(min(in));
maxi = max(max(in));

% Converts in to be an integer between [0 255] with only nb_levels;

out = round((in - mini)/(maxi-mini)*max_level);
out = floor(out/interval)*interval;

