function [matched_start_points,matched_end_points] = ...
    match_response_pair(strip1_detections,strip2_detections,...
    strip1_idx,strip2_idx,params)
%
% [matched_start_points,matched_end_points] = ...
%    match_response_pair(strip1_responses,strip2_responses,...
%    strip1_idx,strip2_idx,params)
%
% Matches edges detected between two strips.
% Strips do not necessarily need to be adjacent. Their position is
% indicated by their index.
%
% INPUT:
% -------------------------------------------------------------------------
% strip1_detections     - position and orientation of edges detected in the
%                         first strip
% strip2_detections     - position and orientation of edges detected in the
%                         second strip
% strip1_idx            - index of first strip
% strip2_idx            - index of second strip
% params                - general parameters for edge detection (see 
%                         params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% matched_start_points  - start points of matched edges
% matched_end_points    - end points of matched edges
%
% Written by Inbal Horev, 2013

L = params.L;
d = params.strip_starts(strip2_idx) - params.strip_ends(strip1_idx); % distance between strips
s = size(strip1_detections);

[top_orientations,top_start_points] = find(strip1_detections);
[x_start_points,x_end_points,x_orientations,created_by] = extrapolate(top_start_points,top_orientations,L,d,s);

idx = sub2ind(s,x_orientations,x_start_points);
have_match = strip2_detections(idx)~=0;

matched_start_points =  reshape(top_start_points(created_by(have_match)),[],1);
matched_end_points =  reshape(x_end_points(have_match),[],1);

end 

function [vertical_distances,num_options] = get_vertical_pixel_distances(L,d)
% [vertical_distances,num_options] = get_vertical_pixel_distances(L,d)
%
% For each edge orientation compute the region of intersection with 
% the other strip. An angular error of at most half of the angle between 
% adjacent orientations is assumed.
%
% INPUT:
% -------------------------------------------------------------------------
% L                     - width of the strips
% d                     - distance between the strips
%
% OUTPUT:
% -------------------------------------------------------------------------
% vertical_distances    - for each orientation its vertical projection
%                         on the other strip
% num_options           - for each orientation, the number of intermediate 
%                         angles to consider

thetas = atan(-1:1/(L-1):1);
d_thetas = diff(thetas);
angular_bins = [thetas(1) thetas(1:end-1)+d_thetas/2; ...
                thetas(1:end-1)+d_thetas/2 thetas(end)];

spatial_bins = round((2*L+d)*tan(angular_bins));

vertical_distances = cell(1,numel(spatial_bins));
num_options = zeros(1,numel(spatial_bins));
for i = 1:size(spatial_bins,2)
    vertical_distances{i} = round([(L+d-1)/(2*L+d-1); 1] * (spatial_bins(1,i):spatial_bins(2,i)));
    num_options(i) = spatial_bins(2,i) - spatial_bins(1,i) + 1;
end

end

function [x_start_points,x_end_points,x_orientations,created_by] = extrapolate(start_points,orientations,L,d,s)
% [x_start_points,x_end_points,x_orientations,created_by] = ...
%   extrapolate(start_points,orientations,L,d,s)
%
% Calculate where edges starting in one strip pass in another strip
%
% INPUT:
% -------------------------------------------------------------------------
% start_points/orientations     - parameters of the edge in the first strip
% L                             - width of strips
% d                             - distance between the strips
% s                             - length of strip (n) x 
%                                 number of orientations (2L-1)
%
% OUPUT:
% -------------------------------------------------------------------------
% x_*                           - parameters of extraoplated edges
% created_by                    - the matching edge in the first strip

[vertical_distances, num_options] = get_vertical_pixel_distances(L,d);

% preallocating
m = sum(num_options(orientations));
x_start_points = zeros(1,m);
x_end_points = zeros(1,m);
x_orientations = zeros(1,m);
created_by = zeros(1,m);

if (m ~= 0)
    idx = 1;
    for i = 1:length(start_points)
        o = orientations(i);
        st = start_points(i); 
        v = vertical_distances{o};
        starts = st + v(1,:);
        ends = st + v(2,:);
        starts = starts(ends > 0 & ends < s(2)+1);
        ends = ends(ends > 0 & ends < s(2)+1);
        n = length(starts);
        
        x_start_points(idx:(idx+n-1)) = starts;
        x_end_points(idx:(idx+n-1)) = ends;
        x_orientations(idx:(idx+n-1)) = o;
        
        created_by(idx:(idx+n-1)) = i;
        idx = idx + n;
    end
    x_start_points = x_start_points(1:(idx-1));
    x_end_points = x_end_points(1:(idx-1));
    x_orientations = x_orientations(1:(idx-1));    
    created_by = created_by(1:(idx-1));
end
end