function [strong_responses,sigma] = calc_responses(img,params)
%
% [strong_responses,sigma] = calc_responses(img,params)
%
% Calculates edge responses for a given mask and returns only those 
% which are statistically significant.
%
% INPUT:
% -------------------------------------------------------------------------
% img               - input image
% params            -  general parameters for edge detection (see 
%                      params.rtf for details)
% OUPUT:
% -------------------------------------------------------------------------
% strong_responses  - responses and parameters of candidate edges
% sigma             - noise level estimated from the image / given by user
%
% Written by Inbal Horev, 2013.

mask = params.mask;

% padding image assuming a symmetric mask
padding_length = find(diff(mask))-1;
padded_img = [fliplr(img(:,1:padding_length)) img fliplr(img(:,(end-padding_length+1):end))];

pixel_responses = conv2(padded_img,mask,'valid')/sum(abs(mask));
edge_responses = calc_integrals(pixel_responses)';
sqr_pixel_responses = pixel_responses.^2;
sqr_edge_responses = calc_integrals(sqr_pixel_responses)';

if isnan(params.sigma)
    % image noise estimation
    Z = abs(pixel_responses(:))*sqrt(sum(mask.^2))/norminv(0.75); % Z are normalized pixel responses
    sigma = median(Z(Z/median(Z) < 3));    
else
    sigma = params.sigma;
end

L = size(img,1)-1;  n = size(img,2);
if mod(log2(L),1)~=0
    error('bad strip width');
end
% not all orientations are legal
for i = 1:L 
    edge_responses(i,1:(L-i)) = 0;
    edge_responses(end-L+i,(end+1-i):end) = 0;    
    sqr_edge_responses(i,1:(L-i)) = 0;
    sqr_edge_responses(end-L+i,(end+1-i):end) = 0; 
end

N = n*(2*L+1); % number of integrals = n pixels * (2L+1) orientations/pixel
alpha_s = params.alpha_s; % false alarm rate
t = sqrt(2*log(N)-log(log(N)) - log(4*pi) - 2*log(abs(log(1-alpha_s))));
t_s = sigma*t/sqrt(sum(abs(mask))*(L-1));
strong_responses = edge_responses.*(abs(edge_responses) > t_s);
v = (sqr_edge_responses - edge_responses.^2).*(abs(edge_responses) > t_s);

pos = sign(strong_responses) == 1;
neg = sign(strong_responses) == -1;
k = 10;
V = get_min_v_per_cluster(v.*pos,strong_responses.*pos,k) + ...
    get_min_v_per_cluster(v.*neg,strong_responses.*neg,k);

strong_responses = strong_responses.*(V~=0);

end

function variance = get_min_v_per_cluster(variance,responses,k)
dilated_data = bwdist(variance) <= 1;
cc = bwconncomp(dilated_data,8);
stats = regionprops(cc,'BoundingBox');
bb = cat(1,stats.BoundingBox);

for i = 1:cc.NumObjects
    x1 = ceil(bb(i,2)) + 1;
    y1 = ceil(bb(i,1)) + 1;
    
    x2 = x1 + bb(i,4) - 2;
    y2 = y1 + bb(i,3) - 2;
    var_patch = variance(x1:x2,y1:y2);
    res_patch = abs(responses(x1:x2,y1:y2));
    var_patch(var_patch == 0) = inf;
    res_patch(res_patch == 0) = 1e-15;
        
    [~,idx] = sort(sqrt(var_patch(:))./res_patch(:),'ascend');
    if (length(var_patch(:)) > k)
        var_patch(idx(k+1:end)) = 0;
    end
    
    var_patch(isinf(var_patch)) = 0;
    variance(x1:x2,y1:y2) = var_patch;

end
end