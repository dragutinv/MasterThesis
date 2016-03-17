function [integrals,data] = ...
            calc_specific_integrals(img,start_points,end_points)
%
% [integrals,data] = ...
%       calc_specific_integrals(img,start_points,end_points)
%
% Interpolates data along line segments and calculates the integral.
%
% INPUT:
% -------------------------------------------------------------------------
% img               - input image
% start_points      - start points of integrals to compute
% end_points        - end points of integrals to compute
%
% OUPUT:
% -------------------------------------------------------------------------
% integrals         - integrals along specified line segments
% data              - interpolated data along the specified line segments
%
% Written by Inbal Horev, 2013.

n = size(img,1);
c = size(img,2);

% padding the image so edges near the boundaries can be detected
points = [start_points; end_points];
left_pad_length = 0;
right_pad_length = 0;
if ~(isempty(find(points < 1, 1)))
    left_pad_length = ceil(1-min(points(points < 1)));
end
if ~(isempty(find(points > c, 1)))
    right_pad_length = ceil(max(points(points > c))-c);
end
img = [fliplr(img(:,1:left_pad_length)) img fliplr(img(:,(end-right_pad_length+1):end))];
start_points = start_points + left_pad_length;
end_points = end_points + left_pad_length;

% sanity check
points = [start_points; end_points];
out_of_bounds = [points(points < 1); points(points > size(img,2))];
assert(numel(out_of_bounds) == 0, 'bad padding in calc_specific_integrals');

data = interpolate(img,start_points,ones(size(start_points)),end_points,n*ones(size(start_points)),n)';
integrals = reshape(trapz(data,2)/(n-1),size(start_points));