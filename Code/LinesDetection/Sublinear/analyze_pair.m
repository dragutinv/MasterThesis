function [edges,edge_signs] = analyze_pair(strip1_candidates,strip2_candidates,strip1_idx,strip2_idx,params)
%
% [edges,edge_signs] = ...
%   analyze_pair(top_responses,bottom_responses,t_idx,b_idx,params)
%
% Detects continuous vertical edges starting at one strip and ending at 
% the other. The strips may not be adjacent, so the index of each is given
% so that the distance between them may be determined.
%
% % INPUT:
% -------------------------------------------------------------------------
% strip1_candidates     - candidate edges from the first strip
% strip2_candidates     - candidate edges from the second strip
% strip1_idx            - index of first strip
% strip2_idx            - index of second strip
% params                - general parameters for edge detection 
%                         (see params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% edges                 - edges matched between the strips
% edge_signs            - direction of detected edges +- or -+
%
% Written by Inbal Horev, 2013.

strip_starts = params.strip_starts;
strip_ends = params.strip_ends;

% match edges between strips
[matched_start_points,matched_end_points] = match_response_pair(strip1_candidates,strip2_candidates,strip1_idx,strip2_idx,params);

% verify matched edges
img_part = params.img(strip_starts(strip1_idx):strip_ends(strip2_idx),:);
[start_points,end_points,edge_signs] = ...
    verify_edges(img_part,matched_start_points,matched_end_points,params);

edges = cell(1,4);
edges{1} = start_points;
edges{2} = end_points;
edges{3} = strip_starts(strip1_idx)*ones(size(start_points));
edges{4} = strip_ends(strip2_idx)*ones(size(start_points));