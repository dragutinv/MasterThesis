%
% Demo
% Applies the Sublinear edge detection algorithm to the powerline image
%
% Written by Inbal Horev, 2014

os = computer('arch');
if strcmp(os,'maci64') || strcmp(os,'glnxa64')
    addpath('../Sublinear');
    
    I = double(rgb2gray(imread('../Images/powerlines.jpg')))/255;
else
    addpath('..\Sublinear');
    
    I = double(rgb2gray(imread('..\Images\powerlines.jpg')))/255;
end


C = [8 10];     % number of strips to extract
j = 6;          % width of strips L=2^j+1;
w = 3;          % width of mask
sigma = NaN;    % noise level is estimated from the image
alpha_s = 0.5;  % false alarm rate in the strips
alpha_m = 0.1;  % false alarm rate for consistency test

[~,~,detectionsOverlay,~,~,~,~,~,runtime] = ...
    sublinear_edge_detection(I,sigma,j,C,w,alpha_s,alpha_m);

figure(); title('SubLinear'); imshow(detectionsOverlay);

disp(['Runtime: ', num2str(runtime),' sec']);

