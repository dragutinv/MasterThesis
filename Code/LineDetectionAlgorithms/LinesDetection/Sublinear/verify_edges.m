function [start_points,end_points,edge_signs] = ...
    verify_edges(img,matched_start_points,matched_end_points,params)
%
% [start_points,end_points,edge_signs] = ...
%   verify_edges(img,matched_start_points,matched_end_points,params)
%
% Verifies that the edges matched between image strips are consistent by
% checking the contrast of windows of size m along the edge.
%
% INPUT:
% -------------------------------------------------------------------------
% img                   - original input image
% matched_start_points  - start points of matched edges
% matched_end_points    - end points of matched edges
% params                - general parameters for edge detection (see
%                         params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% start_points          - start points of verified edges
% end_points            - end points of verified edges
% edge_signs            - sign (direction) of the contrast of the edge
%
% Written by Inbal Horev, 2013

if isempty(matched_start_points)
    start_points = [];
    end_points = [];
    edge_signs = [];
    return;
end

mask = params.mask;

% padding the image to enable edge detection close to the image boundaries
padding_length = find(diff(mask),1)-1;
padded_img = [fliplr(img(:,1:padding_length)) img fliplr(img(:,(end-padding_length+1):end))];
diffs = conv2(padded_img,mask,'valid')/sum(abs(mask));

% computing the exact line integrals between start and end points
% also getting the (interpolated) pixels responses along the edge
[responses,pixel_responses] = calc_specific_integrals(diffs,matched_start_points,matched_end_points);

m = params.L;
segment_responses = conv2(pixel_responses,[0.5 ones(1,m-2) 0.5]/(m-1),'valid');
response_signs = reshape(sign(responses),[],1);

% minimal (maximal) segment responses for each edge
% takes into account the edge sign (direction)
min_responses = min(segment_responses.*repmat(response_signs,[1 size(segment_responses,2)]),[],2);

% minimal contrast threshold (consistency test)
alpha_m = params.alpha_m; % false alarm rate
sigma = params.sigma;
tau = norminv(1-alpha_m,0,sigma/sqrt(sum(abs(mask))*(m-1)));

thresholded = min_responses > tau;

start_points = matched_start_points(thresholded);
end_points = matched_end_points(thresholded);
edge_signs = response_signs(thresholded);
