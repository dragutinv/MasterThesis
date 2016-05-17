function [edge_map,edge_list,overlay_img] = ...
            visualise_edges(img,v_edges,h_edges)
%
% [edge_map,edge_list,overlay_img] = visualise_edges(img,v_edges,h_edges)
% 
% Creates a binary image of detected edges and overlays them in red on the
% input image
%
% INPUT:
% -------------------------------------------------------------------------
% img           - input image
% v_edges       - list of detected vertical edges
% h_edges       - list of detected horizontal edge
%
% OUTPUT:
% -------------------------------------------------------------------------
% edge_map      - a binary map of detected edges
% edge_list     - a list of the (x,y) coordinates of the start and end 
%                 points of the detected edges
% overlay_img   - the original image with detected edges overlayed on it
%
% Written by Inbal Horev, 2013
              
edge_list = create_edge_list(v_edges,h_edges);

h = vision.ShapeInserter;
release(h);
set(h,'Shape','Lines');
set(h,'BorderColor','White');

edge_map = zeros(size(img));
pts=[edge_list.x1', edge_list.y1', edge_list.x2', edge_list.y2'];
edge_map = step(h,edge_map,pts);

overlay_img = overlay_edges(img,edge_map);

end