function [edge_map,edge_list,edge_overlay,...
          no_pp_edge_map,no_pp_edge_list,no_pp_edge_overlay,...
          h_strip_img,v_strip_img,runtime] = ...
          sublinear_edge_detection(I,sigma,j,C,w,alpha_s,alpha_m,visualize)
%
% [edge_map,edge_list,edge_overlay,...
%         no_pp_edge_map,no_pp_edge_list,no_pp_edge_overlay,...
%         h_strip_img,v_strip_img,runtime] = ...
%         sublinear_edge_detection(I,sigma,j,C,w,alpha_s,alpha_m,visualize)
%
% INPUT:
% -------------------------------------------------------------------------
% I         - input image. If RGB, will be converted to grayscale.
% sigma     - noise level. If sigma=NaN or not specified, its value 
%             will be estimated from the image.
% j         - determines the width of the extracted strips L=2^j+1
% C         - number of strips. if C has two elements, C(1), C(2) are the
%             number of horizontal and vertical strips, respectively
% w         - width of mask
% alpha_s   - (OPTIONAL) false alarm rate for edge detection in the strips.
%             Default value is 0.25
% alpha_m   - (OPTIONAL) false alarm rate for sliding window
%             Default value for is 0.1
% visualize - (OPTIONAL) flag whether to display edge overlay
%
% OUTPUT:
% -------------------------------------------------------------------------
% edge_map          - binary map of detected edges (if visualize == 1)
% edge_list         - list of detected edges
% edge_overlay      - input image with detected edge overlayed on it
%                     (if visualize == 1)
% no_pp_*           - same, just before post processing
% h_strip_img       - image consisting of the observed horizontal strips
% v_strip_img       - image consisting of the observed vertical strips
% runtime           - runtime of edge detection
%
% Written by Inbal Horev, 2013

params.verbose = 0;
params.L = 2^j + 1;
params.mask = [ones(1,w) -ones(1,w)];

if (ndims(I) == 3)
    I = rgb2gray(I);
end
I = double(I);

if exist('sigma','var')
    params.sigma = sigma;
else
    params.sigma = NaN;
end

params.img = I;
params.img_size = size(I);

if (numel(C) == 1)
    C = [C C];
end

if ~exist('alpha_s','var')
    alpha_s = 0.25;
end
if ~exist('alpha_m','var')
    alpha_m = 0.1;
end
params.alpha_s = alpha_s;
params.alpha_m = alpha_m;

ticId = tic();
% detect vertical edges
params.C = C(1);
[v_edges,v_no_pp_edges,h_strip_img] = analyse_image(params);
params.img = I'; params.img_size = size(I');
% detect horizontal edges
params.C = C(2);
[h_edges,h_no_pp_edges,v_strip_img] = analyse_image(params);
v_strip_img = v_strip_img';
runtime = toc(ticId);

if ~exist('visualize','var')    
    visualize = 1;
end

if visualize
    % creating edge maps and image overlays
    [edge_map,edge_list,edge_overlay] = ...
        visualise_edges(I,v_edges,h_edges);
    [no_pp_edge_map,no_pp_edge_list,no_pp_edge_overlay] = ...
        visualise_edges(I,v_no_pp_edges,h_no_pp_edges);
else
    % returning just the edge lists
    edge_list = create_edge_list(v_edges,h_edges);
    edge_map  = [];
    edge_overlay = [];
    no_pp_edge_list = create_edge_list(v_no_pp_edges,h_no_pp_edges);
    no_pp_edge_map  = [];
    no_pp_edge_overlay = [];
end
    
end