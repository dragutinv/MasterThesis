function [new_top,new_bottom,new_start,new_end] = ...
    localize_endpoints(A,B,extended_edge_endpoints,original_endpoints,d_x,params)
%
% [chosen_top,chosen_bottom,chosen_start,chosen_end] = ...
%   localize_endpoints(A,B,extended_edge_endpoints,original_endpoints,d_x,params)
%
% Localizes endpoints of detected edges using max-likelihood estimator.
%
% INPUT:
% -------------------------------------------------------------------------
% A                         - slope
% B                         - intercept
% extended_edge_endpoints   - top/bottom endpoints of extended edge
% original_endpoints        - original endpoints relative to extended 
%                             endpoints
% d_x                       - number of options to consider for top/bottom
%                             points in max-likelihood test                             
% params                    - general parameters for edge detection (see 
%                             params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% new_*                     - new coordinates of edge endpoints
%
% Written by Inbal Horev, 2013


img = params.img;
mask = params.mask;
mask_width = floor(length(mask)/2);

x1 = extended_edge_endpoints(1); % top
x2 = extended_edge_endpoints(2); % bottom
% computing horizontal coordinates of extended top/bottom endpoints
y1 = A*x1 + B;
y2 = A*x2 + B;
if (y1 < 1)
    x1 = round((1-B)/A);
    y1 = A*x1 + B;
end
if (y1 > size(img,2))
    x1 = round((size(img,2)-B)/A);
    y1 = A*x1 + B;
end
if (y2 < 1)
    x2 = round((1-B)/A);
    y2 = A*x2 + B;
end
if (y2 > size(img,2))
    x2 = round((size(img,2)-B)/A);
    y2 = A*x2 + B;
end

% computing pixels responses along extended edge
starts = repmat(y1,[1 length(mask)]) + ((-mask_width+1-mod(length(mask),2)):mask_width); 
ends = repmat(y2,[1 length(mask)]) + ((-mask_width+1-mod(length(mask),2)):mask_width);     
[~,data] = calc_specific_integrals(img(x1:x2,:),starts',ends');
data = data';

pixel_responses = sum(data.*repmat(-mask,[size(data,1) 1]),2)/sum(abs(mask));
l = length(pixel_responses);

% using max-likelihood estimator to localize endpoints
% computation is carried out *relative* to the edge location
[t,b] = find_boundaries(original_endpoints,d_x,pixel_responses);
% re-adding the edge location
new_top = t + x1;
new_bottom = b - l + x2;
new_start = A*new_top + B;
new_end = A*new_bottom + B;
