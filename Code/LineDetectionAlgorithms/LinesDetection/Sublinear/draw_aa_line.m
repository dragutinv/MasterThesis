function output = draw_aa_line(p1,p2,input)
%
% output = draw_aa_line(p1,p2,input)
% 
% Draw anti-aliased line between two points
%
% INPUT:
% -------------------------------------------------------------------------
% p1,p2     - start and end points of line
% input     - input matrix
%
% % INPUT:
% -------------------------------------------------------------------------
% output     - output matrix with line drawn on it
%
% Written by Inbal Horev, 2013


    s = size(input);
    img = zeros(s);
    flip = 0;

    x1 = p1(1); x2 = p2(1);
    y1 = p1(2); y2 = p2(2);
    dx = x2 - x1;
    dy = y2 - y1;
    if (abs(dx) < abs(dy))
        img = img';
        flip = 1;
        [x1,y1] = swap(x1,y1);
        [x2,y2] = swap(x2,y2);
        [dx,dy] = swap(dx,dy);    
    end
    if (x2 < x1)
        [x1,x2] = swap(x1,x2);
        [y1,y2] = swap(y1,y2);
    end
    m = dy/dx;

    xend = round(x1);
    yend = y1 + m*(xend - x1);
    xgap = 1 - frc(x1 + 0.5);
    xpxl1 = xend;
    ypxl1 = floor(yend);
    if (xpxl1 > 0)
        img(xpxl1, ypxl1) = (1 - frc(yend)) * xgap;
        img(xpxl1, ypxl1+1) = frc(yend) * xgap;
    end
    intery = yend + m;
    
    xend = round(x2);
    yend = y2 + m*(xend - x2);
    xgap = frc(x2 + 0.5);
    xpxl2 = xend;
    ypxl2 = floor(yend);
    img(xpxl2, ypxl2) = (1 - frc(yend)) * xgap;
    img(xpxl2, ypxl2+1) = frc(yend) * xgap;
    
    for x = (xpxl1+1):(xpxl2-1)
        img(x, floor(intery)) = 1 - frc(intery);
        img(x, floor(intery)+1) = frc(intery);
        intery = intery + m;
    end
    
    if (flip)
        img = img';
    end    
    output = img(1:s(1),1:s(2)) + input;
end

function [x,y] = swap(x,y)
    tmp = x;
    x = y;
    y = tmp;
end

function x = frc(x)
    x = x - fix(x);
end