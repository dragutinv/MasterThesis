function [img,start_points,end_points] = create_k_fibers(n,k,w,line_type)
% [img,start_points,end_points] = create_k_fibers(n,k,w)
%
% Creates an image containing fibers spanning the width of the image.
%
% INPUT:
% -------------------------------------------------------------------------
% n             - size of image 
% k             - number of fibers to create
% w             - width of fibers
% line_type     - (OPTIONAL) 'SMOOTH'|'JAGGED' default is 'SMOOTH'
%
% OUTPUT:
% -------------------------------------------------------------------------
% img           - created image
% start_points  - start points of created fibers
% end_points    - end points of created fibers
%
% Written by Inbal Horev, 2013

if ~exist('line_type','var')
    line_type = 'SMOOTH';
end

min_pix = w+1;
m = floor(w/2);

I = [min_pix (n-min_pix)];
start_points = choose_k_points(I,k,m);
end_points = choose_k_points(I,k,m);

num_points = min(length(start_points),length(end_points));
img = zeros(n);
for i = 1:num_points
    dx = end_points(i) - start_points(i);
    dy = n;
    a = dx/dy;
    b = start_points(i) - a;
    
    if strcmp(line_type,'JAGGED')
        for y = 1:n
            x = round(a*y + b);
            img((x-m+1-mod(w,2)):(x+m),y) = 1;
        end
    elseif strcmp(line_type,'SMOOTH')
        p1 = [start_points(i)-m+1-mod(w,2) 1];
        p2 = [end_points(i)-m+1-mod(w,2) n];
        img = draw_aa_line(p1,p2,img);
        
        p1 = [start_points(i)+m 1];
        p2 = [end_points(i)+m n];
        img = draw_aa_line(p1,p2,img);
        for y = 1:n
            x = ceil(a*y + b);
            img((x-m+1-mod(w,2)):(x+m-1),y) = 1;
        end
    else
        error('bad line type');
    end    
end
end

function points = choose_k_points(I,k,m)
% chooses k points at least m pixels apart from an interval I

unused = I(1):I(2);
points = zeros(1,k);
for i = 1:k
    num_vals = numel(unused);
    idx = 1 + floor(rand(1)*num_vals);
    points(i) = unused(idx);    
    used = (unused(idx)-2*m):(unused(idx)+2*m);
    unused = setdiff(unused,used);
end
points = sort(points);
end