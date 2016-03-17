function edge_list = create_edge_list(v_edges,h_edges)
%
% edge_list = create_edge_list(v_edges,h_edges)
%
% Receives the vertical and horizontal edge lists in the format output 
% by the edge detector and formats them into a single list consisting of 
% the (x,y) coordinates of the start and end points of each edge.
%
% INPUT:
% -------------------------------------------------------------------------
% v_edges       - list of detected vertical edges
% h_edges       - list of detected horizontal edge
%
% OUTPUT:
% -------------------------------------------------------------------------
% edge_list     - a list of the (x,y) coordinates of the start and end 
%                 points of the detected edges
%
% Written by Inbal Horev, 2013

y1_h = h_edges{1};
y2_h = h_edges{2};
x1_h = h_edges{3};
x2_h = h_edges{4};

y1_v = v_edges{3};
y2_v = v_edges{4};
x1_v = v_edges{1};
x2_v = v_edges{2};

edge_list.x1 = [reshape(x1_h,1,[]) reshape(x1_v,1,[])];
edge_list.x2 = [reshape(x2_h,1,[]) reshape(x2_v,1,[])];
edge_list.y1 = [reshape(y1_h,1,[]) reshape(y1_v,1,[])];
edge_list.y2 = [reshape(y2_h,1,[]) reshape(y2_v,1,[])];

end