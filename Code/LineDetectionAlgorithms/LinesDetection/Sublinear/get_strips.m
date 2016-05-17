function [strips,strip_starts,strip_ends,strip_img] = get_strips(params)
%
% [strips,strip_starts,strip_ends,strip_img] = get_strips(params)
%
% Extracts C horizontal image strips of width L
%
% INPUT:
% -------------------------------------------------------------------------
% params           - general parameters for edge detection (see params.rtf
%                    for details)
% params.L         - width of strips to be extracted
% params.C         - number of strips to be extracted
%
% OUTPUT:
% -------------------------------------------------------------------------
% strips            - horizontal image strips
% strips_starts     - vertical start points of the strips
% strips_ends       - vertical end points of the strips
% strip_img         - image consisting only of the observed horizontal 
%                     strips
%
% Written by Inbal Horev, 2013

L = params.L;
C = params.C;
img = params.img;
n_x = size(img,1); n_y = size(img,2);

if (L*C > n_x)
    error('LC is larger than the number of image pixels');
end
if isfield(params,'verbose')
    verbose = params.verbose;
else
    verbose = 0;
end

r = n_x - L*C; % number of remaining pixels between strips
d = round(r/(C-1));
ds = [d*ones(1,C-2) r-d*(C-2) 0];

strips = zeros(L,n_y,C);
strip_starts = zeros(1,C);
strip_ends = zeros(1,C);
strip_img = zeros(size(img));
s = 0;
for i = 1:C
    strip_starts(i) = s+1;
    strip_ends(i) = s+L;    
    strip_img((s+1):(s+L),:) = img((s+1):(s+L),:);
    strips(:,:,i) = img((s+1):(s+L),:);
    s = s + L + ds(i);
end

if (verbose > 0)
    alpha = (log(C) + log(L) + log(n_y))/(log(n_x) + log(n_y));
    disp(['alpha = ',num2str(alpha)]);
    figure(); imagesc(strip_img); colormap gray; axis image;
end

