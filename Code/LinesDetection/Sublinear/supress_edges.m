function centroid_edges = supress_edges(edges,edge_signs,params)
%
% centroid_edges = supress_edges(edges,edge_signs,params)
%
% Non-maximal suppression by choosing the centroid of each response
% cluster.
%
% INPUT:
% -------------------------------------------------------------------------
% edges             - detected edges
% edge_signs        - the direction of the edge
% params            - general parameters for edge detection (see params.rtf 
%                     for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% centroid_edges    - from each reponse cluster, the edge with the 
%                     average parameters (centroid)
% Written by Inbal Horev, 2013 

    strip_starts = params.strip_starts;
    strip_ends = params.strip_ends;
    C = params.C;

    centroid_edges = cell(C-1,4);

    % keep the "centroid" edges for each response cluster between each pair 
    % of adjacent strips
    for i = 1:(C-1)
        start_points = edges{i,1};
        end_points = edges{i,2};
        if (numel(start_points)==0)
            centroid_edges{i,1} = [];
            centroid_edges{i,2} = [];
            centroid_edges{i,3} = [];
            centroid_edges{i,4} = [];
        else            
            p = edge_signs{i} == 1;
            % centroids of positive edges (+- edges)
            [p_centroid_start_points,p_centroid_end_points] = ...            
                get_centroids(start_points(p),end_points(p));
            % centroids of negative edges (-+ edges)
            [n_centroid_start_points,n_centroid_end_points] = ...            
                get_centroids(start_points(~p),end_points(~p));
            
            k = numel(p_centroid_start_points) + numel(n_centroid_start_points);
            centroid_edges{i,1} = [p_centroid_start_points n_centroid_start_points];
            centroid_edges{i,2} = [p_centroid_end_points n_centroid_end_points];
            if (k > 0)
                centroid_edges{i,3} = strip_starts(i)*ones(1,k);
                centroid_edges{i,4} = strip_ends(i+1)*ones(1,k);
            else
                centroid_edges{i,3} = [];
                centroid_edges{i,4} = [];
            end
        end
    end
end

function [centroid_start_points,centroid_end_points] = get_centroids(start_points,end_points)
%
% [centroid_start_points,centroid_end_points] = get_centroids(start_points,end_points)
%
% algorithm for finding almost connected components given in:
% http://blogs.mathworks.com/steve/2010/09/07/almost-connected-component-labeling/

    if numel(start_points) == 0
        centroid_start_points = [];
        centroid_end_points = [];
        return;
    end
    x_min = min(start_points); x_max = max(start_points);
    y_min = min(end_points); y_max = max(end_points);
    data = zeros(x_max-x_min,y_max-y_min);
    for j = 1:length(start_points)
        data(start_points(j)-x_min+1,end_points(j)-y_min+1) = 1;
    end

    dilated_data = bwdist(data) <= 1;
    cc = labelmatrix(bwconncomp(dilated_data,8));
    cc(~data) = 0;
    stats = regionprops(cc,'Centroid');
    centroids = cat(1, stats.Centroid)';
    
    centroid_start_points = centroids(2,:)+x_min-1;
    centroid_end_points = centroids(1,:)+y_min-1;
end