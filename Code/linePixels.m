function [ lim1, lim2, lim3, lim4, lim5, lim6, lim7, lim8 ] = linePixels( m, n, x, y, offset )

if (x(1)+offset > n) lim1 = n; else lim1 = x(1)+offset; end;
if (y(1)+offset > m) lim2 = m; else lim2 = y(1)+offset; end;
if (x(2)+offset > n) lim3 = n; else lim3 = x(2)+offset; end;
if (y(2)+offset > m) lim4 = m; else lim4 = y(2)+offset; end;

if (x(1)-offset < 1) lim5 = 1; else lim5 = x(1)-offset; end;
if (y(1)-offset < 1) lim6 = 1; else lim6 = y(1)-offset; end;
if (x(2)-offset < 1) lim7 = 1; else lim7 = x(2)-offset; end;
if (y(2)-offset < 1) lim8 = 1; else lim8 = y(2)-offset; end;

end

