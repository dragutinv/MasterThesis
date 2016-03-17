function overlay_img = overlay_edges(img,edge_map)
%
% overlay_img = overlay_edges(img,edge_map)
% 
% Overlays (in red) the detected edge map on the original input image.
%
% INPUT:
% -------------------------------------------------------------------------
% img           - input image
% edge_map      - binary map of detected edges
%
% OUTPUT:
% -------------------------------------------------------------------------
% overlay_img   - edges overlayed on the image
%
% Written by Inbal Horev, 2013

overlay_r = im2double(img);
overlay_g = im2double(img);
overlay_b = im2double(img);

overlay_r(edge_map==1) = 1;
overlay_g(edge_map==1) = 0;
overlay_b(edge_map==1) = 0;

overlay_img = cat(3,overlay_r,overlay_g,overlay_b);