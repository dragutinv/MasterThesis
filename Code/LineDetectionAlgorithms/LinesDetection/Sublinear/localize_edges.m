function localized_edges = localize_edges(edges,params)
%
% localized_edges = localize_endpoints(edges,params)
%
% Localizes endpoints of detected edges using max-likelihood estimator.
%
% INPUT:
% -------------------------------------------------------------------------
% edges             - list of edges detected
% params            - general parameters for edge detection (see params.rtf
%                     for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% localized_edges   - list of edges with localized end points
%
% Written by Inbal Horev, 2013

L = params.L;
starts = edges{1};
ends = edges{2};
tops = edges{3};
bottoms = edges{4};
strip_starts = params.strip_starts;
strip_ends = params.strip_ends;
C = params.C;

localized_edges = cell(size(edges));
refined_tops = zeros(size(tops));
refined_bottoms = zeros(size(tops));
refined_starts = zeros(size(tops));
refined_ends = zeros(size(tops));

extended_edge_endpoints = zeros(2,1);
for i = 1:length(tops)
    
    % top/bottom endpoints of extended edge
    idx = find(tops(i) == strip_starts);
    if (idx > 1)
        % middle of previous strip
        x1 = strip_ends(idx-1)-round(L/2);
    else
        x1 = tops(i);
    end
    idx = find(bottoms(i) == strip_ends);
    if (idx < C)
        % middle of next strip
        x2 = strip_starts(idx+1)+round(L/2);
    else
        x2 = bottoms(i);
    end    
    extended_edge_endpoints(1) = x1; % top
    extended_edge_endpoints(2) = x2; % bottom
    
    x_i = tops(i); 
    x_f = bottoms(i); 
    
    % horizontal coordinates corresponding to top/bottom endpoints
    y_i = starts(i); 
    y_f = ends(i);
    
    % original endpoints *relative* to extended endpoints
    original_endpoints = [x_i-x1+1; x2-x_f];
    
    A = (y_f-y_i)./(x_f-x_i);   % slope
    B = y_i - A*x_i;            % intercept
    
    % number of options to consider for each endpoint
    d_x = [x_i+L-x1+1; x2-(x_f-L)];
    
    [new_top,new_bottom,new_start,new_end] = ...
        localize_endpoints(A,B,extended_edge_endpoints,original_endpoints,d_x,params);
    
    refined_tops(i) = new_top;
    refined_bottoms(i) = new_bottom;
    refined_starts(i) = new_start;
    refined_ends(i) = new_end;
end

localized_edges{1} = refined_starts;
localized_edges{2} = refined_ends;
localized_edges{3} = refined_tops;
localized_edges{4} = refined_bottoms;