function [responses,sigma,strip_starts,strip_ends,strip_img] = calc_strip_responses(params)
%
% [responses,sigma,strip_starts,strip_ends,strip_img] = calc_strip_responses(params)
%
% Returns the parameters (position and orientation) of statistically 
% significant edges in each strip
%
% INPUT:
% -------------------------------------------------------------------------
% params        - general parameters for edge detection (see 
%                 params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% responses     - position and orientation of candidate edges from each
%                 strip
% sigma         - noise level estimated from the image / given by user
% strip_starts  - vertical start points of extracted image strips
% strip_ends    - vertical end points of extracted image strips
% strip_img     - image consisting only of extracted strips
%
% Written by Inbal Horev, 2013

C = params.C;
mask = params.mask;
L = params.L;
img = params.img;

num_orientations = 2*L-1;
n = size(img,2);
pad_length = find(diff(mask))-1;

[strips,strip_starts,strip_ends,strip_img] = get_strips(params);
responses = zeros([num_orientations (n + 2*pad_length - length(mask) +1) C]);
sigma_est = zeros(1,C);
for i = 1:C
    [responses(:,:,i),sigma_est(i)] = calc_responses(strips(:,:,i),params);
    
end
sigma = min(sigma_est);
